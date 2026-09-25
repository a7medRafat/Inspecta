import 'dart:convert';

import 'package:http/http.dart' as http;

typedef Coordinates = ({double lat, double lng});

/// Feature 05's Map tab needs a rough distance/drive-time for the day,
/// which needs coordinates for each stop — the app has never geocoded a
/// job's free-text `location` before. Uses OpenStreetMap's Nominatim (no
/// API key or billing, unlike Google's Geocoding API), with an in-memory
/// cache since several jobs often share a site/building.
class GeocodingService {
  final http.Client? _clientOverride;
  final Map<String, Coordinates?> _cache = {};

  GeocodingService({http.Client? client}) : _clientOverride = client;

  http.Client get _client => _clientOverride ?? http.Client();

  Future<Coordinates?> geocode(String address) async {
    if (address.trim().isEmpty) return null;
    if (_cache.containsKey(address)) return _cache[address];

    try {
      final uri = Uri.https('nominatim.openstreetmap.org', '/search', {
        'q': address,
        'format': 'json',
        'limit': '1',
      });
      final response = await _client.get(
        uri,
        // Nominatim's usage policy requires an identifying User-Agent for
        // its shared public instance.
        headers: {'User-Agent': 'InspectaApp/1.0 (inspection scheduling)'},
      );
      if (response.statusCode != 200) return _cache[address] = null;

      final results = jsonDecode(response.body) as List<dynamic>;
      if (results.isEmpty) return _cache[address] = null;

      final first = results.first as Map<String, dynamic>;
      final lat = double.tryParse(first['lat'] as String? ?? '');
      final lng = double.tryParse(first['lon'] as String? ?? '');
      if (lat == null || lng == null) return _cache[address] = null;

      return _cache[address] = (lat: lat, lng: lng);
    } catch (_) {
      return _cache[address] = null;
    }
  }
}
