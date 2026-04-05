import 'dart:io';
import 'package:exif/exif.dart';

/// Service for extracting GPS coordinates from photo EXIF data.
class ExifGpsService {
  /// Extracts GPS coordinates from an image file.
  /// Returns null if no GPS data is found.
  Future<({double latitude, double longitude})?> extractGpsFromImage(
    File imageFile,
  ) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final data = await readExifFromBytes(bytes);

      if (data.isEmpty) {
        return null;
      }

      // Extract GPS coordinates
      final gpsLat = data['GPS GPSLatitude'];
      final gpsLatRef = data['GPS GPSLatitudeRef'];
      final gpsLng = data['GPS GPSLongitude'];
      final gpsLngRef = data['GPS GPSLongitudeRef'];

      if (gpsLat == null || gpsLatRef == null || gpsLng == null || gpsLngRef == null) {
        return null;
      }

      // Convert EXIF GPS format to decimal degrees
      final latitude = _convertToDecimalDegrees(
        gpsLat.values.toList().cast<Ratio>(),
        gpsLatRef.printable,
      );
      final longitude = _convertToDecimalDegrees(
        gpsLng.values.toList().cast<Ratio>(),
        gpsLngRef.printable,
      );

      if (latitude == null || longitude == null) {
        return null;
      }

      return (latitude: latitude, longitude: longitude);
    } catch (e) {
      // Failed to extract GPS data
      return null;
    }
  }

  /// Converts EXIF GPS format to decimal degrees.
  double? _convertToDecimalDegrees(List<Ratio> ratios, String ref) {
    try {
      if (ratios.length != 3) return null;

      final degrees = ratios[0].toDouble();
      final minutes = ratios[1].toDouble();
      final seconds = ratios[2].toDouble();

      var decimal = degrees + (minutes / 60) + (seconds / 3600);

      // Apply hemisphere reference
      if (ref == 'S' || ref == 'W') {
        decimal = -decimal;
      }

      return decimal;
    } catch (e) {
      return null;
    }
  }
}
