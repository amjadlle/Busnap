import 'dart:convert';
import 'package:http/http.dart' as http;

/// Used only for the initial route estimate (distance + ETA) shown before
/// the user taps "Start Journey". During the journey, straight-line distance
/// via [BackgroundLocationService.distanceTo] is used instead — no API calls needed.
class DistanceService {
  static const String _baseUrl = 'https://valhalla1.openstreetmap.de/route';
  static const String _osrmUrl = 'https://router.project-osrm.org/route/v1/driving';

  Future<Map<String, dynamic>> getRouteData({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    final body = jsonEncode({
      'locations': [
        {'lon': startLng, 'lat': startLat},
        {'lon': endLng, 'lat': endLat},
      ],
      'costing': 'auto',
      'directions_options': {'units': 'km'},
    });

    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json', 'User-Agent': 'busnap-app/1.0'},
        body: body,
      ).timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final summary = (data['trip'] as Map<String, dynamic>)['summary'] as Map<String, dynamic>;
        return _result((summary['length'] as num).toDouble(), (summary['time'] as num).toDouble());
      }
    } catch (_) {
      // OSRM below is a reliable fallback when Valhalla is busy or unavailable.
    }

    final uri = Uri.parse('$_osrmUrl/$startLng,$startLat;$endLng,$endLat?overview=false');
    final response = await http.get(uri, headers: {'User-Agent': 'busnap-app/1.0'})
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) throw Exception('Routing unavailable');
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final route = (data['routes'] as List<dynamic>).first as Map<String, dynamic>;
    return _result((route['distance'] as num).toDouble() / 1000, (route['duration'] as num).toDouble());
  }

  Map<String, dynamic> _result(double km, double seconds) => {
    'distance_km': km.toStringAsFixed(2),
    'duration_min': (seconds / 60).toStringAsFixed(0),
  };
}
