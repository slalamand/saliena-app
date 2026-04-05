import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;

import 'package:saliena_app/core/config/app_config.dart';
import 'package:saliena_app/core/error/failures.dart';
import 'package:saliena_app/core/utils/result.dart';

/// Service for handling image capture and processing.
abstract class ImageService {
  Future<Result<ImageData>> captureFromCamera();
  Future<Result<ImageData>> pickFromGallery();
  Future<Uint8List> compressImage(Uint8List bytes);
}

/// Data class for image information.
class ImageData {
  final Uint8List bytes;
  final String fileName;
  final String mimeType;

  const ImageData({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });
}

/// Implementation of ImageService using image_picker.
class ImageServiceImpl implements ImageService {
  final ImagePicker _picker;

  ImageServiceImpl({ImagePicker? picker}) : _picker = picker ?? ImagePicker();

  @override
  Future<Result<ImageData>> captureFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: AppConfig.maxImageWidth.toDouble(),
        maxHeight: AppConfig.maxImageHeight.toDouble(),
        imageQuality: AppConfig.imageQuality,
      );

      if (image == null) {
        return Result.failure(
          const ValidationFailure(message: 'No image captured'),
        );
      }

      final bytes = await image.readAsBytes();
      final compressedBytes = await compressImage(bytes);

      return Result.success(ImageData(
        bytes: compressedBytes,
        fileName: image.name,
        mimeType: image.mimeType ?? 'image/jpeg',
      ));
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to capture image: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Result<ImageData>> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: AppConfig.maxImageWidth.toDouble(),
        maxHeight: AppConfig.maxImageHeight.toDouble(),
        imageQuality: AppConfig.imageQuality,
      );

      if (image == null) {
        return Result.failure(
          const ValidationFailure(message: 'No image selected'),
        );
      }

      final bytes = await image.readAsBytes();
      final compressedBytes = await compressImage(bytes);

      return Result.success(ImageData(
        bytes: compressedBytes,
        fileName: image.name,
        mimeType: image.mimeType ?? 'image/jpeg',
      ));
    } catch (e) {
      return Result.failure(
        ServerFailure(message: 'Failed to pick image: ${e.toString()}'),
      );
    }
  }

  @override
  Future<Uint8List> compressImage(Uint8List bytes) async {
    // Check if compression is needed
    if (bytes.length <= AppConfig.maxImageSizeBytes) {
      return bytes;
    }

    // Decode and re-encode with lower quality
    final image = img.decodeImage(bytes);
    if (image == null) return bytes;

    // Resize if too large
    img.Image resized = image;
    if (image.width > AppConfig.maxImageWidth ||
        image.height > AppConfig.maxImageHeight) {
      resized = img.copyResize(
        image,
        width: AppConfig.maxImageWidth,
        height: AppConfig.maxImageHeight,
        maintainAspect: true,
      );
    }

    // Encode as JPEG with quality
    final compressed = img.encodeJpg(resized, quality: AppConfig.imageQuality);
    return Uint8List.fromList(compressed);
  }
}
