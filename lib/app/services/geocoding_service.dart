import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart';

/// A service class to handle geocoding tasks.
class GeocodingService {
  // Private constructor to prevent instantiation
  GeocodingService._();

  /// Converts a physical address string into geographic coordinates (Latitude, Longitude).
  /// Returns a LatLng object on success, or null on failure.
  static Future<LatLng?> getCoordinatesFromAddress(String address) async {
    try {
      final List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        return LatLng(location.latitude, location.longitude);
      }
      return null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting coordinates from address: $e');
      }
      return null;
    }
  }

  /// Converts geographic coordinates into a human-readable address string.
  /// Returns a formatted address string on success, or a default message on failure.
  static Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        // You can format this string however you like
        return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.subAdministrativeArea}';
      }
      return 'Alamat tidak ditemukan';
    } catch (e) {
      if (kDebugMode) {
        print('Error getting address from coordinates: $e');
      }
      return 'Tidak dapat memuat alamat';
    }
  }
}