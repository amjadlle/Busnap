import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

/// Manages the Android foreground service and bridges native GPS events
/// to Flutter via an EventChannel.
///
/// The native service owns the GPS listener (works through Doze mode).
/// Flutter receives locations via the event channel and computes distance.
class BackgroundLocationService {
  static const MethodChannel _method =
      MethodChannel('com.busnap.app/location_service');
  static const EventChannel _events =
      EventChannel('com.busnap.app/location_events');

  static bool _isTracking = false;
  static LatLng? _destination;
  static double? _speedKmh;

  static StreamSubscription? _eventSub;
  static Function(LatLng)? _onLocation;
  static VoidCallback? _onStopped;

  // ── Public API ────────────────────────────────────────────────────────────

  /// Requests permissions, starts the foreground service, and begins
  /// streaming native GPS events to [onLocation].
  /// [onStopped] is called if the user taps Stop on the notification.
  static Future<bool> start({
    required LatLng destination,
    required Function(LatLng) onLocation,
    required VoidCallback onStopped,
  }) async {
    try {
      // Foreground location
      if (!await Permission.location.isGranted) {
        if (!await Permission.location.request().then((r) => r.isGranted)) {
          return false;
        }
      }
      _destination = destination;
      _onLocation  = onLocation;
      _onStopped   = onStopped;

      // Listen to events from native service
      _eventSub?.cancel();
      _eventSub = _events.receiveBroadcastStream().listen(
        (event) {
          if (event is! Map) return;
          final type = event['type'] as String?;
          if (type == 'location') {
            final lat = (event['lat'] as num).toDouble();
            final lng = (event['lng'] as num).toDouble();
            final speed = event['speed'] as num?;
            _speedKmh = speed == null ? null : speed.toDouble() * 3.6;
            _onLocation?.call(LatLng(lat, lng));
          } else if (type == 'stopped') {
            _isTracking = false;
            _onStopped?.call();
          }
        },
        onError: (e) => debugPrint('BackgroundLocationService event error: $e'),
      );

      await _method.invokeMethod('startBackgroundTracking');
      _isTracking = true;
      return true;
    } catch (e) {
      debugPrint('BackgroundLocationService.start: $e');
      return false;
    }
  }

  /// Stops the foreground service and clears all state.
  static Future<void> stop() async {
    _eventSub?.cancel();
    _eventSub   = null;
    _onLocation = null;
    _onStopped  = null;
    try {
      await _method.invokeMethod('stopBackgroundTracking');
    } catch (e) {
      debugPrint('BackgroundLocationService.stop: $e');
    } finally {
      _isTracking  = false;
      _destination = null;
      _speedKmh = null;
    }
  }

  /// Straight-line distance in km from [current] to the destination.
  static double? distanceTo(LatLng current) {
    if (_destination == null) return null;
    return Geolocator.distanceBetween(
          current.latitude,  current.longitude,
          _destination!.latitude, _destination!.longitude,
        ) / 1000;
  }

  static bool get isTracking => _isTracking;
  static double? get speedKmh => _speedKmh;
}
