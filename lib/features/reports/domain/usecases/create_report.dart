import 'package:saliena_app/core/usecase/usecase.dart';
import 'package:saliena_app/core/utils/result.dart';
import 'package:saliena_app/features/reports/domain/entities/report.dart';
import 'package:saliena_app/features/reports/domain/repositories/report_repository.dart';

/// Use case for creating a new report.
class CreateReport implements UseCase<Report, CreateReportInput> {
  final ReportRepository _repository;

  CreateReport(this._repository);

  @override
  Future<Result<Report>> call(CreateReportInput params) {
    return _repository.createReport(params);
  }
}
