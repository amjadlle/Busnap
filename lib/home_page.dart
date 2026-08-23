import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:latlong2/latlong.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:busnap/main.dart';
import 'package:busnap/services/background_location_service.dart';
import 'package:busnap/services/connectivity_service.dart';
import 'package:busnap/services/distance_service.dart';
import 'package:busnap/services/place_search_service.dart';
import 'package:busnap/alarm_settings_screen.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _SavedDestination {
  const _SavedDestination(this.name, this.latLng);

  final String name;
  final LatLng latLng;

  factory _SavedDestination.fromJson(Map<String, dynamic> json) => _SavedDestination(
    json['name'] as String,
    LatLng((json['lat'] as num).toDouble(), (json['lng'] as num).toDouble()),
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'lat': latLng.latitude,
    'lng': latLng.longitude,
  };
}

class _JourneyStep extends StatelessWidget {
  const _JourneyStep({required this.number, required this.label});

  final String number;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Container(
        width: 28, height: 28,
        decoration: const BoxDecoration(color: AppTheme.accentLight, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(number, style: const TextStyle(
            color: AppTheme.accent, fontSize: 12, fontWeight: FontWeight.w800)),
      ),
      const SizedBox(height: 6),
      Text(label, style: const TextStyle(
          color: AppTheme.inkSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
    ]),
  );
}

class _StepLine extends StatelessWidget {
  const _StepLine();

  @override
  Widget build(BuildContext context) => Container(
    width: 18,
    height: 1,
    margin: const EdgeInsets.only(bottom: 22),
    color: AppTheme.accentLight,
  );
}

class _HomePageState extends State<HomePage> {
  final _destController = TextEditingController();
  final _destFocus      = FocusNode();
  final _connectivity   = ConnectivityService();
  final _placeSearch    = PlaceSearchService();
  final _distanceSvc    = DistanceService();
  final _notifications  = FlutterLocalNotificationsPlugin();
  final _audioPlayer    = AudioPlayer();

  LatLng? _currentLatLng;
  LatLng? _destinationLatLng;
  String  _destinationName = '';
  StreamSubscription<Position>? _locationSub;

  String? _routeDistance;
  String? _routeDuration;
  bool    _isFetchingRoute = false;
  bool    _waitingForRoute = false;

  bool      _journeyActive    = false;
  Stopwatch _journeyStopwatch = Stopwatch();
  String    _elapsed          = '00:00';
  Timer?    _clockTimer;
  Timer?    _gpsWatchdog;
  final Set<int> _alertedKm  = {};
  List<int> _alertDistances = [5, 2, 1];
  List<_SavedDestination> _history = [];
  int _searchRequest = 0;
  bool _arrivalHandled = false;
  double?   _initialDistanceKm;
  double?   _initialDurationMin;
  LatLng?   _lastJourneyLocation;
  double    _tripDistanceKm = 0;
  double?   _speedKmh;

  bool              _isAlarmPlaying = false;
  Timer?            _alarmTimer;
  StreamSubscription? _alarmCompleteSub;

  List<PlaceSuggestion> _suggestions     = [];
  Timer?                _searchDebounce;
  bool                  _showSuggestions = false;
  bool                  _isSearching = false;

