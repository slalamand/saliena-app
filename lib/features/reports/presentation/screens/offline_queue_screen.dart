import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:saliena_app/core/services/offline_queue_service.dart';
import 'package:saliena_app/core/network/network_info.dart';
import 'package:saliena_app/design_system/design_system.dart';
import 'package:saliena_app/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:saliena_app/injection.dart';
import 'package:saliena_app/l10n/app_localizations.dart';
import 'package:saliena_app/routing/routes.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

class OfflineQueueScreen extends StatefulWidget {
  const OfflineQueueScreen({super.key});

  @override
  State<OfflineQueueScreen> createState() => _OfflineQueueScreenState();
}

class _OfflineQueueScreenState extends State<OfflineQueueScreen> {
  late OfflineQueueService _offlineQueue;
  late NetworkInfo _networkInfo;
  List<QueuedReport> _queuedReports = [];
  bool _isOnline = false;
  bool _isRetrying = false;
  String? _retryingId;

  @override
  void initState() {
    super.initState();
    _offlineQueue = getIt<OfflineQueueService>();
    _networkInfo = getIt<NetworkInfo>();
    _loadQueue();
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    final connected = await _networkInfo.isConnected;
    setState(() {
      _isOnline = connected;
    });

    // Listen to connectivity changes
    _networkInfo.onStatusChange.listen((status) {
      if (mounted) {
        setState(() {
          _isOnline = status == InternetStatus.connected;
        });
        
        // Auto-retry when connection restored
        if (_isOnline && _queuedReports.isNotEmpty && !_isRetrying) {
          _retryAll();
        }
      }
    });
  }

  void _loadQueue() {
    setState(() {
      _queuedReports = _offlineQueue.getQueuedReports();
    });
  }

