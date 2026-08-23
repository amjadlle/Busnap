# Busnap

A Flutter app that alerts you when you're approaching your bus stop.

## What it does

- Set any destination by searching a place name
- Calculates the road route and displays distance + ETA
- Tracks your location during the journey
- Plays an alarm and sends a notification at **5 km**, **2 km**, and **1 km** from the destination
- Supports a custom alarm sound (MP3, WAV, OGG, M4A)

## Project structure

```
lib/
  main.dart                      # App entry, theme
  home_page.dart                 # Main screen (search + journey)
  alarm_settings_screen.dart     # Custom alarm sound picker
  services/
    background_location_service.dart   # Background GPS tracking
    connectivity_service.dart          # Internet check + dialog
    distance_service.dart              # OpenStreetMap routing services
    place_search_service.dart          # Nominatim place search
assets/
  alarm.mp3                      # Default alarm sound
  logo.png                       # App icon
```

## Getting started

```bash
flutter pub get
flutter run
```

Requires a physical Android device or emulator with location enabled.

## Environment

- Flutter SDK `^3.8.1`
- Dart SDK `^3.8.1`
- Target: Android (primary), iOS (supported)

## Permissions required

- `ACCESS_FINE_LOCATION` — GPS tracking
- `ACCESS_BACKGROUND_LOCATION` — tracking while app is in background
- `FOREGROUND_SERVICE` — persistent tracking notification
- `POST_NOTIFICATIONS` — proximity alerts (Android 13+)

## Privacy

Busnap does not include accounts, analytics, advertising, or a Busnap backend.
Recent destinations and alarm preferences are stored locally on the device.
When a place is searched or a route estimate is requested, the search text or
route coordinates are sent to the configured OpenStreetMap-based services
(Nominatim, Valhalla, and OSRM). During an active journey, GPS data is used
locally to calculate distance and trigger alerts; it is not uploaded by Busnap.

You are responsible for reviewing the terms and usage policies of those
third-party services before distributing an app based on this code.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE).