  // ── Lifecycle ────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initNotifications();
    _loadPreferences();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startPassiveLocation();
      _checkConnectivity();
    });
  }

  @override
  void dispose() {
    _destController.dispose();
    _destFocus.dispose();
    _locationSub?.cancel();
    _clockTimer?.cancel();
    _alarmTimer?.cancel();
    _alarmCompleteSub?.cancel();
    _searchDebounce?.cancel();
    _gpsWatchdog?.cancel();
    _audioPlayer.dispose();
    if (BackgroundLocationService.isTracking) BackgroundLocationService.stop();
    super.dispose();
  }

  // ── Init ─────────────────────────────────────────────────────────────────

  Future<void> _initNotifications() async {
    await _notifications.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (response) {
        if (response.actionId == 'stop_alarm') _stopAlarm();
      },
    );
    final android = _notifications.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final distances = prefs.getStringList('alert_distances')
        ?.map(int.tryParse).whereType<int>().where((d) => d > 0).toSet().toList();
    final rawHistory = prefs.getString('journey_history');
    var history = <_SavedDestination>[];
    if (rawHistory != null) {
      try {
        history = (jsonDecode(rawHistory) as List<dynamic>)
            .whereType<Map<String, dynamic>>()
            .map(_SavedDestination.fromJson)
            .toList();
      } catch (_) {
        await prefs.remove('journey_history');
      }
    }
    if (!mounted) return;
    setState(() {
      _alertDistances = (distances == null || distances.isEmpty ? [5, 2, 1] : distances)
        ..sort((a, b) => b.compareTo(a));
      _history = history;
    });
  }

  Future<void> _saveHistory() async {
    if (_destinationName.isEmpty || _destinationLatLng == null) return;
    final entry = _SavedDestination(_destinationName, _destinationLatLng!);
    final next = [entry, ..._history.where((item) => item.name != entry.name)].take(5).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('journey_history', jsonEncode(next.map((item) => item.toJson()).toList()));
    if (mounted) setState(() => _history = next);
  }

  void _checkConnectivity() async {
    if (mounted) await _connectivity.requestInternetConnection(context);
  }

  Future<bool> _showLocationDisclosure() async {
    if (!mounted) return false;
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Location access for journey alerts'),
        content: const Text(
          'Busnap collects your device location while you are using the app and '
          'during an active journey when the app is minimized or the screen is '
          'locked. This is needed to calculate your distance to the destination '
          'and alert you when you are approaching it. Location is not collected '
          'when you are not tracking a journey.',
          style: TextStyle(height: 1.45),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Not now'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    return accepted == true;
  }

  void _startPassiveLocation() async {
    if (!await _showLocationDisclosure()) return;
    final p = await Geolocator.requestPermission();
    if (p == LocationPermission.denied || p == LocationPermission.deniedForever) return;
    if (p == LocationPermission.whileInUse) {
      // This is best-effort: tracking can still work as a foreground service
      // when the user starts it from the visible app.
      await Permission.locationAlways.request();
    }
    _locationSub?.cancel();
    _locationSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
      ),
    ).listen((pos) {
      if (!mounted) return;
      final location = LatLng(pos.latitude, pos.longitude);
      setState(() => _currentLatLng = location);
      if (_waitingForRoute && _destinationLatLng != null) {
        _waitingForRoute = false;
        _fetchRoute(_destinationLatLng!);
      }
    });
  }

  // ── Search ───────────────────────────────────────────────────────────────

  void _onSearchChanged(String v) {
    _searchDebounce?.cancel();
    final request = ++_searchRequest;
    if (v.trim().length < 2) {
      setState(() {
        _suggestions.clear();
        _showSuggestions = false;
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    _searchDebounce = Timer(const Duration(milliseconds: 220), () async {
      final r = await _placeSearch.fetchSuggestions(v);
      if (!mounted || request != _searchRequest || _destController.text != v) return;
      setState(() {
        _suggestions = r;
        _showSuggestions = r.isNotEmpty;
        _isSearching = false;
      });
    });
  }

  void _selectSuggestion(PlaceSuggestion s) {
    _destController.text = s.displayName;
    _destFocus.unfocus();
    setState(() {
      _destinationLatLng = s.latLng;
      _destinationName   = s.displayName;
      _suggestions.clear();
      _showSuggestions = false;
      _isSearching = false;
    });
    _fetchRoute(s.latLng);
  }

  void _clearDestination() {
    _destController.clear();
    setState(() {
      _destinationLatLng = null;
      _destinationName   = '';
      _suggestions.clear();
      _showSuggestions = false;
      _routeDistance   = null;
      _routeDuration   = null;
      _waitingForRoute = false;
    });
  }

  // ── Route (initial estimate only) ────────────────────────────────────────

  Future<void> _fetchRoute(LatLng dest) async {
    if (!mounted) return;

    // Bug 4 fix: wait for a GPS fix before trying to calculate route
    if (_currentLatLng == null) {
      _waitingForRoute = true;
      return;
    }

    if (!await _connectivity.requestInternetConnection(context)) return;
    setState(() { _isFetchingRoute = true; _routeDistance = null; _routeDuration = null; });
    try {
      final d = await _distanceSvc.getRouteData(
        startLat: _currentLatLng!.latitude,  startLng: _currentLatLng!.longitude,
        endLat:   dest.latitude,             endLng:   dest.longitude,
      );
      if (!mounted) return;
      setState(() {
        _routeDistance = '${d['distance_km']} km';
        _routeDuration = '${d['duration_min']} min';
      });
      // Bug 1 fix: do NOT check thresholds at route fetch time — only during active journey
    } catch (_) {
      // Keep the journey usable when public routing providers are unavailable.
      final straightLineKm = Geolocator.distanceBetween(
        _currentLatLng!.latitude, _currentLatLng!.longitude,
        dest.latitude, dest.longitude,
      ) / 1000;
      if (mounted) {
        setState(() {
          _routeDistance = '${straightLineKm.toStringAsFixed(2)} km';
          _routeDuration = '${(straightLineKm / 35 * 60).ceil().clamp(1, 999)} min';
        });
        _snack('Route service is unavailable. Using direct distance estimate.');
      }
    } finally {
      if (mounted) setState(() => _isFetchingRoute = false);
    }
  }

  // ── Journey ──────────────────────────────────────────────────────────────

  Future<void> _startJourney() async {
    if (_destinationLatLng == null || !mounted) return;
    if (!await _connectivity.requestInternetConnection(context)) return;

    final ok = await BackgroundLocationService.start(
      destination: _destinationLatLng!,
      onLocation: (ll) {
        if (!mounted) return;
        setState(() => _currentLatLng = ll);
        _updateDistance(ll);
      },
      onStopped: () { if (mounted) _stopJourney(); },
    );

    if (!ok) {
      if (mounted) _snack('Could not start. Check permissions.', error: true);
      return;
    }

    _locationSub?.cancel();
    _locationSub = null;

    // Bug 1 fix: clear thresholds only NOW at journey start — not at route fetch
    setState(() {
      _journeyActive    = true;
      _alertedKm.clear();
      _arrivalHandled = false;
      _initialDistanceKm  = null;
      _initialDurationMin = null;
      _lastJourneyLocation = null;
      _tripDistanceKm = 0;
      _speedKmh = null;
      _journeyStopwatch = Stopwatch()..start();
    });
    _saveHistory();

    _armGpsWatchdog();

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final e = _journeyStopwatch.elapsed;
      setState(() {
        _elapsed =
          '${e.inMinutes.toString().padLeft(2,'0')}:${(e.inSeconds % 60).toString().padLeft(2,'0')}';
      });
    });
  }

  void _updateDistance(LatLng ll) {
    final d = BackgroundLocationService.distanceTo(ll);
    if (d == null) return;

    // Bug 3 fix: if d is valid we have GPS — update display
    setState(() => _routeDistance = '${d.toStringAsFixed(2)} km');
    _recordJourneyMetrics(ll);

    // Bug 2 fix: update ETA proportionally based on remaining distance
    // Uses the initial estimate as a baseline ratio (simple but honest)
    _updateEta(d);

    _checkThresholds(d);

    // Auto-arrive when within 200 m — silent notification, no alarm
    if (d <= 0.2 && _journeyActive && !_arrivalHandled) {
      _arrivalHandled = true;
      _notifyArrival();
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted && _journeyActive) _stopJourney();
      });
    }
  }

  void _recordJourneyMetrics(LatLng location) {
    final previous = _lastJourneyLocation;
    if (previous != null) {
      final legKm = Geolocator.distanceBetween(
        previous.latitude, previous.longitude, location.latitude, location.longitude,
      ) / 1000;
      // Discard impossible GPS jumps; normal native updates are 5 seconds apart.
      if (legKm <= 0.5) _tripDistanceKm += legKm;
    }
    _lastJourneyLocation = location;
    final speed = BackgroundLocationService.speedKmh;
    if (speed != null && speed >= 0 && speed < 200) {
      setState(() => _speedKmh = speed);
    }
  }

  // Bug 3 fix: GPS fallback — if native service provides no updates after
  // 30 seconds, restart a Flutter-side stream as backup
  void _armGpsWatchdog() {
    _gpsWatchdog?.cancel();
    _gpsWatchdog = Timer(const Duration(seconds: 30), () {
      if (!_journeyActive || !mounted) return;
      // Native GPS may be unavailable — start Flutter fallback stream
      _locationSub ??= Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 20,
        ),
      ).listen((pos) {
        if (!_journeyActive || !mounted) return;
        final ll = LatLng(pos.latitude, pos.longitude);
        setState(() => _currentLatLng = ll);
        _updateDistance(ll);
      });
    });
  }

  // Bug 2 fix: recalculate ETA proportionally from initial estimate
  void _updateEta(double currentKm) {
    // Capture baseline on first valid distance during journey
    if (_initialDistanceKm == null) {
      final parsed = double.tryParse(
        _routeDistance?.replaceAll(' km', '') ?? '');
      if (parsed != null && parsed > 0) {
        _initialDistanceKm  = parsed;
        _initialDurationMin = double.tryParse(
          _routeDuration?.replaceAll(' min', '') ?? '');
      }
      return;
    }
    if (_initialDurationMin == null || _initialDistanceKm! <= 0) return;
    final ratio         = currentKm / _initialDistanceKm!;
    final remainingMin  = (_initialDurationMin! * ratio).clamp(0, double.infinity);
    setState(() => _routeDuration =
      '${remainingMin.toStringAsFixed(0)} min');
  }

  void _checkThresholds(double km) {
    for (final t in _alertDistances) {
      if (km <= t && !_alertedKm.contains(t)) {
        _alertedKm.add(t);
        _triggerAlert(t);
      }
    }
  }

  void _stopJourney() {
    BackgroundLocationService.stop();
    _clockTimer?.cancel();
    _locationSub?.cancel();
    _gpsWatchdog?.cancel();
    _stopAlarm();
    setState(() {
      _journeyActive      = false;
      _arrivalHandled     = false;
      _elapsed            = '00:00';
      _initialDistanceKm  = null;
      _initialDurationMin = null;
      _lastJourneyLocation = null;
      _tripDistanceKm = 0;
      _speedKmh = null;
      _journeyStopwatch.stop();
      _alertedKm.clear();
      _destinationLatLng = null;
      _destinationName   = '';
      _routeDistance     = null;
      _routeDuration     = null;
    });
    _destController.clear();
    _startPassiveLocation();
  }

  // ── Alarm ────────────────────────────────────────────────────────────────

  Future<void> _triggerAlert(int km) async {
    await _notifications.show(
      km,
      km == 1 ? '⚡ Almost there!' : 'Approaching stop',
      km == 1 ? 'Within 1 km of destination!' : 'Within $km km.',
      NotificationDetails(
        android: AndroidNotificationDetails(
          'busnap_alerts', 'Busnap Alerts',
          channelDescription: 'Proximity alerts',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          actions: const [
            AndroidNotificationAction(
              'stop_alarm',
              'Stop alarm',
              cancelNotification: true,
              showsUserInterface: false,
            ),
          ],
        ),
        iOS: DarwinNotificationDetails(presentSound: true),
      ),
    );
    _startAlarm();
  }

  /// Silent arrival notification — no sound, no vibration, no alarm.
  Future<void> _notifyArrival() async {
    await _notifications.show(
      0,
      '📍 You have arrived!',
      _destinationName.isNotEmpty ? _destinationName : 'You reached your destination.',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'busnap_alerts', 'Busnap Alerts',
          channelDescription: 'Proximity alerts',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
          playSound: false,
          enableVibration: true,
        ),
        iOS: DarwinNotificationDetails(presentSound: false),
      ),
    );
  }

  Future<void> _startAlarm() async {
    if (_isAlarmPlaying || !_journeyActive || !mounted) return;
    setState(() => _isAlarmPlaying = true);
    _alarmTimer?.cancel();
    _alarmCompleteSub?.cancel();
    final prefs = await SharedPreferences.getInstance();
    if (!_journeyActive || !mounted) return;
    final path  = prefs.getString('alarm_file_path');
    Future<void> play() async {
      if (!_journeyActive || !mounted) return;
      try {
        await _audioPlayer.play(path != null ? DeviceFileSource(path) : AssetSource('alarm.mp3'));
      } catch (_) {
        await _audioPlayer.play(AssetSource('alarm.mp3'));
      }
    }
    _alarmCompleteSub = _audioPlayer.onPlayerComplete.listen((_) { if (_isAlarmPlaying) play(); });
    await play();
    _alarmTimer = Timer(const Duration(minutes: 1), _stopAlarm);
  }

  void _stopAlarm() {
    _audioPlayer.stop();
    _alarmTimer?.cancel();
    _alarmCompleteSub?.cancel();
    if (mounted) setState(() => _isAlarmPlaying = false);
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: error ? AppTheme.danger : AppTheme.ink,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      margin: const EdgeInsets.all(12),
    ));
  }

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // ── Radial gradient background ──────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment(0.0, -0.4),
                  radius: 1.2,
                  colors: [AppTheme.gradCentre, AppTheme.gradEdge],
                  stops: [0.0, 1.0],
                ),
              ),
            ),
          ),
          // ── Subtle accent glow top-right ────────────────────────────
          Positioned(
            top: -60, right: -40,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppTheme.accent.withValues(alpha: 0.07),
                    AppTheme.accent.withValues(alpha: 0.0),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: -110, bottom: 50,
            child: IgnorePointer(
              child: Container(
                width: 290, height: 290,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFF72D69C).withValues(alpha: 0.22),
                    const Color(0x0072D69C),
                  ]),
                ),
              ),
            ),
          ),
          // ── Content ─────────────────────────────────────────────────
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    layoutBuilder: (currentChild, previousChildren) => Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.topCenter,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    ),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(
                        scale: Tween<double>(begin: 0.98, end: 1).animate(animation),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_journeyActive),
                      child: _journeyActive ? _buildJourneyView() : _buildSearchView(),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Glass card helper ─────────────────────────────────────────────────────

  Widget _glass({
    required Widget child,
    double radius = 20,
    EdgeInsets padding = const EdgeInsets.all(20),
    Color? fill,
    Color? border,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: fill ?? AppTheme.glassFill,
            borderRadius: BorderRadius.circular(radius),
                border: Border.all(color: border ?? Colors.transparent),
            boxShadow: const [
                BoxShadow(color: AppTheme.glassShadow, blurRadius: 22, offset: Offset(0, 10)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset('assets/logo.png', width: 36, height: 36, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          const Text('Busnap',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800,
                color: AppTheme.ink, letterSpacing: -0.5)),
          const Spacer(),
          if (_isAlarmPlaying)
            GestureDetector(
              onTap: _stopAlarm,
              child: _glass(
                radius: 22, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                fill: AppTheme.dangerLight, border: AppTheme.danger.withValues(alpha: 0.3),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.stop_rounded, color: AppTheme.danger, size: 14),
                  SizedBox(width: 5),
                  Text('Stop Alarm', style: TextStyle(color: AppTheme.danger,
                      fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          if (!_isAlarmPlaying)
            GestureDetector(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AlarmSettingsScreen()))
                  .then((_) => _loadPreferences()),
              child: _glass(
                radius: 12, padding: const EdgeInsets.all(10),
                child: const Icon(Icons.tune_rounded, color: AppTheme.ink, size: 20),
              ),
            ),
        ],
      ),
    );
  }

  // ── Search view ───────────────────────────────────────────────────────────

  Widget _buildSearchView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSearchCard(),
          if (_isSearching) ...[
            const SizedBox(height: 10),
            _glass(
              radius: 18,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: const Row(children: [
                SizedBox(width: 16, height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent)),
                SizedBox(width: 10),
                Text('Finding places nearby...', style: TextStyle(
                    color: AppTheme.inkSecondary, fontSize: 13, fontWeight: FontWeight.w600)),
              ]),
            ),
          ],
          if (_history.isNotEmpty && _destinationLatLng == null) ...[
            const SizedBox(height: 12),
            _buildHistory(),
          ],
          if (_showSuggestions) ...[
            const SizedBox(height: 6),
            _buildSuggestions(),
          ],
          if (!_showSuggestions && _destinationLatLng != null) ...[
            const SizedBox(height: 16),
            _buildRouteCard(),
          ],
          if (!_showSuggestions && _destinationLatLng != null
              && !_isFetchingRoute && _routeDistance != null) ...[
            const SizedBox(height: 16),
            _buildStartBtn(),
          ],
          const SizedBox(height: 48),
          _buildHint(),
        ],
      ),
    );
  }

  Widget _buildSearchCard() {
    return _glass(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Where are you going?',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                color: AppTheme.inkSecondary, letterSpacing: 0.8)),
          const SizedBox(height: 10),
          TextField(
            controller: _destController,
            focusNode: _destFocus,
            onChanged: _onSearchChanged,
            onSubmitted: (v) {
              if (_suggestions.isNotEmpty) _selectSuggestion(_suggestions.first);
            },
            style: const TextStyle(fontSize: 15, color: AppTheme.ink, fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              hintText: 'Search for a place...',
              prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.inkMuted, size: 20),
              suffixIcon: _isSearching
                ? const Padding(
                    padding: EdgeInsets.all(14),
                    child: SizedBox(width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent)),
                  )
                : _destController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppTheme.inkMuted, size: 18),
                    onPressed: _clearDestination)
                : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return _glass(
      padding: EdgeInsets.zero,
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) => const Divider(height: 1, color: AppTheme.glassBorder),
        itemBuilder: (_, i) {
          final s = _suggestions[i];
          return InkWell(
            onTap: () => _selectSuggestion(s),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: Row(
                children: [
                  Container(
                    width: 28, height: 28,
                    decoration: BoxDecoration(
                      color: AppTheme.accentLight,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.place_rounded, color: AppTheme.accent, size: 14),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(s.displayName, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13, color: AppTheme.ink, height: 1.3)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHistory() {
    return _glass(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 4, 16, 8),
          child: Text('RECENT DESTINATIONS', style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.inkMuted, letterSpacing: 1)),
        ),
        ..._history.map((item) => ListTile(
          dense: true,
          leading: const Icon(Icons.history_rounded, size: 18, color: AppTheme.inkSecondary),
          title: Text(item.name, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          onTap: () => _selectSuggestion(PlaceSuggestion(displayName: item.name, latLng: item.latLng)),
        )),
      ]),
    );
  }

  Widget _buildRouteCard() {
    if (_waitingForRoute) {
      return _glass(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: const Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            SizedBox(width: 22, height: 22,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.accent)),
            SizedBox(height: 12),
            Text('Getting your current location...',
              style: TextStyle(color: AppTheme.inkSecondary, fontSize: 13)),
          ]),
        ),
      );
    }
    if (_isFetchingRoute) {
      return _glass(
        padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
        child: const Center(
          child: Column(mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center, children: [
          SizedBox(width: 20, height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.ink)),
          SizedBox(height: 12),
          Text('Calculating...', style: TextStyle(color: AppTheme.inkSecondary, fontSize: 13)),
        ]),
        ),
      );
    }
    if (_routeDistance == null) return const SizedBox.shrink();
    return _glass(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 28, height: 28,
            decoration: BoxDecoration(color: AppTheme.accentLight, borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.place_rounded, color: AppTheme.accent, size: 14)),
          const SizedBox(width: 10),
          Expanded(child: Text(_destinationName, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.ink))),
        ]),
        const SizedBox(height: 14),
        Row(children: [
          Expanded(child: _statChip(Icons.straighten_rounded, 'Distance', _routeDistance ?? '—')),
          const SizedBox(width: 10),
          Expanded(child: _statChip(Icons.schedule_rounded, 'ETA', _routeDuration ?? '—')),
        ]),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppTheme.accentLight,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(children: [
            Icon(Icons.notifications_rounded, color: AppTheme.accent, size: 13),
            SizedBox(width: 6),
            Text('Alerts at ${_alertDistances.map((d) => '$d km').join(', ')}',
              style: TextStyle(fontSize: 12, color: AppTheme.accent, fontWeight: FontWeight.w500)),
          ]),
        ),
      ]),
    );
  }

  Widget _statChip(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
      decoration: BoxDecoration(
        color: AppTheme.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.glassBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 11, color: AppTheme.inkMuted),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 10,
              color: AppTheme.inkMuted, fontWeight: FontWeight.w600, letterSpacing: 0.3)),
        ]),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800,
            color: AppTheme.ink, letterSpacing: -0.3)),
      ]),
    );
  }

  Widget _buildStartBtn() {
    return SizedBox(
      height: 54,
      child: ElevatedButton.icon(
        onPressed: _startJourney,
        icon: const Icon(Icons.directions_bus_rounded, size: 18),
        label: const Text('Start Journey'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          elevation: 5,
          shadowColor: AppTheme.accent.withValues(alpha: 0.35),
        ),
      ),
    );
  }

  Widget _buildHint() {
    if (_destinationLatLng != null) return const SizedBox.shrink();
    final locationReady = _currentLatLng != null;
    return _glass(
      radius: 24,
      padding: const EdgeInsets.all(20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(
              color: AppTheme.accentLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.directions_bus_rounded, color: AppTheme.accent, size: 25),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Ready to travel',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.ink)),
            const SizedBox(height: 3),
            Text(locationReady ? 'Your location is ready' : 'Getting your location...',
              style: const TextStyle(fontSize: 13, color: AppTheme.inkSecondary)),
          ])),
          Icon(locationReady ? Icons.check_circle_rounded : Icons.location_searching_rounded,
            color: locationReady ? AppTheme.accent : AppTheme.inkMuted, size: 22),
        ]),
        const SizedBox(height: 20),
        const Text('HOW IT WORKS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800,
            color: AppTheme.inkMuted, letterSpacing: 1.1)),
        const SizedBox(height: 12),
        const Row(children: [
          _JourneyStep(number: '1', label: 'Search'),
          _StepLine(),
          _JourneyStep(number: '2', label: 'Start'),
          _StepLine(),
          _JourneyStep(number: '3', label: 'Alerts'),
        ]),
      ]),
    );
  }

  // ── Journey dashboard ─────────────────────────────────────────────────────

  Widget _journeyGlass({
    required Widget child,
    EdgeInsets padding = const EdgeInsets.all(16),
    double radius = 20,
    Color tint = Colors.white,
    Color? border,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [tint.withValues(alpha: 0.80), tint.withValues(alpha: 0.48)],
            ),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: border ?? Colors.white.withValues(alpha: 0.72)),
            boxShadow: const [
              BoxShadow(color: AppTheme.glassShadow, blurRadius: 18, offset: Offset(0, 8)),
            ],
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _journeyStat(IconData icon, String label, String value) {
    return _journeyGlass(
      radius: 18,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 13, color: AppTheme.inkMuted),
          const SizedBox(width: 5),
          Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.inkMuted,
              fontWeight: FontWeight.w700, letterSpacing: 0.6)),
        ]),
        const SizedBox(height: 7),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: Text(value, key: ValueKey(value), style: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.ink)),
        ),
      ]),
    );
  }

  Widget _buildJourneyView() {
    final raw      = _routeDistance?.replaceAll(' km', '') ?? '—';
    final isClose  = _alertedKm.contains(1);
    final isNear   = _alertedKm.contains(2) && !isClose;

    Color numColor  = AppTheme.ink;
    Color cardFill  = Colors.white.withValues(alpha: 0.58);
    Color cardBdr   = Colors.white.withValues(alpha: 0.78);
    Color accentCol = AppTheme.ink;
    String status   = '';

    if (isClose) {
      numColor  = AppTheme.danger;
      cardFill  = AppTheme.dangerLight;
      cardBdr   = AppTheme.danger.withValues(alpha: 0.3);
      accentCol = AppTheme.danger;
      status    = '⚡ Almost there!';
    } else if (isNear) {
      numColor  = AppTheme.warning;
      cardFill  = AppTheme.warningLight;
      cardBdr   = AppTheme.warning.withValues(alpha: 0.3);
      accentCol = AppTheme.warning;
      status    = '🔔 Getting close';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [

        // Destination label
        _journeyGlass(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          radius: 14,
          child: Row(children: [
            Container(width: 6, height: 6,
              decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle)),
            const SizedBox(width: 10),
            Expanded(child: Text(_destinationName, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.ink))),
          ]),
        ),
        const SizedBox(height: 16),

        // Big distance
        ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 24),
              decoration: BoxDecoration(
                color: cardFill, borderRadius: BorderRadius.circular(24),
                border: Border.all(color: cardBdr),
                boxShadow: const [BoxShadow(color: AppTheme.glassShadow, blurRadius: 20, offset: Offset(0, 6))],
              ),
              child: Column(children: [
                Text('DISTANCE REMAINING', style: TextStyle(fontSize: 10,
                    fontWeight: FontWeight.w700, color: AppTheme.inkMuted, letterSpacing: 1.5)),
                const SizedBox(height: 10),
                Row(mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end, children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: Text(raw, key: ValueKey(raw), style: TextStyle(fontSize: 80,
                        fontWeight: FontWeight.w900, color: numColor, letterSpacing: -4, height: 1)),
                  ),
                  const SizedBox(width: 6),
                  Padding(padding: const EdgeInsets.only(bottom: 14),
                    child: Text('km', style: TextStyle(fontSize: 20,
                        fontWeight: FontWeight.w600, color: AppTheme.inkSecondary))),
                ]),
                if (status.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: accentCol.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: accentCol.withValues(alpha: 0.25)),
                    ),
                    child: Text(status, style: TextStyle(fontSize: 13,
                        fontWeight: FontWeight.w700, color: accentCol)),
                  ),
                ],
              ]),
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Live journey metrics
        Row(children: [
          Expanded(child: _journeyStat(Icons.schedule_rounded, 'ETA', _routeDuration ?? '—')),
          const SizedBox(width: 12),
          Expanded(child: _journeyStat(Icons.speed_rounded, 'SPEED',
              _speedKmh == null ? '—' : '${_speedKmh!.round()} km/h')),
        ]),
        const SizedBox(height: 12),
        Row(children: [
          Expanded(child: _journeyStat(Icons.route_rounded, 'ODOMETER',
              '${_tripDistanceKm.toStringAsFixed(2)} km')),
          const SizedBox(width: 12),
          Expanded(child: _journeyStat(Icons.timer_rounded, 'ON JOURNEY', _elapsed)),
        ]),
        const SizedBox(height: 12),

        // Alert badges
        _journeyGlass(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          radius: 14,
          child: Row(children: [
            const Text('ALERTS', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                color: AppTheme.inkMuted, letterSpacing: 1.2)),
            const Spacer(),
            ..._alertDistances.map((km) {
              final hit = _alertedKm.contains(km);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(left: 6),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: hit ? AppTheme.ink : AppTheme.bg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: hit ? AppTheme.ink : AppTheme.glassBorder),
                ),
                child: Text('${km}km', style: TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: hit ? AppTheme.bg : AppTheme.inkMuted)),
              );
            }),
          ]),
        ),
        const SizedBox(height: 20),

        // End journey
        SizedBox(
          height: 54,
          child: OutlinedButton.icon(
            onPressed: _stopJourney,
            icon: const Icon(Icons.stop_circle_outlined, size: 18),
            label: const Text('End Journey'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.danger,
              side: BorderSide(color: AppTheme.danger.withValues(alpha: 0.5), width: 1.5),
              backgroundColor: AppTheme.dangerLight,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ]),
    );
  }
}
