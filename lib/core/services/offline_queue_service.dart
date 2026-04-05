import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

/// Service for managing offline report queue with automatic retry.
class OfflineQueueService {
  static const String _boxName = 'offline_reports';
  Box<Map>? _box;
  final InternetConnection _connectionChecker;
  StreamSubscription<InternetStatus>? _connectionSubscription;
  Timer? _retryTimer;

  OfflineQueueService(this._connectionChecker);

  /// Initialize the offline queue service.
  Future<void> initialize() async {
    try {
      await Hive.initFlutter();
      _box = await Hive.openBox<Map>(_boxName);
      _startConnectionMonitoring();
    } catch (e) {
      // If Hive initialization fails, continue without offline queue
      // This prevents app crashes on iOS when Hive can't access storage
      print('Warning: Offline queue initialization failed: $e');
      print('App will continue without offline queue functionality');
      _box = null;
      // Still start connection monitoring for other features
      _startConnectionMonitoring();
    }
  }

  /// Add a report to the offline queue.
  Future<String> queueReport({
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
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    
    final reportData = {
      'id': id,
      'title': title,
      'description': description,
      'photoBytesList': photoBytesList.map((b) => base64Encode(b)).toList(),
      'photoFileNames': photoFileNames,
      'videoBytes': videoBytes != null ? base64Encode(videoBytes) : null,
      'videoFileName': videoFileName,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'timestamp': DateTime.now().toIso8601String(),
      'retryCount': 0,
    };

    await _box?.put(id, reportData);
    return id;
  }

  /// Get all queued reports.
  List<QueuedReport> getQueuedReports() {
    if (_box == null) return [];
    
    return _box!.values.map((data) {
      final map = Map<String, dynamic>.from(data);
      return QueuedReport(
        id: map['id'] as String,
        title: map['title'] as String,
        description: map['description'] as String,
        photoCount: (map['photoBytesList'] as List).length,
        hasVideo: map['videoBytes'] != null,
        timestamp: DateTime.parse(map['timestamp'] as String),
        retryCount: map['retryCount'] as int,
      );
    }).toList();
  }

  /// Get a specific queued report data.
  Map<String, dynamic>? getReportData(String id) {
    final data = _box?.get(id);
    if (data == null) return null;
    
    final map = Map<String, dynamic>.from(data);
    
    // Decode base64 back to bytes
    final photoBytesList = (map['photoBytesList'] as List)
        .map((b) => base64Decode(b as String))
        .toList();
    
    Uint8List? videoBytes;
    if (map['videoBytes'] != null) {
      videoBytes = base64Decode(map['videoBytes'] as String);
    }
    
    return {
      'id': map['id'],
      'title': map['title'],
      'description': map['description'],
      'photoBytesList': photoBytesList,
      'photoFileNames': map['photoFileNames'],
      'videoBytes': videoBytes,
      'videoFileName': map['videoFileName'],
      'latitude': map['latitude'],
      'longitude': map['longitude'],
      'address': map['address'],
      'timestamp': map['timestamp'],
      'retryCount': map['retryCount'],
    };
  }

  /// Remove a report from the queue.
  Future<void> removeReport(String id) async {
    await _box?.delete(id);
  }

  /// Increment retry count for a report.
  Future<void> incrementRetryCount(String id) async {
    final data = _box?.get(id);
    if (data != null) {
      final map = Map<String, dynamic>.from(data);
      map['retryCount'] = (map['retryCount'] as int) + 1;
      await _box?.put(id, map);
    }
  }

  /// Get the count of queued reports.
  int get queuedCount => _box?.length ?? 0;

  /// Check if there are queued reports.
  bool get hasQueuedReports => queuedCount > 0;

  /// Start monitoring connection for automatic retry.
  void _startConnectionMonitoring() {
    _connectionSubscription = _connectionChecker.onStatusChange.listen((status) {
      if (status == InternetStatus.connected && hasQueuedReports) {
        // Connection restored, trigger retry after a short delay
        _scheduleRetry();
      }
    });
  }

  /// Schedule a retry attempt.
  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 2), () {
      // Retry will be triggered by the UI listening to connection changes
    });
  }

  /// Dispose resources.
  Future<void> dispose() async {
    await _connectionSubscription?.cancel();
    _retryTimer?.cancel();
    await _box?.close();
  }
}

/// Represents a queued report in the offline queue.
class QueuedReport {
  final String id;
  final String title;
  final String description;
  final int photoCount;
  final bool hasVideo;
  final DateTime timestamp;
  final int retryCount;

  QueuedReport({
    required this.id,
    required this.title,
    required this.description,
    required this.photoCount,
    required this.hasVideo,
    required this.timestamp,
    required this.retryCount,
  });

  String get mediaDescription {
    final parts = <String>[];
    if (photoCount > 0) parts.add('$photoCount photo${photoCount > 1 ? 's' : ''}');
    if (hasVideo) parts.add('1 video');
    return parts.isEmpty ? 'No media' : parts.join(' + ');
  }
}
