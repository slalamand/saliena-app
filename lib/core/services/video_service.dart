import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

import 'package:saliena_app/core/config/app_config.dart';
import 'package:saliena_app/core/error/failures.dart';
import 'package:saliena_app/core/utils/result.dart';

/// Service for handling video capture and processing.
abstract class VideoService {
  Future<Result<VideoData>> captureFromCamera();
  Future<Result<VideoData>> pickFromGallery();
  Future<int> getVideoDuration(String path);
}

/// Data class for video information.
class VideoData {
  final Uint8List bytes;
  final String fileName;
  final String mimeType;
  final int durationSeconds;

  const VideoData({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
    required this.durationSeconds,
  });
}

/// Implementation of VideoService using image_picker and video_player.
class VideoServiceImpl implements VideoService {
  final ImagePicker _picker;

  VideoServiceImpl({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  @override
  Future<Result<VideoData>> captureFromCamera() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.camera,
        maxDuration: const Duration(seconds: AppConfig.maxVideoDurationSeconds),
      );

      if (video == null) {
        return Result.failure(
          const ValidationFailure(message: 'No video captured'),
        );
      }

      return await _processVideo(video);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to capture video: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<VideoData>> pickFromGallery() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
        maxDuration: const Duration(seconds: AppConfig.maxVideoDurationSeconds),
      );

      if (video == null) {
        return Result.failure(
          const ValidationFailure(message: 'No video selected'),
        );
      }

      return await _processVideo(video);
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to pick video: ${e.toString()}'),
      );
    }
  }

  @override
  Future<int> getVideoDuration(String path) async {
    try {
      final controller = VideoPlayerController.file(File(path));
      await controller.initialize();
      final duration = controller.value.duration.inSeconds;
      await controller.dispose();
      return duration;
    } catch (e) {
      return 0;
    }
  }

  Future<Result<VideoData>> _processVideo(XFile video) async {
    try {
      // Check video duration
      final duration = await getVideoDuration(video.path);
      if (duration > AppConfig.maxVideoDurationSeconds) {
        return Result.failure(
          ValidationFailure(
            message: 'Video is too long. Maximum ${AppConfig.maxVideoDurationSeconds} seconds allowed.',
          ),
        );
      }

      // Read video bytes
      final bytes = await video.readAsBytes();

      // Check file size
      if (bytes.length > AppConfig.maxVideoSizeBytes) {
        return Result.failure(
          ValidationFailure(
            message: 'Video file is too large. Maximum ${AppConfig.maxVideoSizeBytes ~/ (1024 * 1024)}MB allowed.',
          ),
        );
      }

      return Result.success(VideoData(
        bytes: bytes,
        fileName: video.name,
        mimeType: video.mimeType ?? 'video/mp4',
        durationSeconds: duration,
      ));
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to process video: ${e.toString()}'),
      );
    }
  }
}
