import 'package:saliena_app/core/error/exceptions.dart' as exceptions;
import 'package:saliena_app/core/error/failures.dart';
import 'package:saliena_app/core/network/network_info.dart';
import 'package:saliena_app/core/utils/result.dart';
import 'package:saliena_app/features/reports/data/datasources/report_remote_datasource.dart';
import 'package:saliena_app/features/reports/domain/entities/report.dart';
import 'package:saliena_app/features/reports/domain/repositories/report_repository.dart';

/// Implementation of ReportRepository.
class ReportRepositoryImpl implements ReportRepository {
  final ReportRemoteDataSource _remoteDataSource;
  final NetworkInfo _networkInfo;

  ReportRepositoryImpl({
    required ReportRemoteDataSource remoteDataSource,
    required NetworkInfo networkInfo,
  })  : _remoteDataSource = remoteDataSource,
        _networkInfo = networkInfo;

  @override
  Future<Result<Report>> createReport(CreateReportInput input) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }

    try {
      final report = await _remoteDataSource.createReport(
        title: input.title,
        description: input.description,
        photoBytesList: input.photoBytesList,
        photoFileNames: input.photoFileNames,
        videoBytes: input.videoBytes,
        videoFileName: input.videoFileName,
        latitude: input.latitude,
        longitude: input.longitude,
        address: input.address,
      );
      return Result.success(report);
    } on exceptions.AppAuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message, code: e.code));
    } on exceptions.ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Result<Report>> getReport(String id) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }

    try {
      final report = await _remoteDataSource.getReport(id);
      return Result.success(report);
    } on exceptions.NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(message: e.message));
    } on exceptions.ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Result<List<Report>>> getReports({
    ReportFilter? filter,
    int page = 1,
    int pageSize = 20,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }

    try {
      final reports = await _remoteDataSource.getReports(
        status: filter?.status,
        userId: filter?.userId,
        page: page,
        pageSize: pageSize,
      );
      return Result.success(reports);
    } on exceptions.ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Result<List<Report>>> getReportsInBounds({
    required double northLat,
    required double southLat,
    required double eastLng,
    required double westLng,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }

    try {
      final reports = await _remoteDataSource.getReportsInBounds(
        northLat: northLat,
        southLat: southLat,
        eastLng: eastLng,
        westLng: westLng,
      );
      return Result.success(reports);
    } on exceptions.ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Result<Report>> updateReportStatus({
    required String reportId,
    required ReportStatus status,
  }) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }

    try {
      final report = await _remoteDataSource.updateReportStatus(
        reportId: reportId,
        status: status,
      );
      return Result.success(report);
    } on exceptions.NotFoundException catch (e) {
      return Result.failure(NotFoundFailure(message: e.message));
    } on exceptions.AppAuthException catch (e) {
      return Result.failure(AuthFailure(message: e.message, code: e.code));
    } on exceptions.ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Result<Report>> markAsFixed(String reportId) async {
    return updateReportStatus(
      reportId: reportId,
      status: ReportStatus.fixed,
    );
  }

  @override
  Future<Result<void>> deleteReport(String reportId) async {
    if (!await _networkInfo.isConnected) {
      return Result.failure(const NetworkFailure());
    }

    try {
      await _remoteDataSource.deleteReport(reportId);
      return Result.success(null);
    } on exceptions.ServerException catch (e) {
      return Result.failure(ServerFailure(message: e.message, code: e.code));
    }
  }

  @override
  Stream<List<Report>> watchReports({ReportFilter? filter}) {
    return _remoteDataSource.watchReports(status: filter?.status);
  }

  @override
  Stream<Report> watchReport(String id) {
    return _remoteDataSource.watchReport(id);
  }
}
