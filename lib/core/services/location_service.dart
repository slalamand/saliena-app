import 'package:geolocator/geolocator.dart';

import 'package:saliena_app/core/utils/result.dart';
import 'package:saliena_app/core/error/failures.dart';

/// Service for handling location/GPS functionality.
/// Abstracts the geolocator package for easy testing and replacement.
abstract class LocationService {
  Future<Result<Position>> getCurrentPosition();
  Future<bool> isLocationServiceEnabled();
  Future<LocationPermission> checkPermission();
  Future<LocationPermission> requestPermission();
  Stream<Position> getPositionStream();
}

/// Implementation of LocationService using geolocator.
class LocationServiceImpl implements LocationService {
  @override
  Future<Result<Position>> getCurrentPosition() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Result.failure(
          const LocationFailure(message: 'Location services are disabled'),
        );
      }

      // Check permission
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Result.failure(
            const LocationFailure(message: 'Location permission denied'),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Result.failure(
          const LocationFailure(
            message: 'Location permission permanently denied. Please enable in settings.',
          ),
        );
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      return Result.success(position);
    } catch (e) {
      return Result.failure(
        LocationFailure(message: 'Failed to get location: ${e.toString()}'),
      );
    }
  }

  @override
  Future<bool> isLocationServiceEnabled() {
    return Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermission> checkPermission() {
    return Geolocator.checkPermission();
  }

  @override
  Future<LocationPermission> requestPermission() {
    return Geolocator.requestPermission();
  }

  @override
  Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }
}

/// Extension to convert Position to a simple map for storage.
extension PositionExtension on Position {
  Map<String, double> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
