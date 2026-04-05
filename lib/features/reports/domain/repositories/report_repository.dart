import 'dart:typed_data';

import 'package:saliena_app/core/utils/result.dart';
import 'package:saliena_app/features/reports/domain/entities/report.dart';

/// Input data for creating a new report.
class CreateReportInput {
  final String title;
  final String description;
  final List<Uint8List> photoBytesList;
  final List<String> photoFileNames;
  final Uint8List? videoBytes;
  final String? videoFileName;
  final double latitude;
  final double longitude;
  final String? address;

  const CreateReportInput({
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
}

/// Filter options for fetching reports.
class ReportFilter {
  final ReportStatus? status;
  final String? userId;
  final double? nearLatitude;
  final double? nearLongitude;
  final double? radiusKm;
  final DateTime? fromDate;
  final DateTime? toDate;

  const ReportFilter({
    this.status,
    this.userId,
    this.nearLatitude,
    this.nearLongitude,
    this.radiusKm,
    this.fromDate,
    this.toDate,
  });
}

/// Abstract repository interface for reports.
/// This interface defines the contract that any reports backend must implement.
abstract class ReportRepository {
  /// Creates a new report with photo upload.
  Future<Result<Report>> createReport(CreateReportInput input);

  /// Gets a single report by ID.
  Future<Result<Report>> getReport(String id);

  /// Gets a list of reports with optional filtering.
  Future<Result<List<Report>>> getReports({
    ReportFilter? filter,
    int page = 1,
    int pageSize = 20,
  });

  /// Gets reports within a geographic bounding box (for map view).
  Future<Result<List<Report>>> getReportsInBounds({
    required double northLat,
    required double southLat,
    required double eastLng,
    required double westLng,
  });

  /// Updates the status of a report (workers/staff only).
  Future<Result<Report>> updateReportStatus({
    required String reportId,
    required ReportStatus status,
  });

  /// Marks a report as fixed (workers/staff only).
  Future<Result<Report>> markAsFixed(String reportId);

  /// Deletes a report (admin only or own report).
  Future<Result<void>> deleteReport(String reportId);

  /// Stream of real-time report updates.
  Stream<List<Report>> watchReports({ReportFilter? filter});

  /// Stream of a single report's updates.
  Stream<Report> watchReport(String id);
}
