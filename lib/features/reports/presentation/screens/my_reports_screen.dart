import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:saliena_app/design_system/design_system.dart';
import 'package:saliena_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:saliena_app/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:saliena_app/features/reports/domain/entities/report.dart';
import 'package:saliena_app/l10n/app_localizations.dart';
import 'package:saliena_app/routing/routes.dart';
import 'package:saliena_app/core/services/offline_queue_service.dart';
import 'package:saliena_app/core/utils/name_formatter.dart';
import 'package:saliena_app/injection.dart';

class MyReportsScreen extends StatefulWidget {
  const MyReportsScreen({super.key});

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  int _queuedCount = 0;

  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<ReportsBloc>().add(const ReportsLoadRequested());
    }
    _checkQueuedReports();
  }

  void _checkQueuedReports() {
    final offlineQueue = getIt<OfflineQueueService>();
    setState(() {
      _queuedCount = offlineQueue.queuedCount;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: SalienaColors.getBackgroundBlue(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: _buildHeader(context, l10n),
                  ),
                  
                  // Offline queue banner
                  if (_queuedCount > 0)
                    GestureDetector(
                      onTap: () {
                        context.push(Routes.offlineQueue);
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.orange.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.cloud_upload, color: Colors.orange.shade900, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$_queuedCount report${_queuedCount > 1 ? 's' : ''} queued for upload',
                                    style: TextStyle(
                                      color: Colors.orange.shade900,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    l10n.tapToViewAndRetry,
                                    style: TextStyle(
                                      color: Colors.orange.shade700,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(Icons.arrow_forward_ios, color: Colors.orange.shade900, size: 16),
                          ],
                        ),
                      ),
                    ),
                  
                  Expanded(
                    child: BlocBuilder<ReportsBloc, ReportsState>(
                      builder: (context, state) {
                        if (state is ReportsLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }

                        if (state is ReportsError) {
                          return Center(child: Text(state.failure.message));
                        }

                        if (state is ReportsLoaded) {
                          final visibleReports = state.reports;

                          if (visibleReports.isEmpty) {
                            return Center(child: Text(l10n.noReports));
                          }

                          return RefreshIndicator(
                            onRefresh: () async {
                              context.read<ReportsBloc>().add(const ReportsRefreshRequested());
                            },
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: 24.0),
                              itemCount: visibleReports.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _buildReportCard(context, visibleReports[index]);
                              },
                            ),
                          );
                        }

                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: SalienaSecondaryButton(
                      text: l10n.viewOnMap,
                      onPressed: () => context.push(Routes.map),
                    ),
                  ),
                ],
              ),
            ),
            SalienaBottomNav(currentIndex: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 120,
          height: 80,
          child: SalienaLogo(
            withText: false,
            scale: 1.6,
            isDarkBackground: Theme.of(context).brightness == Brightness.dark,
          ),
        ),
        Text(
          l10n.issues,
          style: TextStyle(
            color: SalienaColors.getTextColor(context),
            fontSize: 28,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildReportCard(BuildContext context, Report report) {
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      decoration: BoxDecoration(
        color: SalienaColors.getTextFieldBackground(context),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('${Routes.reportDetail}/${report.id}', extra: report),
          borderRadius: BorderRadius.circular(4),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Reporter name
                Text(
                  NameFormatter.formatNameWithInitial(report.reporterName),
                  style: TextStyle(
                    color: SalienaColors.getTextFieldHint(context).withValues(alpha: 0.8),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                // Report title
                Text(
                  report.title.isNotEmpty ? report.title : l10n.reportIssue,
                  style: TextStyle(
                    color: SalienaColors.getTextFieldHint(context),
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
