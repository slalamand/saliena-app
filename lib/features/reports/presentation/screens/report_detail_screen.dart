import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:saliena_app/design_system/design_system.dart';
import 'package:saliena_app/features/auth/domain/entities/user.dart';
import 'package:saliena_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:saliena_app/features/reports/domain/entities/report.dart';
import 'package:saliena_app/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:saliena_app/core/utils/name_formatter.dart';
import 'package:saliena_app/l10n/app_localizations.dart';

class ReportDetailScreen extends StatefulWidget {
  final Report report;

  const ReportDetailScreen({super.key, required this.report});

  @override
  State<ReportDetailScreen> createState() => _ReportDetailScreenState();
}

class _ReportDetailScreenState extends State<ReportDetailScreen> {
  late Report _currentReport;

  @override
  void initState() {
    super.initState();
    _currentReport = widget.report;
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
    final l10n = AppLocalizations.of(context)!;

    if (difference.inDays == 0) {
      return l10n.today;
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: SalienaColors.getBackgroundBlue(context),
      appBar: AppBar(
        title: Text(
          l10n.reportDetails,
          style: TextStyle(
            color: SalienaColors.getTextColor(context),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: SalienaColors.getTextColor(context)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Section
            _buildMediaSection(context, theme, l10n),

            Padding(
              padding: const EdgeInsets.all(SalienaSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: SalienaSpacing.md,
                      vertical: SalienaSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(_currentReport.status).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _getStatusColor(_currentReport.status),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      _getLocalizedStatusLabel(context, _currentReport.status),
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: _getStatusColor(_currentReport.status),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: SalienaSpacing.md),

                  // Title
                  Text(
                    _currentReport.title,
                    style: TextStyle(
                      color: SalienaColors.getTextColor(context),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: SalienaSpacing.sm),

                  // Reporter name
                  Text(
                    NameFormatter.formatNameWithInitial(_currentReport.reporterName),
                    style: TextStyle(
                      color: SalienaColors.getTextColor(context).withValues(alpha: 0.7),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 4),

                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: SalienaColors.getTextColor(context).withValues(alpha: 0.6),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        l10n.reportedOn(_formatDate(context, _currentReport.createdAt)),
                        style: TextStyle(
                          color: SalienaColors.getTextColor(context).withValues(alpha: 0.6),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: SalienaSpacing.xl),

                  // Description
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(SalienaSpacing.md),
                    decoration: BoxDecoration(
                      color: SalienaColors.getTextFieldBackground(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.reportDescription,
                          style: TextStyle(
                            color: SalienaColors.getTextColor(context).withValues(alpha: 0.5),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: SalienaSpacing.sm),
                        Text(
                          _currentReport.description,
                          style: TextStyle(
                            color: SalienaColors.getTextColor(context),
                            fontSize: 16,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: SalienaSpacing.xl),

                  // Location Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(SalienaSpacing.md),
                    decoration: BoxDecoration(
                      color: SalienaColors.getTextFieldBackground(context),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              color: SalienaColors.getTextColor(context),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n.location,
                              style: TextStyle(
                                color: SalienaColors.getTextColor(context),
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        if (_currentReport.location.address != null) ...[
                          const SizedBox(height: SalienaSpacing.sm),
                          Text(
                            _currentReport.location.address!,
                            style: TextStyle(
                              color: SalienaColors.getTextColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ],
                        const SizedBox(height: SalienaSpacing.md),
                        // Mini Map
                        Container(
                          height: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: SalienaColors.getTextColor(context).withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                  _currentReport.location.latitude,
                                  _currentReport.location.longitude,
                                ),
                                initialZoom: 15,
                                interactionOptions: const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                  userAgentPackageName: 'com.saliena.app',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(
                                        _currentReport.location.latitude,
                                        _currentReport.location.longitude,
                                      ),
                                      width: 40,
                                      height: 40,
                                      child: Icon(
                                        Icons.location_pin,
                                        color: SalienaColors.getTextColor(context),
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: SalienaSpacing.xl),

                  // Reporter Info Section (for Workers/Admins only)
                  _buildReporterInfoSection(context, theme, l10n),

                  // Status Change Actions (for Workers/Admins)
                  _buildStatusActions(context, theme, l10n),

                  const SizedBox(height: SalienaSpacing.xxl),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReporterInfoSection(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    final userRole = authState.user.role;
    final isStaff = userRole == UserRole.worker || userRole == UserRole.officeAdmin;

    // Only show reporter info to staff members
    if (!isStaff) return const SizedBox.shrink();

    // Check if we have reporter info to display
    final hasReporterInfo = _currentReport.reporterName != null || _currentReport.reporterPhone != null;
    if (!hasReporterInfo) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reporterInfo,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SalienaSpacing.sm),
        Container(
          padding: const EdgeInsets.all(SalienaSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(SalienaRadius.md),
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 0.5,
            ),
          ),
          child: Column(
            children: [
              if (_currentReport.reporterName != null)
                _buildInfoRow(
                  theme: theme,
                  icon: Icons.person_outline,
                  label: l10n.reporterFullName,
                  value: _currentReport.reporterName!,
                ),
              if (_currentReport.reporterName != null && _currentReport.reporterPhone != null)
                const SizedBox(height: SalienaSpacing.sm),
              if (_currentReport.reporterPhone != null)
                _buildInfoRow(
                  theme: theme,
                  icon: Icons.phone_outlined,
                  label: l10n.reporterPhoneNumber,
                  value: _currentReport.reporterPhone!,
                ),
            ],
          ),
        ),
        const SizedBox(height: SalienaSpacing.xl),
      ],
    );
  }

  Widget _buildInfoRow({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: SalienaSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusActions(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) return const SizedBox.shrink();

    final userRole = authState.user.role;
    final canChangeStatus = userRole == UserRole.worker || userRole == UserRole.officeAdmin;

    if (!canChangeStatus) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.reportStatus,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: SalienaSpacing.sm),

        // Status change buttons
        if (_currentReport.status == ReportStatus.pending) ...[
          _buildStatusButton(
            context: context,
            theme: theme,
            icon: Icons.play_arrow_rounded,
            label: l10n.markAsInProgress,
            color: theme.colorScheme.primary,
            onTap: () => _updateStatus(context, ReportStatus.inProgress),
          ),
          const SizedBox(height: SalienaSpacing.sm),
        ],

        if (_currentReport.status != ReportStatus.fixed) ...[
          _buildStatusButton(
            context: context,
            theme: theme,
            icon: Icons.check_circle_rounded,
            label: l10n.markAsFixed,
            color: Colors.green,
            onTap: () => _updateStatus(context, ReportStatus.fixed),
          ),
          const SizedBox(height: SalienaSpacing.sm),
        ],

        // Allow changing from Fixed back to In Progress
        if (_currentReport.status == ReportStatus.fixed) ...[
          _buildStatusButton(
            context: context,
            theme: theme,
            icon: Icons.replay_rounded,
            label: l10n.markAsInProgress,
            color: theme.colorScheme.primary,
            onTap: () => _updateStatus(context, ReportStatus.inProgress),
          ),
          const SizedBox(height: SalienaSpacing.sm),
        ],

        // Delete report button
        _buildStatusButton(
          context: context,
          theme: theme,
          icon: Icons.delete_outline,
          label: l10n.deleteReport,
          color: theme.colorScheme.error,
          onTap: () => _showDeleteConfirmation(context, l10n),
        ),
      ],
    );
  }

  Widget _buildStatusButton({
    required BuildContext context,
    required ThemeData theme,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(SalienaRadius.md),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: SalienaSpacing.md,
            vertical: SalienaSpacing.md,
          ),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(SalienaRadius.md),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: SalienaSpacing.sm),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: color.withValues(alpha: 0.5),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateStatus(BuildContext context, ReportStatus newStatus) {
    context.read<ReportsBloc>().add(ReportStatusUpdateRequested(
      reportId: _currentReport.id,
      status: newStatus,
    ));

    // Update local state to reflect the change immediately
    setState(() {
      _currentReport = _currentReport.copyWith(
        status: newStatus,
        fixedAt: newStatus == ReportStatus.fixed ? DateTime.now() : null,
      );
    });

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          newStatus == ReportStatus.fixed
              ? AppLocalizations.of(context)!.statusFixed
              : AppLocalizations.of(context)!.statusInProgress,
        ),
        backgroundColor: newStatus == ReportStatus.fixed ? Colors.green : Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteReport),
        content: Text(l10n.deleteReportConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deleteReport(context, l10n);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );
  }

  void _deleteReport(BuildContext context, AppLocalizations l10n) {
    context.read<ReportsBloc>().add(ReportDeleteRequested(
      reportId: _currentReport.id,
    ));

    // Show confirmation and navigate back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.reportDeleted),
        backgroundColor: Theme.of(context).colorScheme.primary,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.of(context).pop();
  }

  Widget _buildMediaSection(BuildContext context, ThemeData theme, AppLocalizations l10n) {
    final hasPhotos = _currentReport.photoUrls.isNotEmpty;

    if (!hasPhotos) {
      // No media uploaded
      return Container(
        height: 200,
        width: double.infinity,
        color: theme.colorScheme.surfaceContainerHighest,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_not_supported_outlined,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
            const SizedBox(height: SalienaSpacing.sm),
            Text(
              l10n.noMediaUploaded,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    // Has photos - show image gallery
    if (_currentReport.photoUrls.length == 1) {
      // Single image
      return AspectRatio(
        aspectRatio: 16 / 9,
        child: Image.network(
          _currentReport.photoUrls.first,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              color: theme.colorScheme.surfaceContainerHighest,
              child: const Center(child: CircularProgressIndicator()),
            );
          },
          errorBuilder: (context, error, stackTrace) => Container(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.broken_image,
              size: 48,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ),
      );
    }

    // Multiple images - horizontal scroll
    return SizedBox(
      height: 250,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: SalienaSpacing.lg),
        itemCount: _currentReport.photoUrls.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              right: index < _currentReport.photoUrls.length - 1 ? SalienaSpacing.sm : 0,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SalienaRadius.md),
              child: Image.network(
                _currentReport.photoUrls[index],
                width: 300,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    width: 300,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                },
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 300,
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: Icon(
                    Icons.broken_image,
                    size: 48,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
