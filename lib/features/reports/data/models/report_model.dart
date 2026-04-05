import 'dart:convert';

import 'package:saliena_app/features/reports/domain/entities/report.dart';

/// Data model for Report that handles serialization.
class ReportModel extends Report {
  const ReportModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.description,
    required super.photoUrls,
    super.videoUrl,
    required super.location,
    required super.status,
    super.fixedBy,
    super.fixedAt,
    required super.createdAt,
    super.updatedAt,
    super.reporterName,
    super.reporterPhone,
  });

  /// Creates a ReportModel from a Supabase/JSON response.
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    // Parse photo_url - can be single URL, pipe-separated, or JSON array
    List<String> photoUrls = [];
    final photoUrlRaw = json['photo_url'] as String?;
    if (photoUrlRaw != null && photoUrlRaw.isNotEmpty) {
      if (photoUrlRaw.contains('|||')) {
        // Pipe-separated format for multiple URLs
        photoUrls = photoUrlRaw.split('|||');
      } else if (photoUrlRaw.startsWith('[')) {
        // JSON array format (legacy)
        photoUrls = (jsonDecode(photoUrlRaw) as List).cast<String>();
      } else {
        // Single URL (backward compatibility)
        photoUrls = [photoUrlRaw];
      }
    }

    return ReportModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      photoUrls: photoUrls,
      videoUrl: json['video_url'] as String?,
      location: GeoLocation(
        latitude: (json['latitude'] as num).toDouble(),
        longitude: (json['longitude'] as num).toDouble(),
        address: json['address'] as String?,
        source: _parseLocationSource(json['location_source'] as String?),
      ),
      status: ReportStatus.fromString(json['status'] as String? ?? 'pending'),
      fixedBy: json['fixed_by'] as String?,
      fixedAt: json['fixed_at'] != null
          ? DateTime.parse(json['fixed_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      reporterName: json['profiles']?['full_name'] as String?,
      reporterPhone: json['profiles']?['phone'] as String?,
    );
  }

  /// Converts the model to JSON for Supabase/API.
  Map<String, dynamic> toJson() {
    final data = {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'address': location.address,
      'location_source': _locationSourceToString(location.source),
      'status': status.toStorageString(),
      if (fixedBy != null) 'fixed_by': fixedBy,
      if (fixedAt != null) 'fixed_at': fixedAt!.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };

    // Add photo_url only if photos exist
    if (photoUrls.isNotEmpty) {
      data['photo_url'] = photoUrls.length == 1 ? photoUrls.first : jsonEncode(photoUrls);
    }

    // Add video_url only if video exists
    if (videoUrl != null) {
      data['video_url'] = videoUrl;
    }

    return data;
  }

  /// Creates a ReportModel from a domain Report entity.
  factory ReportModel.fromEntity(Report report) {
    return ReportModel(
      id: report.id,
      userId: report.userId,
      title: report.title,
      description: report.description,
      photoUrls: report.photoUrls,
      videoUrl: report.videoUrl,
      location: report.location,
      status: report.status,
      fixedBy: report.fixedBy,
      fixedAt: report.fixedAt,
      createdAt: report.createdAt,
      updatedAt: report.updatedAt,
      reporterName: report.reporterName,
      reporterPhone: report.reporterPhone,
    );
  }

  /// Converts to domain entity.
  Report toEntity() => this;

  /// Parse location source from string.
  static LocationSource _parseLocationSource(String? value) {
    switch (value?.toLowerCase()) {
      case 'photo_exif':
        return LocationSource.photoExif;
      case 'manual':
        return LocationSource.manual;
      case 'device_gps':
      default:
        return LocationSource.deviceGps;
    }
  }

  /// Convert location source to string for storage.
  static String _locationSourceToString(LocationSource source) {
    switch (source) {
      case LocationSource.photoExif:
        return 'photo_exif';
      case LocationSource.deviceGps:
        return 'device_gps';
      case LocationSource.manual:
        return 'manual';
    }
  }
}
