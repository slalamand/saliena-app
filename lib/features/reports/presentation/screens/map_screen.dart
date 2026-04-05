import 'dart:ui';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_cache/flutter_map_cache.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';

import 'package:saliena_app/design_system/design_system.dart';
import 'package:saliena_app/features/reports/domain/entities/report.dart';
import 'package:saliena_app/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:saliena_app/features/settings/domain/repositories/settings_repository.dart';
import 'package:saliena_app/core/utils/name_formatter.dart';
import 'package:saliena_app/injection.dart';
import 'package:saliena_app/l10n/app_localizations.dart';

class MapScreen extends StatefulWidget {
  final GeoLocation? initialLocation;
  
  const MapScreen({
    super.key,
    this.initialLocation,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  LatLng? _currentLocation;
  bool _isLoadingLocation = true;
  // Default to Saliena, Latvia area
  static const LatLng _defaultLocation = LatLng(56.9496, 24.1052);
  
  // Tile caching for faster map loading
  CacheStore? _cacheStore;
  bool _cacheInitialized = false;

  // Filter state - default to showing pending and in progress
  Set<ReportStatus> _selectedStatuses = {
    ReportStatus.pending,
    ReportStatus.inProgress,
  };

  // Clustering state
  double _currentZoom = 13;
  List<Marker>? _cachedMarkers;
  List<Report>? _cachedReports;
  double? _cachedZoom;

  @override
  void initState() {
    super.initState();
    _initTileCache();
    _loadSavedFilter();
    if (widget.initialLocation != null) {
      _currentLocation = LatLng(
        widget.initialLocation!.latitude,
        widget.initialLocation!.longitude,
      );
      _isLoadingLocation = false;
    } else {
      _getCurrentLocation();
    }
  }

  Future<void> _loadSavedFilter() async {
    final savedFilter = await getIt<SettingsRepository>().getMapFilter();
    if (savedFilter != null && mounted) {
      setState(() {
        _selectedStatuses = savedFilter
            .map((s) => ReportStatus.fromString(s))
            .toSet();
      });
    }
  }

  Future<void> _saveFilter(Set<ReportStatus> statuses) async {
    await getIt<SettingsRepository>().saveMapFilter(
      statuses.map((s) => s.toStorageString()).toSet(),
    );
  }

  Future<void> _initTileCache() async {
    final cacheDir = await getTemporaryDirectory();
    _cacheStore = HiveCacheStore(
      cacheDir.path,
      hiveBoxName: 'saliena_map_tiles',
    );
    if (mounted) {
      setState(() {
        _cacheInitialized = true;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        final requested = await Geolocator.requestPermission();
        if (requested == LocationPermission.denied ||
            requested == LocationPermission.deniedForever) {
          setState(() {
            _isLoadingLocation = false;
          });
          return;
        }
      }

      // Optimization: Try to get last known position first for instant feedback
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && mounted) {
        setState(() {
          _currentLocation = LatLng(lastKnown.latitude, lastKnown.longitude);
          // Don't set _isLoadingLocation to false yet, we still want the precise one
        });
        _mapController.move(_currentLocation!, 14);
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (mounted) {
        setState(() {
          _currentLocation = LatLng(position.latitude, position.longitude);
          _isLoadingLocation = false;
        });
        
        _mapController.move(_currentLocation!, 14);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
        });
      }
    }
  }

  Color _getMarkerColor(ReportStatus status, ThemeData theme) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.inProgress:
        return theme.colorScheme.primary;
      case ReportStatus.fixed:
        return Colors.green;
    }
  }

  // Clustering logic - clusters only overlapping markers
  List<Marker> _buildClusteredMarkers(List<Report> reports, ThemeData theme) {
    if (reports.isEmpty) return [];

    // Cache markers to prevent rebuilding on every frame
    // Only rebuild if reports changed or zoom changed significantly (>0.5 levels)
    if (_cachedMarkers != null && 
        _cachedReports == reports && 
        _cachedZoom != null &&
        (_currentZoom - _cachedZoom!).abs() < 0.5) {
      return _cachedMarkers!;
    }

    // Cluster reports that would visually overlap
    final clusters = _clusterOverlappingReports(reports);
    final markers = <Marker>[];

    for (final cluster in clusters) {
      if (cluster.reports.length == 1) {
        markers.add(_buildSingleMarker(cluster.reports.first, theme));
      } else {
        markers.add(_buildClusterMarker(cluster, theme));
      }
    }

    // Cache the results
    _cachedMarkers = markers;
    _cachedReports = reports;
    _cachedZoom = _currentZoom;

    return markers;
  }

  List<_ReportCluster> _clusterOverlappingReports(List<Report> reports) {
    // Calculate overlap threshold based on zoom level
    // At higher zoom, markers appear further apart in lat/lng terms
    // Marker size is ~40px, we consider overlap if markers would touch
    final overlapThreshold = _getOverlapThreshold();
    
    final clusters = <_ReportCluster>[];
    final assigned = <String>{};

    for (final report in reports) {
      if (assigned.contains(report.id)) continue;

      final clusterReports = <Report>[report];
      assigned.add(report.id);

      // Find all reports that overlap with any report in this cluster
      bool foundNew = true;
      while (foundNew) {
        foundNew = false;
        for (final other in reports) {
          if (assigned.contains(other.id)) continue;

          // Check if this report overlaps with any report in the cluster
          for (final clusterReport in clusterReports) {
            if (_wouldOverlap(clusterReport, other, overlapThreshold)) {
              clusterReports.add(other);
              assigned.add(other.id);
              foundNew = true;
              break;
            }
          }
        }
      }

      // Calculate cluster center
      double avgLat = 0, avgLng = 0;
      for (final r in clusterReports) {
        avgLat += r.location.latitude;
        avgLng += r.location.longitude;
      }
      avgLat /= clusterReports.length;
      avgLng /= clusterReports.length;

      clusters.add(_ReportCluster(
        center: LatLng(avgLat, avgLng),
        reports: clusterReports,
      ));
    }

    return clusters;
  }

  double _getOverlapThreshold() {
    // Convert ~40px marker size to lat/lng degrees based on zoom
    // At zoom 1, ~360 degrees = 256px, so 1 degree ≈ 0.7px
    // At zoom N, 1 degree ≈ 0.7 * 2^N px
    // We want to find degrees that equal ~40px (marker overlap distance)
    // degrees = 40 / (0.7 * 2^zoom) ≈ 57 / 2^zoom
    final pixelsPerDegree = 0.7 * (1 << _currentZoom.round());
    final markerSizeInDegrees = 50 / pixelsPerDegree; // 50px overlap threshold
    return markerSizeInDegrees * markerSizeInDegrees; // squared for distance comparison
  }

  bool _wouldOverlap(Report a, Report b, double threshold) {
    final dLat = a.location.latitude - b.location.latitude;
    final dLng = a.location.longitude - b.location.longitude;
    final distanceSquared = dLat * dLat + dLng * dLng;
    return distanceSquared < threshold;
  }

  Marker _buildSingleMarker(Report report, ThemeData theme) {
    return Marker(
      key: ValueKey('marker_${report.id}'),
      point: LatLng(report.location.latitude, report.location.longitude),
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: () => _showReportDetails(report),
        child: Container(
          decoration: BoxDecoration(
            color: _getMarkerColor(report.status, theme),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.report_problem,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    );
  }

  Marker _buildClusterMarker(_ReportCluster cluster, ThemeData theme) {
    final statuses = cluster.reports.map((r) => r.status).toSet();
    final hasFixed = statuses.contains(ReportStatus.fixed);
    final hasPending = statuses.contains(ReportStatus.pending);
    final hasInProgress = statuses.contains(ReportStatus.inProgress);
    final isMixed = statuses.length > 1;

    // Create a stable key based on cluster contents
    final clusterKey = cluster.reports.map((r) => r.id).join('_');

    return Marker(
      key: ValueKey('cluster_$clusterKey'),
      point: cluster.center,
      width: 48,
      height: 48,
      child: GestureDetector(
        onTap: () => _showClusterSheet(cluster),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipOval(
            child: isMixed
                ? _buildSplitColorCircle(hasFixed, hasPending, hasInProgress, theme, cluster.reports.length)
                : Container(
                    color: _getClusterColor(statuses.first, theme),
                    child: Center(
                      child: Text(
                        '${cluster.reports.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSplitColorCircle(bool hasFixed, bool hasPending, bool hasInProgress, ThemeData theme, int count) {
    // Determine the two colors to show
    Color leftColor;
    Color rightColor;

    if (hasFixed && (hasPending || hasInProgress)) {
      leftColor = Colors.green;
      rightColor = hasPending ? Colors.orange : theme.colorScheme.primary;
    } else if (hasPending && hasInProgress) {
      leftColor = Colors.orange;
      rightColor = theme.colorScheme.primary;
    } else {
      leftColor = Colors.green;
      rightColor = Colors.orange;
    }

    return CustomPaint(
      painter: _SplitCirclePainter(leftColor: leftColor, rightColor: rightColor),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Color _getClusterColor(ReportStatus status, ThemeData theme) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.inProgress:
        return theme.colorScheme.primary;
      case ReportStatus.fixed:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocProvider.value(
      value: getIt<ReportsBloc>()..add(const ReportsLoadRequested()),
      child: Scaffold(
        backgroundColor: SalienaColors.getBackgroundBlue(context),
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.map,
            style: TextStyle(
              color: SalienaColors.getTextColor(context),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: SalienaColors.getTextColor(context)),
          actions: [
            IconButton(
              icon: Icon(Icons.filter_list, color: SalienaColors.getTextColor(context)),
              onPressed: _showFilterSheet,
            ),
          ],
        ),
        body: BlocBuilder<ReportsBloc, ReportsState>(
          builder: (context, state) {
            final allReports = state is ReportsLoaded ? state.reports : <Report>[];
            // Apply filter to reports
            final reports = allReports
                .where((r) => _selectedStatuses.contains(r.status))
                .toList();

            return Stack(
              children: [
                // Map
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation ?? _defaultLocation,
                    initialZoom: 13,
                    minZoom: 5,
                    maxZoom: 18,
                    onPositionChanged: (position, hasGesture) {
                      // Only update zoom if it changed significantly to avoid constant rebuilds
                      if ((position.zoom - _currentZoom).abs() > 0.5) {
                        _currentZoom = position.zoom;
                        // Invalidate cache so markers rebuild on next frame
                        _cachedMarkers = null;
                        // Use post-frame callback to avoid calling setState during build
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (mounted) {
                            setState(() {});
                          }
                        });
                      }
                    },
                  ),
                  children: [
                    // OpenStreetMap tiles with caching
                    if (_cacheInitialized && _cacheStore != null)
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.saliena.app',
                        tileProvider: CachedTileProvider(
                          store: _cacheStore!,
                        ),
                      )
                    else
                      TileLayer(
                        urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.saliena.app',
                      ),
                    // Report markers (with clustering)
                    MarkerLayer(
                      markers: _buildClusteredMarkers(reports, theme),
                    ),
                    // Current location marker
                    if (_currentLocation != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            key: const ValueKey('current_location'),
                            point: _currentLocation!,
                            width: 24,
                            height: 24,
                            child: Container(
                              decoration: BoxDecoration(
                                color: SalienaColors.getNavy(context),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: SalienaColors.getNavy(context).withValues(alpha: 0.4),
                                    blurRadius: 8,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
                // Legend
                Positioned(
                  bottom: 40,
                  left: SalienaSpacing.md,
                  child: _buildLegend(theme),
                ),
                // Location button
                Positioned(
                  bottom: 40,
                  right: SalienaSpacing.md,
                  child: _buildLocationButton(),
                ),
                // Loading indicator
                if (_isLoadingLocation)
                  Positioned(
                    top: 20,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: SalienaSpacing.md,
                          vertical: SalienaSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: SalienaColors.getSurfaceColor(context),
                          borderRadius: BorderRadius.circular(SalienaRadius.lg),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: SalienaColors.getNavy(context),
                              ),
                            ),
                            const SizedBox(width: SalienaSpacing.sm),
                            Text(
                              AppLocalizations.of(context)!.gettingLocation,
                              style: TextStyle(
                                color: SalienaColors.getTextColor(context),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(SalienaSpacing.sm),
      decoration: BoxDecoration(
        color: SalienaColors.getTextFieldBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: SalienaColors.getTextColor(context).withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLegendItem(Colors.orange, AppLocalizations.of(context)!.statusPending),
          const SizedBox(height: 4),
          _buildLegendItem(Colors.blue, AppLocalizations.of(context)!.statusInProgress),
          const SizedBox(height: 4),
          _buildLegendItem(Colors.green, AppLocalizations.of(context)!.statusFixed),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            color: SalienaColors.getTextColor(context).withValues(alpha: 0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildLocationButton() {
    return Container(
      decoration: BoxDecoration(
        color: SalienaColors.getTextFieldBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: SalienaColors.getTextColor(context).withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(
          Icons.my_location,
          color: SalienaColors.getTextColor(context),
        ),
        onPressed: () {
          if (_currentLocation != null) {
            _mapController.move(_currentLocation!, 15);
          } else {
            _getCurrentLocation();
          }
        },
      ),
    );
  }

  void _showReportDetails(Report report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ReportDetailsSheet(report: report),
    );
  }

  void _showClusterSheet(_ReportCluster cluster) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _ClusterReportsSheet(
        reports: cluster.reports,
        onReportTap: (report) {
          Navigator.pop(context);
          _showReportDetails(report);
        },
      ),
    );
  }

  void _showFilterSheet() async {
    final result = await showModalBottomSheet<Set<ReportStatus>>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _FilterSheet(initialStatuses: _selectedStatuses),
    );
    
    if (result != null) {
      setState(() {
        _selectedStatuses = result;
        // Invalidate marker cache when filter changes
        _cachedMarkers = null;
        _cachedReports = null;
      });
      await _saveFilter(result);
    }
  }
}

class _ReportDetailsSheet extends StatelessWidget {
  final Report report;

  const _ReportDetailsSheet({required this.report});

  String _getLocalizedStatusLabel(BuildContext context, ReportStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case ReportStatus.pending:
        return l10n.statusPending;
      case ReportStatus.inProgress:
        return l10n.statusInProgress;
      case ReportStatus.fixed:
        return l10n.statusFixed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(SalienaSpacing.lg),
      decoration: BoxDecoration(
        color: SalienaColors.getSurfaceColor(context),
        borderRadius: SalienaRadius.radiusTopXl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SalienaColors.getTertiaryTextColor(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: SalienaSpacing.md),
          // Status badge
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SalienaSpacing.sm,
              vertical: SalienaSpacing.xs,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor(report.status).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(SalienaRadius.sm),
              border: Border.all(
                color: _getStatusColor(report.status),
                width: 1,
              ),
            ),
            child: Text(
              _getLocalizedStatusLabel(context, report.status),
              style: theme.textTheme.labelSmall?.copyWith(
                color: _getStatusColor(report.status),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: SalienaSpacing.sm),
          // Title
          Text(
            report.title,
            style: TextStyle(
              color: SalienaColors.getTextColor(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SalienaSpacing.xs),
          // Reporter name
          Text(
            NameFormatter.formatNameWithInitial(report.reporterName),
            style: TextStyle(
              color: SalienaColors.getTextColor(context).withValues(alpha: 0.7),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: SalienaSpacing.xs),
          // Location
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: SalienaColors.getIconColor(context),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  report.location.address ?? AppLocalizations.of(context)!.unknownLocation,
                  style: TextStyle(
                    color: SalienaColors.getSecondaryTextColor(context),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SalienaSpacing.md),
          // Description
          Text(
            report.description,
            style: TextStyle(
              color: SalienaColors.getTextColor(context),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: SalienaSpacing.md),
          // Date
          Text(
            AppLocalizations.of(context)!.reportedOn(_formatDate(context, report.createdAt)),
            style: TextStyle(
              color: SalienaColors.getTertiaryTextColor(context),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: SalienaSpacing.lg),
        ],
      ),
    );
  }

  Color _getStatusColor(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.inProgress:
        return Colors.blue;
      case ReportStatus.fixed:
        return Colors.green;
    }
  }

  String _formatDate(BuildContext context, DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return AppLocalizations.of(context)!.today;
    } else if (difference.inDays == 1) {
      return AppLocalizations.of(context)!.yesterday;
    } else if (difference.inDays < 7) {
      return AppLocalizations.of(context)!.daysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class _FilterSheet extends StatefulWidget {
  final Set<ReportStatus> initialStatuses;
  
  const _FilterSheet({required this.initialStatuses});

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<ReportStatus> _selectedStatuses;

  @override
  void initState() {
    super.initState();
    _selectedStatuses = Set.from(widget.initialStatuses);
  }

  String _getLocalizedStatusLabel(BuildContext context, ReportStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case ReportStatus.pending:
        return l10n.statusPending;
      case ReportStatus.inProgress:
        return l10n.statusInProgress;
      case ReportStatus.fixed:
        return l10n.statusFixed;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SalienaSpacing.lg),
      decoration: BoxDecoration(
        color: SalienaColors.getSurfaceColor(context),
        borderRadius: SalienaRadius.radiusTopXl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: SalienaColors.getTertiaryTextColor(context),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: SalienaSpacing.md),
          Text(
            AppLocalizations.of(context)!.filterReports,
            style: TextStyle(
              color: SalienaColors.getTextColor(context),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: SalienaSpacing.lg),
          // Status filters
          Wrap(
            spacing: SalienaSpacing.sm,
            children: ReportStatus.values.map((status) {
              final isSelected = _selectedStatuses.contains(status);
              return FilterChip(
                label: Text(
                  _getLocalizedStatusLabel(context, status),
                  style: TextStyle(
                    color: isSelected ? Colors.white : SalienaColors.navy,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedStatuses.add(status);
                    } else {
                      _selectedStatuses.remove(status);
                    }
                  });
                },
                selectedColor: SalienaColors.getNavy(context),
                backgroundColor: SalienaColors.getSurfaceColor(context),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? SalienaColors.navy : SalienaColors.navy.withValues(alpha: 0.3),
                  ),
                ),
                checkmarkColor: Colors.white,
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: SalienaSpacing.xl),
          // Apply button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _selectedStatuses);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SalienaColors.getNavy(context),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                elevation: 0,
              ),
              child: Text(
                AppLocalizations.of(context)!.applyFilters,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: SalienaSpacing.md),
        ],
      ),
    );
  }
}

// Cluster data class
class _ReportCluster {
  final LatLng center;
  final List<Report> reports;

  _ReportCluster({required this.center, required this.reports});
}

// Custom painter for split-color circle
class _SplitCirclePainter extends CustomPainter {
  final Color leftColor;
  final Color rightColor;

  _SplitCirclePainter({required this.leftColor, required this.rightColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Left half
    final leftPaint = Paint()..color = leftColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      0.5 * 3.14159, // 90 degrees
      3.14159, // 180 degrees
      true,
      leftPaint,
    );

    // Right half
    final rightPaint = Paint()..color = rightColor;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -0.5 * 3.14159, // -90 degrees
      3.14159, // 180 degrees
      true,
      rightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Bottom sheet for selecting a report from a cluster
class _ClusterReportsSheet extends StatelessWidget {
  final List<Report> reports;
  final Function(Report) onReportTap;

  const _ClusterReportsSheet({
    required this.reports,
    required this.onReportTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return ClipRRect(
      borderRadius: SalienaRadius.radiusTopXl,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface.withValues(alpha: 0.95),
            borderRadius: SalienaRadius.radiusTopXl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Padding(
                padding: const EdgeInsets.only(top: SalienaSpacing.md),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Title
              Padding(
                padding: const EdgeInsets.all(SalienaSpacing.md),
                child: Text(
                  '${reports.length} ${l10n.reports}',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              // Report list
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(
                    horizontal: SalienaSpacing.md,
                  ),
                  itemCount: reports.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final report = reports[index];
                    return _ClusterReportTile(
                      report: report,
                      onTap: () => onReportTap(report),
                    );
                  },
                ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + SalienaSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClusterReportTile extends StatelessWidget {
  final Report report;
  final VoidCallback onTap;

  const _ClusterReportTile({
    required this.report,
    required this.onTap,
  });

  Color _getStatusColor(ReportStatus status, ThemeData theme) {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;
      case ReportStatus.inProgress:
        return theme.colorScheme.primary;
      case ReportStatus.fixed:
        return Colors.green;
    }
  }

  String _getLocalizedStatusLabel(BuildContext context, ReportStatus status) {
    final l10n = AppLocalizations.of(context)!;
    switch (status) {
      case ReportStatus.pending:
        return l10n.statusPending;
      case ReportStatus.inProgress:
        return l10n.statusInProgress;
      case ReportStatus.fixed:
        return l10n.statusFixed;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SalienaSpacing.sm),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: _getStatusColor(report.status, theme),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: SalienaSpacing.sm),
            // Report info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    NameFormatter.formatNameWithInitial(report.reporterName),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getLocalizedStatusLabel(context, report.status),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: _getStatusColor(report.status, theme),
                    ),
                  ),
                ],
              ),
            ),
            // Arrow
            Icon(
              Icons.chevron_right,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
