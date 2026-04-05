import 'package:equatable/equatable.dart';

/// Location source for GPS data.
enum LocationSource {
  photoExif,
  deviceGps,
  manual;

  String get label {
    switch (this) {
      case LocationSource.photoExif:
        return 'Photo GPS';
      case LocationSource.deviceGps:
        return 'Device GPS';
      case LocationSource.manual:
        return 'Manual';
    }
  }
}

/// Report status enum.
enum ReportStatus {
  pending,
  inProgress,
  fixed;

  /// Parses a status from a string.
  static ReportStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'in_progress':
      case 'inprogress':
        return ReportStatus.inProgress;
      case 'fixed':
        return ReportStatus.fixed;
      default:
        return ReportStatus.pending;
    }
  }

  /// Converts the status to a string for storage.
  String toStorageString() {
    switch (this) {
      case ReportStatus.pending:
        return 'pending';
      case ReportStatus.inProgress:
        return 'in_progress';
      case ReportStatus.fixed:
        return 'fixed';
    }
  }

  /// Returns a human-readable label.
  String get label {
    switch (this) {
      case ReportStatus.pending:
        return 'Pending';
      case ReportStatus.inProgress:
        return 'In Progress';
      case ReportStatus.fixed:
        return 'Fixed';
    }
  }
}

/// Domain entity representing a geographic location.
class GeoLocation extends Equatable {
  final double latitude;
  final double longitude;
  final String? address;
  final LocationSource source;

  const GeoLocation({
    required this.latitude,
    required this.longitude,
    this.address,
    this.source = LocationSource.deviceGps,
  });

  @override
  List<Object?> get props => [latitude, longitude, address, source];

  GeoLocation copyWith({
    double? latitude,
    double? longitude,
    String? address,
    LocationSource? source,
  }) {
    return GeoLocation(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      source: source ?? this.source,
    );
  }
}

/// Domain entity representing an issue report.
class Report extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String description;
  final List<String> photoUrls;
  final String? videoUrl;
  final GeoLocation location;
  final ReportStatus status;
  final String? fixedBy;
  final DateTime? fixedAt;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // Optional: Reporter info for display (not always loaded)
  final String? reporterName;
  final String? reporterPhone;

  const Report({
    required this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.photoUrls,
    this.videoUrl,
    required this.location,
    required this.status,
    this.fixedBy,
    this.fixedAt,
    required this.createdAt,
    this.updatedAt,
    this.reporterName,
    this.reporterPhone,
  });

  /// Returns true if the report is still open.
  bool get isOpen => status != ReportStatus.fixed;

  /// Returns true if the report has been fixed.
  bool get isFixed => status == ReportStatus.fixed;

  /// Creates a copy of this report with the given fields replaced.
  Report copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    List<String>? photoUrls,
    String? videoUrl,
    GeoLocation? location,
    ReportStatus? status,
    String? fixedBy,
    DateTime? fixedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? reporterName,
    String? reporterPhone,
  }) {
    return Report(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      photoUrls: photoUrls ?? this.photoUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      location: location ?? this.location,
      status: status ?? this.status,
      fixedBy: fixedBy ?? this.fixedBy,
      fixedAt: fixedAt ?? this.fixedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      reporterName: reporterName ?? this.reporterName,
      reporterPhone: reporterPhone ?? this.reporterPhone,
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        photoUrls,
        videoUrl,
        location,
        status,
        fixedBy,
        fixedAt,
        createdAt,
        updatedAt,
        reporterName,
        reporterPhone,
      ];
}
