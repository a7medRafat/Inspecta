import 'dart:math';

import 'geocoding_service.dart';

/// A day's route summary — straight-line, not real roads (Feature 05's
/// Map tab, scope-cut: no routing/traffic API).
class RouteEstimate {
  final double distanceKm;
  final int minutes;

  const RouteEstimate({required this.distanceKm, required this.minutes});
}

/// Roughly what a city driver actually averages door-to-door, once
/// traffic lights, parking and turns eat into the straight-line
/// distance — not meant to be precise, just in the right ballpark.
const double _assumedAverageSpeedKmh = 25;

/// Sums the haversine distance between each consecutive pair of
/// [orderedCoordinates] and derives a rough drive time from it. `null`
/// when there are fewer than two stops with known coordinates.
RouteEstimate? estimateRoute(List<Coordinates?> orderedCoordinates) {
  final known = orderedCoordinates.whereType<Coordinates>().toList();
  if (known.length < 2) return null;

  var totalKm = 0.0;
  for (var i = 0; i < known.length - 1; i++) {
    totalKm += _haversineKm(known[i], known[i + 1]);
  }
  final minutes = (totalKm / _assumedAverageSpeedKmh * 60).round();
  return RouteEstimate(distanceKm: totalKm, minutes: minutes);
}

double _haversineKm(Coordinates a, Coordinates b) {
  const earthRadiusKm = 6371.0;
  final dLat = _degToRad(b.lat - a.lat);
  final dLng = _degToRad(b.lng - a.lng);
  final sinLat = sin(dLat / 2);
  final sinLng = sin(dLng / 2);
  final h = sinLat * sinLat + cos(_degToRad(a.lat)) * cos(_degToRad(b.lat)) * sinLng * sinLng;
  return earthRadiusKm * 2 * atan2(sqrt(h), sqrt(1 - h));
}

double _degToRad(double degrees) => degrees * pi / 180;
