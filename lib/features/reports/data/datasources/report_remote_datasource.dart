import 'dart:typed_data';

import 'package:saliena_app/features/reports/data/models/report_model.dart';
import 'package:saliena_app/features/reports/domain/entities/report.dart';

/// Abstract interface for remote report data source.
abstract class ReportRemoteDataSource {
  Future<ReportModel> createReport({
    required String title,
    required String description,
    required List<Uint8List> photoBytesList,
    required List<String> photoFileNames,
    Uint8List? videoBytes,
    String? videoFileName,
    required double latitude,
    required double longitude,
    String? address,
  });

  Future<ReportModel> getReport(String id);

  Future<List<ReportModel>> getReports({
    ReportStatus? status,
    String? userId,
    int page = 1,
    int pageSize = 20,
  });

  Future<List<ReportModel>> getReportsInBounds({
    required double northLat,
    required double southLat,
    required double eastLng,
    required double westLng,
  });

  Future<ReportModel> updateReportStatus({
    required String reportId,
    required ReportStatus status,
  });

  Future<void> deleteReport(String reportId);

  Stream<List<ReportModel>> watchReports({ReportStatus? status});

  Stream<ReportModel> watchReport(String id);
}
