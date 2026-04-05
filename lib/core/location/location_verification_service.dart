import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:saliena_app/core/location/saliena_boundary.dart';
import 'package:saliena_app/core/utils/result.dart';
import 'package:saliena_app/core/error/failures.dart';

/// Service for verifying user location during sign-up
/// Ensures only Saliena residents can create accounts
class LocationVerificationService {
  /// Checks if the device is currently inside Saliena municipality
  /// Returns success if inside, failure with reason if outside or error
  Future<Result<Position>> verifyLocationInSaliena() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return Result.failure(
          const LocationFailure(
            message: 'Location services are disabled. Please enable GPS to continue.',
            code: 'location_service_disabled',
          ),
        );
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Result.failure(
            const LocationFailure(
              message: 'Location permission denied. We need your location to verify residency.',
              code: 'location_permission_denied',
            ),
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Result.failure(
          const LocationFailure(
            message: 'Location permission permanently denied. Please enable it in device settings.',
            code: 'location_permission_denied_forever',
          ),
        );
      }

      // Get current position with high accuracy for verification
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      // Check if position is inside Saliena boundary
      final userLocation = LatLng(position.latitude, position.longitude);
      final isInSaliena = SalienaBoundary.isPointInSaliena(userLocation);

      if (!isInSaliena) {
        return Result.failure(
          LocationFailure(
            message: 'You must be physically located in Saliena municipality to sign up. '
                'Your current location (${position.latitude.toStringAsFixed(4)}, '
                '${position.longitude.toStringAsFixed(4)}) is outside our service area.',
            code: 'outside_saliena_boundary',
          ),
        );
      }

      // Success - user is inside Saliena
      return Result.success(position);
    } catch (e) {
      return Result.failure(
        LocationFailure(
          message: 'Failed to verify location: ${e.toString()}',
          code: 'location_verification_failed',
        ),
      );
    }
  }

  /// Checks permission status without requesting
  Future<LocationPermission> checkPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  /// Opens app settings for user to enable location permission
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }

  /// Checks if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Opens app settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
