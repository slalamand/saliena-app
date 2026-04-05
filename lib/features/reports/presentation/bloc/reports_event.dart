part of 'reports_bloc.dart';

/// Base class for all reports events.
sealed class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

/// Load reports with optional filter.
class ReportsLoadRequested extends ReportsEvent {
  final ReportFilter? filter;

  const ReportsLoadRequested({this.filter});

  @override
  List<Object?> get props => [filter];
}

/// Load more reports (pagination).
class ReportsLoadMoreRequested extends ReportsEvent {
  const ReportsLoadMoreRequested();
}

/// Refresh reports list.
class ReportsRefreshRequested extends ReportsEvent {
  const ReportsRefreshRequested();
}

/// Create a new report.
class ReportCreateRequested extends ReportsEvent {
  final String title;
  final String description;
  final List<Uint8List> photoBytesList;
  final List<String> photoFileNames;
  final Uint8List? videoBytes;
  final String? videoFileName;
  final double latitude;
  final double longitude;
  final String? address;

  const ReportCreateRequested({
    required this.title,
    required this.description,
    required this.photoBytesList,
    required this.photoFileNames,
    this.videoBytes,
    this.videoFileName,
    required this.latitude,
    required this.longitude,
    this.address,
  });

  @override
  List<Object?> get props => [
        title,
        description,
        photoBytesList,
        photoFileNames,
        videoBytes,
        videoFileName,
        latitude,
        longitude,
        address,
      ];
}

/// Update report status (workers/staff only).
class ReportStatusUpdateRequested extends ReportsEvent {
  final String reportId;
  final ReportStatus status;

  const ReportStatusUpdateRequested({
    required this.reportId,
    required this.status,
  });

  @override
  List<Object?> get props => [reportId, status];
}

/// Load reports within map bounds.
class ReportsInBoundsRequested extends ReportsEvent {
  final double northLat;
  final double southLat;
  final double eastLng;
  final double westLng;

  const ReportsInBoundsRequested({
    required this.northLat,
    required this.southLat,
    required this.eastLng,
    required this.westLng,
  });

  @override
  List<Object?> get props => [northLat, southLat, eastLng, westLng];
}

/// Reports updated from real-time subscription.
class ReportsUpdated extends ReportsEvent {
  final List<Report> reports;

  const ReportsUpdated({required this.reports});

  @override
  List<Object?> get props => [reports];
}

/// Delete a report (workers/staff only).
class ReportDeleteRequested extends ReportsEvent {
  final String reportId;

  const ReportDeleteRequested({required this.reportId});

  @override
  List<Object?> get props => [reportId];
}
