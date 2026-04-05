part of 'reports_bloc.dart';

/// Base class for all reports states.
sealed class ReportsState extends Equatable {
  const ReportsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any reports are loaded.
class ReportsInitial extends ReportsState {
  const ReportsInitial();
}

/// Loading state while fetching reports.
class ReportsLoading extends ReportsState {
  const ReportsLoading();
}

/// Reports loaded successfully.
class ReportsLoaded extends ReportsState {
  final List<Report> reports;
  final bool hasMore;
  final int currentPage;
  final ReportFilter? filter;
  final bool isLoadingMore;
  final bool isMapView;

  const ReportsLoaded({
    required this.reports,
    required this.hasMore,
    required this.currentPage,
    this.filter,
    this.isLoadingMore = false,
    this.isMapView = false,
  });

  ReportsLoaded copyWith({
    List<Report>? reports,
    bool? hasMore,
    int? currentPage,
    ReportFilter? filter,
    bool? isLoadingMore,
    bool? isMapView,
  }) {
    return ReportsLoaded(
      reports: reports ?? this.reports,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
      filter: filter ?? this.filter,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isMapView: isMapView ?? this.isMapView,
    );
  }

  @override
  List<Object?> get props => [
        reports,
        hasMore,
        currentPage,
        filter,
        isLoadingMore,
        isMapView,
      ];
}

/// Error state when loading reports fails.
class ReportsError extends ReportsState {
  final Failure failure;

  const ReportsError({required this.failure});

  @override
  List<Object?> get props => [failure];
}

/// Creating a new report.
class ReportCreating extends ReportsState {
  const ReportCreating();
}

/// Report created successfully.
class ReportCreated extends ReportsState {
  final Report report;

  const ReportCreated({required this.report});

  @override
  List<Object?> get props => [report];
}

/// Error creating a report.
class ReportCreateError extends ReportsState {
  final Failure failure;

  const ReportCreateError({required this.failure});

  @override
  List<Object?> get props => [failure];
}
