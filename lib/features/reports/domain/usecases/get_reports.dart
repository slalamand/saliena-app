import 'package:saliena_app/core/usecase/usecase.dart';
import 'package:saliena_app/core/utils/result.dart';
import 'package:saliena_app/features/reports/domain/entities/report.dart';
import 'package:saliena_app/features/reports/domain/repositories/report_repository.dart';

/// Use case for getting a list of reports.
class GetReports implements UseCase<List<Report>, GetReportsParams> {
  final ReportRepository _repository;

  GetReports(this._repository);

  @override
  Future<Result<List<Report>>> call(GetReportsParams params) {
    return _repository.getReports(
      filter: params.filter,
      page: params.page,
      pageSize: params.pageSize,
    );
  }
}

/// Parameters for the GetReports use case.
class GetReportsParams {
  final ReportFilter? filter;
  final int page;
  final int pageSize;

  const GetReportsParams({
    this.filter,
    this.page = 1,
    this.pageSize = 20,
  });
}

/// Use case for getting reports within map bounds.
class GetReportsInBounds implements UseCase<List<Report>, GetReportsInBoundsParams> {
  final ReportRepository _repository;

  GetReportsInBounds(this._repository);

  @override
  Future<Result<List<Report>>> call(GetReportsInBoundsParams params) {
    return _repository.getReportsInBounds(
      northLat: params.northLat,
      southLat: params.southLat,
      eastLng: params.eastLng,
      westLng: params.westLng,
    );
  }
}

/// Parameters for the GetReportsInBounds use case.
class GetReportsInBoundsParams {
  final double northLat;
  final double southLat;
  final double eastLng;
  final double westLng;

  const GetReportsInBoundsParams({
    required this.northLat,
    required this.southLat,
    required this.eastLng,
    required this.westLng,
  });
}
