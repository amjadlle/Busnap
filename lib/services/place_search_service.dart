import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class PlaceSuggestion {
  final String displayName;
  final LatLng latLng;

  const PlaceSuggestion({required this.displayName, required this.latLng});
}

/// Place search via Nominatim (OpenStreetMap).
/// Free, no API key, no account required.
class PlaceSearchService {
  static const String _baseUrl =
      'https://nominatim.openstreetmap.org/search'
      '?format=jsonv2&limit=8&addressdetails=1';

  Future<List<PlaceSuggestion>> fetchSuggestions(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse('$_baseUrl&q=${Uri.encodeQueryComponent(query.trim())}');

    try {
      final response = await http
          .get(uri, headers: {'User-Agent': 'busnap-app/1.0'})
          .timeout(const Duration(seconds: 8));

      if (response.statusCode != 200) return [];

      final data = jsonDecode(response.body) as List<dynamic>;

      final seen = <String>{};
      final suggestions = <PlaceSuggestion>[];
      for (final e in data) {
        final lat = double.tryParse(e['lat'] as String? ?? '') ?? 0.0;
        final lon = double.tryParse(e['lon'] as String? ?? '') ?? 0.0;
        final name = (e['display_name'] as String?)?.trim() ?? 'Unknown';
        final key = name.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
        if ((lat == 0 && lon == 0) || !seen.add(key)) continue;
        suggestions.add(PlaceSuggestion(displayName: name, latLng: LatLng(lat, lon)));
      }
      return suggestions;
    } catch (_) {
      return [];
    }
  }
}
