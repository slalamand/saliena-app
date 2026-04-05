import 'package:saliena_app/core/usecase/usecase.dart';
import 'package:saliena_app/core/utils/result.dart';
import 'package:saliena_app/features/reports/domain/entities/report.dart';
import 'package:saliena_app/features/reports/domain/repositories/report_repository.dart';

/// Use case for updating a report's status (workers/staff only).
class UpdateReportStatus implements UseCase<Report, UpdateReportStatusParams> {
  final ReportRepository _repository;

  UpdateReportStatus(this._repository);

  @override
  Future<Result<Report>> call(UpdateReportStatusParams params) {
    return _repository.updateReportStatus(
      reportId: params.reportId,
      status: params.status,
    );
  }
}

/// Parameters for the UpdateReportStatus use case.
class UpdateReportStatusParams {
  final String reportId;
  final ReportStatus status;

  const UpdateReportStatusParams({
    required this.reportId,
    required this.status,
  });
}

/// Use case for marking a report as fixed.
class MarkReportAsFixed implements UseCase<Report, String> {
  final ReportRepository _repository;

  MarkReportAsFixed(this._repository);

  @override
  Future<Result<Report>> call(String reportId) {
    return _repository.markAsFixed(reportId);
  }
}
