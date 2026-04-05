import 'package:latlong2/latlong.dart';

class SalienaBoundary {
  static const List<LatLng> polygonCoordinates = [
    LatLng(56.9570305510687, 23.89833325060968),
    LatLng(56.95725372455834, 23.895847727585704),
    LatLng(56.95601002791241, 23.886610208342944),
    LatLng(56.951669611086146, 23.887914730211065),
    LatLng(56.94913317761086, 23.88967300337123),
    LatLng(56.95105098925251, 23.89774591406109),
    LatLng(56.952628470034, 23.897311073438374),
    LatLng(56.953504819401104, 23.90041167613836),
    LatLng(56.948893942963736, 23.904428659478242),
    LatLng(56.95054368992669, 23.908039727257517),
    LatLng(56.94995092168244, 23.912580925295856),
    LatLng(56.95267288784561, 23.91341279431299),
    LatLng(56.95273474840309, 23.911975929647184),
    LatLng(56.95340489786176, 23.909915163218614),
    LatLng(56.95488949375172, 23.90772205399091),
    LatLng(56.95558668173064, 23.90611100375844),
    LatLng(56.9570305510687, 23.89833325060968),
  ];

  /// Checks if a point is inside the Saliena municipality boundary
  /// using the ray casting algorithm (point-in-polygon test)
  static bool isPointInSaliena(LatLng point) {
    return _isPointInPolygon(point, polygonCoordinates);
  }

  /// Ray casting algorithm for point-in-polygon test
  /// Returns true if point is inside the polygon
  static bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    bool inside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      if ((polygon[i].longitude < point.longitude && 
           polygon[j].longitude >= point.longitude) ||
          (polygon[j].longitude < point.longitude && 
           polygon[i].longitude >= point.longitude)) {
        if (polygon[i].latitude +
                (point.longitude - polygon[i].longitude) /
                    (polygon[j].longitude - polygon[i].longitude) *
                    (polygon[j].latitude - polygon[i].latitude) <
            point.latitude) {
          inside = !inside;
        }
      }
      j = i;
    }

    return inside;
  }

  /// Get the approximate center of Saliena for map display
  static LatLng get center => const LatLng(56.95264, 23.89987);

  /// Get the approximate bounds for map fitting
  static double get minLatitude => 56.94913317761086;
  static double get maxLatitude => 56.9570305510687;
  static double get minLongitude => 23.886610208342944;
  static double get maxLongitude => 23.912580925295856;
}