  Future<void> _retryReport(QueuedReport report) async {
    final l10n = AppLocalizations.of(context)!;
    
    if (!_isOnline) {
      _showError(l10n.noInternetConnection);
      return;
    }

    setState(() {
      _isRetrying = true;
      _retryingId = report.id;
    });

    try {
      final reportData = _offlineQueue.getReportData(report.id);
      if (reportData == null) {
        _showError(l10n.reportDataNotFound);
        return;
      }

      if (!mounted) return;

      // Submit the report
      context.read<ReportsBloc>().add(
        ReportCreateRequested(
          title: reportData['title'] as String,
          description: reportData['description'] as String,
          photoBytesList: (reportData['photoBytesList'] as List).cast<Uint8List>(),
          photoFileNames: (reportData['photoFileNames'] as List).cast<String>(),
          videoBytes: reportData['videoBytes'] as Uint8List?,
          videoFileName: reportData['videoFileName'] as String?,
          latitude: reportData['latitude'] as double,
          longitude: reportData['longitude'] as double,
          address: reportData['address'] as String?,
        ),
      );

      // Wait for result
      await Future.delayed(const Duration(seconds: 2));

      // Remove from queue on success
      await _offlineQueue.removeReport(report.id);
      _loadQueue();
      
      if (mounted) {
        _showSuccess('✅ Report uploaded successfully');
      }
    } catch (e) {
      await _offlineQueue.incrementRetryCount(report.id);
      _loadQueue();
      
      if (mounted) {
        _showError('Failed to upload: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isRetrying = false;
          _retryingId = null;
        });
      }
    }
  }

  Future<void> _retryAll() async {
    final l10n = AppLocalizations.of(context)!;
    
    if (!_isOnline) {
      _showError(l10n.noInternetConnection);
      return;
    }

    setState(() {
      _isRetrying = true;
    });

    for (final report in _queuedReports) {
      if (!_isOnline) break;
      await _retryReport(report);
      await Future.delayed(const Duration(milliseconds: 500));
    }

    setState(() {
      _isRetrying = false;
    });

    if (_queuedReports.isEmpty && mounted) {
      _showSuccess('✅ All reports uploaded!');
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        context.go(Routes.myReports);
      }
    }
  }

  Future<void> _deleteReport(QueuedReport report) async {
    final l10n = AppLocalizations.of(context)!;
    
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteReport),
        content: Text(l10n.deleteReportFromQueue(report.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n.delete),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _offlineQueue.removeReport(report.id);
      _loadQueue();
      if (mounted) {
        _showSuccess('Report removed from queue');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: SalienaColors.iconGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: SalienaColors.getBackgroundBlue(context),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => context.pop(),
                    color: SalienaColors.getTextColor(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Offline Queue',
                      style: TextStyle(
                        color: SalienaColors.getTextColor(context),
                        fontSize: 28,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Connection status banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: _isOnline 
                    ? SalienaColors.iconGreen.withValues(alpha: 0.1)
                    : Colors.orange.shade100,
                border: Border(
                  bottom: BorderSide(
                    color: _isOnline 
                        ? SalienaColors.iconGreen.withValues(alpha: 0.3)
                        : Colors.orange.shade300,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _isOnline ? Icons.cloud_done : Icons.cloud_off,
                    color: _isOnline ? SalienaColors.iconGreen : Colors.orange.shade900,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isOnline 
                          ? '✅ Online - Ready to upload'
                          : '📤 Offline - Reports will upload when connected',
                      style: TextStyle(
                        color: _isOnline ? SalienaColors.iconGreen : Colors.orange.shade900,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Queue count
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_queuedReports.length} report${_queuedReports.length != 1 ? 's' : ''} queued',
                    style: TextStyle(
                      color: SalienaColors.getTextColor(context),
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (_queuedReports.isNotEmpty && _isOnline && !_isRetrying)
                    TextButton.icon(
                      onPressed: _retryAll,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry All'),
                      style: TextButton.styleFrom(
                        foregroundColor: SalienaColors.accentBlue,
                      ),
                    ),
                ],
              ),
            ),

            // Queue list
            Expanded(
              child: _queuedReports.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 64,
                            color: SalienaColors.getHintColor(context),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No queued reports',
                            style: TextStyle(
                              color: SalienaColors.getHintColor(context),
                              fontSize: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Reports will appear here when offline',
                            style: TextStyle(
                              color: SalienaColors.getHintColor(context),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      itemCount: _queuedReports.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final report = _queuedReports[index];
                        final isRetrying = _retryingId == report.id;
                        
                        return _buildQueuedReportCard(report, isRetrying);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueuedReportCard(QueuedReport report, bool isRetrying) {
    return Container(
      decoration: BoxDecoration(
        color: SalienaColors.getTextFieldBackground(context),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: SalienaColors.getBorderColor(context),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              report.title,
              style: TextStyle(
                color: SalienaColors.getTextColor(context),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            
            // Description
            Text(
              report.description,
              style: TextStyle(
                color: SalienaColors.getSecondaryTextColor(context),
                fontSize: 14,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            
            // Media info
            Row(
              children: [
                Icon(
                  Icons.photo_library,
                  size: 16,
                  color: SalienaColors.getHintColor(context),
                ),
                const SizedBox(width: 4),
                Text(
                  report.mediaDescription,
                  style: TextStyle(
                    color: SalienaColors.getHintColor(context),
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 16),
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: SalienaColors.getHintColor(context),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimestamp(report.timestamp),
                  style: TextStyle(
                    color: SalienaColors.getHintColor(context),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            
            // Retry count
            if (report.retryCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                '⚠️ Retry attempts: ${report.retryCount}',
                style: TextStyle(
                  color: Colors.orange.shade700,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: isRetrying ? null : () => _deleteReport(report),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                if (_isOnline)
                  ElevatedButton.icon(
                    onPressed: isRetrying ? null : () => _retryReport(report),
                    icon: isRetrying
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Icon(Icons.upload, size: 18),
                    label: Text(isRetrying ? 'Uploading...' : 'Upload'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: SalienaColors.accentBlue,
                      foregroundColor: Colors.white,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}
