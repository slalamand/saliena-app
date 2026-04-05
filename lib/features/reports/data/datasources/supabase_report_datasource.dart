import 'package:flutter/foundation.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:saliena_app/core/error/exceptions.dart' as exceptions;
import 'package:saliena_app/features/reports/data/datasources/report_remote_datasource.dart';
import 'package:saliena_app/features/reports/data/models/report_model.dart';
import 'package:saliena_app/features/reports/domain/entities/report.dart';

/// Supabase implementation of ReportRemoteDataSource.
/// This class is the ONLY place where Supabase report logic exists.
class SupabaseReportDataSource implements ReportRemoteDataSource {
  final SupabaseClient _client;

  SupabaseReportDataSource(this._client);

  @override
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
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const exceptions.AppAuthException(message: 'Not authenticated');
      }

      // Upload all photos to storage
      final List<String> photoUrls = [];
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      
      for (int i = 0; i < photoBytesList.length; i++) {
        final photoPath = 'reports/$userId/${timestamp}_${i}_${photoFileNames[i]}';
        await _client.storage.from('report-photos').uploadBinary(
              photoPath,
              photoBytesList[i],
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );
        final url = _client.storage.from('report-photos').getPublicUrl(photoPath);
        photoUrls.add(url);
      }

      // Upload video if provided
      String? videoUrl;
      if (videoBytes != null && videoFileName != null) {
        final videoPath = 'reports/$userId/${timestamp}_video_$videoFileName';
        await _client.storage.from('report-videos').uploadBinary(
              videoPath,
              videoBytes,
              fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
            );
        videoUrl = _client.storage.from('report-videos').getPublicUrl(videoPath);
      }

      // Store as single URL or pipe-separated for multiple
      final photoUrlValue = photoUrls.isEmpty 
          ? null 
          : (photoUrls.length == 1 ? photoUrls.first : photoUrls.join('|||'));

      // Create report record
      final reportData = {
        'user_id': userId,
        'title': title,
        'description': description,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'status': 'pending',
      };

      // Add photo_url only if photos exist
      if (photoUrlValue != null) {
        reportData['photo_url'] = photoUrlValue;
      }

      // Add video_url only if video exists
      if (videoUrl != null) {
        reportData['video_url'] = videoUrl;
      }

      final response = await _client.from('reports').insert(reportData)
          .select('*, profiles!user_id(full_name, phone)').single();

      // Trigger notification edge function
      try {
        await _client.functions.invoke(
          'notify_new_report',
          body: {'record': response},
        );
      } catch (e) {
        // Log error but don't fail the report creation
        debugPrint('Failed to send notifications: $e');
      }

      return ReportModel.fromJson(response);
    } on StorageException catch (e) {
      throw exceptions.ServerException(
        message: e.message,
        originalError: e,
      );
    } on PostgrestException catch (e) {
      throw exceptions.ServerException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<ReportModel> getReport(String id) async {
    try {
      final response = await _client
          .from('reports')
          .select('*, profiles!user_id(full_name, phone)')
          .eq('id', id)
          .single();

      return ReportModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const exceptions.NotFoundException(message: 'Report not found');
      }
      throw exceptions.ServerException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<List<ReportModel>> getReports({
    ReportStatus? status,
    String? userId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      var query = _client
          .from('reports')
          .select('*, profiles!user_id(full_name, phone)');

      if (status != null) {
        query = query.eq('status', status.toStorageString());
      }

      if (userId != null) {
        query = query.eq('user_id', userId);
      }

      final response = await query
          .order('created_at', ascending: false)
          .range((page - 1) * pageSize, page * pageSize - 1);

      return (response as List)
          .map((json) => ReportModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw exceptions.ServerException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<List<ReportModel>> getReportsInBounds({
    required double northLat,
    required double southLat,
    required double eastLng,
    required double westLng,
  }) async {
    try {
      final response = await _client
          .from('reports')
          .select('*, profiles!user_id(full_name, phone)')
          .gte('latitude', southLat)
          .lte('latitude', northLat)
          .gte('longitude', westLng)
          .lte('longitude', eastLng)
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => ReportModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw exceptions.ServerException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<ReportModel> updateReportStatus({
    required String reportId,
    required ReportStatus status,
  }) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const exceptions.AppAuthException(message: 'Not authenticated');
      }

      final updates = <String, dynamic>{
        'status': status.toStorageString(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (status == ReportStatus.fixed) {
        updates['fixed_by'] = userId;
        updates['fixed_at'] = DateTime.now().toIso8601String();
      }

      final response = await _client
          .from('reports')
          .update(updates)
          .eq('id', reportId)
          .select('*, profiles!user_id(full_name, phone)')
          .single();

      return ReportModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == 'PGRST116') {
        throw const exceptions.NotFoundException(message: 'Report not found');
      }
      throw exceptions.ServerException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Future<void> deleteReport(String reportId) async {
    try {
      await _client.from('reports').delete().eq('id', reportId);
    } on PostgrestException catch (e) {
      throw exceptions.ServerException(
        message: e.message,
        code: e.code,
        originalError: e,
      );
    }
  }

  @override
  Stream<List<ReportModel>> watchReports({ReportStatus? status}) {
    var query = _client
        .from('reports')
        .stream(primaryKey: ['id']);

    return query.asyncMap((data) async {
      var filtered = data;
      if (status != null) {
        filtered = data.where((r) => r['status'] == status.toStorageString()).toList();
      }

      if (filtered.isEmpty) return [];

      // Fetch profiles for the reports to get reporter names
      final userIds = filtered.map((r) => r['user_id'] as String).toSet().toList();
      
      if (userIds.isEmpty) {
        return filtered.map((json) => ReportModel.fromJson(json)).toList();
      }

      try {
        final profiles = await _client
            .from('profiles')
            .select('id, full_name, phone')
            .inFilter('id', userIds);
            
        final profileMap = {
          for (var p in profiles) p['id'] as String: {
            'full_name': p['full_name'] as String?,
            'phone': p['phone'] as String?,
          }
        };

        return filtered.map((json) {
          final userId = json['user_id'] as String;
          // Inject profile data into the json so fromJson can parse it
          // ReportModel.fromJson expects json['profiles']['full_name']
          final jsonWithProfile = Map<String, dynamic>.from(json);
          if (profileMap.containsKey(userId)) {
            jsonWithProfile['profiles'] = profileMap[userId];
          }
          return ReportModel.fromJson(jsonWithProfile);
        }).toList();
      } catch (e) {
        // If profile fetch fails, return reports without reporter names
        return filtered.map((json) => ReportModel.fromJson(json)).toList();
      }
    });
  }

  @override
  Stream<ReportModel> watchReport(String id) {
    return _client
        .from('reports')
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((data) {
          if (data.isEmpty) {
            throw const exceptions.NotFoundException(message: 'Report not found');
          }
          return ReportModel.fromJson(data.first);
        });
  }
}
