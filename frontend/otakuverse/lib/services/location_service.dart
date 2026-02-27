import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Demande la permission de localisation
  Future<void> requestPermission() async {
    final permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      await Geolocator.requestPermission();
    }
  }

  /// Retourne la localisation sous forme "latitude,longitude" ou null
  Future<String?> getLocation() async {
    try {
      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      return '${position.latitude},${position.longitude}';
    } catch (e) {
      return null;
    }
  }
}