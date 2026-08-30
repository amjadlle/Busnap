# Busnap

<p align="center">
  <img src="assets/logo.png" alt="Busnap Logo" width="120" />
</p>

<p align="center">
  <strong>A smart, privacy-first proximity alarm Flutter app that wakes you up before reaching your bus stop.</strong>
</p>

<p align="center">
  <a href="https://play.google.com/store/apps/details?id=com.busnap.app">
    <img src="https://img.shields.io/badge/Google_Play-Available_Now-1DB56A?style=for-the-badge&logo=google-play&logoColor=white" alt="Google Play" />
  </a>
  <a href="https://github.com/amjadlle/busnap/releases">
    <img src="https://img.shields.io/badge/APK-Download_v1.0-blue?style=for-the-badge&logo=android&logoColor=white" alt="APK Download" />
  </a>
  <a href="LICENSE">
    <img src="https://img.shields.io/badge/License-MIT-emerald?style=for-the-badge" alt="MIT License" />
  </a>
</p>

---

## ✨ Features

- **Multi-Stage Progressive Alarms**: Plays an alarm and triggers notifications at **5 km** (heads-up), **2 km** (preparation), and **1 km** (wake-up) from your destination.
- **100% On-Device & Zero Tracking**: No accounts, no ads, no telemetry, no backend tracking. GPS math stays strictly on your device.
- **True Road Route Distances**: Calculates turn-by-turn road route distances and accurate ETA using OpenStreetMap (Nominatim, Valhalla, OSRM).
- **Battery-Optimized Background GPS**: Uses native Foreground Services with distance throttling to keep battery drain well under 1%.
- **Custom Wakeup Tones**: Pick your favorite audio file (MP3, WAV, OGG, M4A) from your device storage.

---

## 📱 Google Play Store

Get Busnap on Android directly from Google Play:
👉 **[Download on Google Play](https://play.google.com/store/apps/details?id=com.busnap.app)**

---

## 📂 Project Structure

```
busnap/
├── lib/
│   ├── main.dart                      # App entry, theme
│   ├── home_page.dart                 # Main screen (search + journey)
│   ├── alarm_settings_screen.dart     # Custom alarm sound picker
│   └── services/
│       ├── background_location_service.dart   # Background GPS tracking
│       ├── connectivity_service.dart          # Internet check + dialog
│       ├── distance_service.dart              # OpenStreetMap routing services
│       └── place_search_service.dart          # Nominatim place search
├── assets/
│   ├── alarm.mp3                      # Default alarm sound
│   └── logo.png                       # App icon
└── website/                           # Official Landing Page (Vue 3 + Vite)
    ├── src/                           # Single File Components & Simulator
    └── public/                        # Website assets
```

---

## 🚀 Getting Started with the Mobile App

```bash
flutter pub get
flutter run
```

*Requires an Android device (Android 8.0+) or emulator with location services enabled.*

---

## 🌐 Landing Page Website

The official landing page is built with **Vue 3 (Composition API)**, **Vite**, **TypeScript**, and **Tailwind CSS** in the `website/` directory:

```bash
cd website
npm install
npm run dev
```

To build for **Cloudflare Pages**:
```bash
npm run build
```

---

## 🔐 Permissions Required

- `ACCESS_FINE_LOCATION` — Precise GPS tracking during active journeys
- `ACCESS_BACKGROUND_LOCATION` — Proximity tracking while the screen is locked
- `FOREGROUND_SERVICE` — Persistent background tracking service
- `POST_NOTIFICATIONS` — Proximity notifications (Android 13+)

---

## 🔒 Privacy Policy

Busnap does not collect, sell, or upload your location data. Recent destinations and alarm sound choices are stored locally on your device. During a journey, distance calculations are performed locally on your phone.

---

## 👨‍💻 Author

**Amjad P A**
- 🌐 Portfolio: [amjad.mapki.in](https://amjad.mapki.in)
- 🐙 GitHub: [@amjadlle](https://github.com/amjadlle)
- 💼 LinkedIn: [in/amjadlle](https://linkedin.com/in/amjadlle)
- ✉️ Email: [hire.amjad@gmail.com](mailto:hire.amjad@gmail.com)

---

## 📜 License

This project is open source and licensed under the [MIT License](LICENSE).
