import 'package:geolocator/geolocator.dart';

/// A service class to handle all geolocation-related tasks.
class GeolocationService {
  // Private constructor to prevent instantiation
  GeolocationService._();

  // A default position for Banjarmasin, used as a fallback.
  static final Position _defaultPosition = Position(
      latitude: -7.2575, longitude: 112.7521, timestamp: DateTime.now(),
      accuracy: 0, altitude: 0, altitudeAccuracy: 0, heading: 0, headingAccuracy: 0, speed: 0, speedAccuracy: 0);

  /// Determines the current position of the device.
  ///
  /// It will request location permissions from the user if they have not yet been granted.
  /// If permissions are denied or services are disabled, it returns a default location.
  static Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, don't request permissions
      // and return the default position.
      return _defaultPosition;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, return default position.
        return _defaultPosition;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, return default position.
      return _defaultPosition;
    }

    // When we reach here, permissions are granted and we can
    // access the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}