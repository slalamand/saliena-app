import 'dart:async';
import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:saliena_app/core/error/failures.dart';
import 'package:saliena_app/features/reports/domain/entities/report.dart';
import 'package:saliena_app/features/reports/domain/repositories/report_repository.dart';

part 'reports_event.dart';
part 'reports_state.dart';

/// BLoC for managing reports state.
class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final ReportRepository _reportRepository;
  StreamSubscription<List<Report>>? _reportsSubscription;

  ReportsBloc({
    required ReportRepository reportRepository,
  })  : _reportRepository = reportRepository,
        super(const ReportsInitial()) {
    on<ReportsLoadRequested>(_onLoadRequested);
    on<ReportsLoadMoreRequested>(_onLoadMoreRequested);
    on<ReportsRefreshRequested>(_onRefreshRequested);
    on<ReportCreateRequested>(_onCreateRequested);
    on<ReportStatusUpdateRequested>(_onStatusUpdateRequested);
    on<ReportDeleteRequested>(_onDeleteRequested);
    on<ReportsInBoundsRequested>(_onInBoundsRequested);
    on<ReportsUpdated>(_onReportsUpdated);
  }

  Future<void> _onLoadRequested(
    ReportsLoadRequested event,
    Emitter<ReportsState> emit,
  ) async {
    emit(const ReportsLoading());

    final result = await _reportRepository.getReports(
      filter: event.filter,
      page: 1,
    );

    result.fold(
      onSuccess: (reports) {
        emit(ReportsLoaded(
          reports: reports,
          hasMore: reports.length >= 20,
          currentPage: 1,
          filter: event.filter,
        ));

        // Start watching for real-time updates
        _startWatchingReports(event.filter);
      },
      onFailure: (failure) {
        emit(ReportsError(failure: failure));
      },
    );
  }

  Future<void> _onLoadMoreRequested(
    ReportsLoadMoreRequested event,
    Emitter<ReportsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReportsLoaded || !currentState.hasMore) return;

    emit(currentState.copyWith(isLoadingMore: true));

    final result = await _reportRepository.getReports(
      filter: currentState.filter,
      page: currentState.currentPage + 1,
    );

    result.fold(
      onSuccess: (newReports) {
        emit(currentState.copyWith(
          reports: [...currentState.reports, ...newReports],
          hasMore: newReports.length >= 20,
          currentPage: currentState.currentPage + 1,
          isLoadingMore: false,
        ));
      },
      onFailure: (failure) {
        emit(currentState.copyWith(isLoadingMore: false));
      },
    );
  }

  Future<void> _onRefreshRequested(
    ReportsRefreshRequested event,
    Emitter<ReportsState> emit,
  ) async {
    final currentState = state;
    final filter = currentState is ReportsLoaded ? currentState.filter : null;

    final result = await _reportRepository.getReports(
      filter: filter,
      page: 1,
    );

    result.fold(
      onSuccess: (reports) {
        emit(ReportsLoaded(
          reports: reports,
          hasMore: reports.length >= 20,
          currentPage: 1,
          filter: filter,
        ));
      },
      onFailure: (failure) {
        emit(ReportsError(failure: failure));
      },
    );
  }

  Future<void> _onCreateRequested(
    ReportCreateRequested event,
    Emitter<ReportsState> emit,
  ) async {
    final currentState = state;

    emit(const ReportCreating());

    final result = await _reportRepository.createReport(
      CreateReportInput(
        title: event.title,
        description: event.description,
        photoBytesList: event.photoBytesList,
        photoFileNames: event.photoFileNames,
        videoBytes: event.videoBytes,
        videoFileName: event.videoFileName,
        latitude: event.latitude,
        longitude: event.longitude,
        address: event.address,
      ),
    );

    result.fold(
      onSuccess: (report) {
        emit(ReportCreated(report: report));

        // Refresh the list
        if (currentState is ReportsLoaded) {
          emit(ReportsLoaded(
            reports: [report, ...currentState.reports],
            hasMore: currentState.hasMore,
            currentPage: currentState.currentPage,
            filter: currentState.filter,
          ));
        }
      },
      onFailure: (failure) {
        emit(ReportCreateError(failure: failure));
        // Restore previous state
        if (currentState is ReportsLoaded) {
          emit(currentState);
        }
      },
    );
  }

  Future<void> _onStatusUpdateRequested(
    ReportStatusUpdateRequested event,
    Emitter<ReportsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReportsLoaded) return;

    final result = await _reportRepository.updateReportStatus(
      reportId: event.reportId,
      status: event.status,
    );

    result.fold(
      onSuccess: (updatedReport) {
        final updatedReports = currentState.reports.map((r) {
          return r.id == updatedReport.id ? updatedReport : r;
        }).toList();

        emit(currentState.copyWith(reports: updatedReports));
      },
      onFailure: (failure) {
        emit(ReportsError(failure: failure));
        emit(currentState);
      },
    );
  }

  Future<void> _onDeleteRequested(
    ReportDeleteRequested event,
    Emitter<ReportsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! ReportsLoaded) return;

    final result = await _reportRepository.deleteReport(event.reportId);

    result.fold(
      onSuccess: (_) {
        final updatedReports = currentState.reports
            .where((r) => r.id != event.reportId)
            .toList();

        emit(currentState.copyWith(reports: updatedReports));
      },
      onFailure: (failure) {
        emit(ReportsError(failure: failure));
        emit(currentState);
      },
    );
  }

  Future<void> _onInBoundsRequested(
    ReportsInBoundsRequested event,
    Emitter<ReportsState> emit,
  ) async {
    final result = await _reportRepository.getReportsInBounds(
      northLat: event.northLat,
      southLat: event.southLat,
      eastLng: event.eastLng,
      westLng: event.westLng,
    );

    result.fold(
      onSuccess: (reports) {
        emit(ReportsLoaded(
          reports: reports,
          hasMore: false,
          currentPage: 1,
          isMapView: true,
        ));
      },
      onFailure: (failure) {
        emit(ReportsError(failure: failure));
      },
    );
  }

  void _onReportsUpdated(
    ReportsUpdated event,
    Emitter<ReportsState> emit,
  ) {
    final currentState = state;
    if (currentState is ReportsLoaded) {
      emit(currentState.copyWith(reports: event.reports));
    } else {
      emit(ReportsLoaded(
        reports: event.reports,
        hasMore: false,
        currentPage: 1,
      ));
    }
  }

  void _startWatchingReports(ReportFilter? filter) {
    _reportsSubscription?.cancel();
    _reportsSubscription = _reportRepository
        .watchReports(filter: filter)
        .listen((reports) {
      add(ReportsUpdated(reports: reports));
    });
  }

  @override
  Future<void> close() {
    _reportsSubscription?.cancel();
    return super.close();
  }
}
