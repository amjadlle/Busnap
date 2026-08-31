# Busnap — Comprehensive Knowledge Base

## 1. What is Busnap?
Busnap is a smart, free, and open-source location-based proximity alarm application built with Flutter. It is designed for daily transit commuters, students, late-night shift workers, and travelers who take naps, listen to music, or read on buses and trains. Busnap monitors your GPS journey silently in the background and rings progressive alarms before you reach your bus stop so you never miss your destination.

---

## 2. Multi-Stage Progressive Alert System
Unlike basic map apps with a single abrupt alert, Busnap triggers tiered notifications at 3 customizable milestones:
- **🟢 5 km Alert (Heads-Up)**: Sends a gentle notification and single vibration chime reminding you that you are approaching your destination zone.
- **🟡 2 km Alert (Preparation)**: Sends a distinctive preparation reminder to wake up, gather your phone, jacket, and pack your bags.
- **🔴 1 km Alert (Wake-Up Alarm)**: Sounds a loud, continuous alarm and strong vibration to ensure you wake up and step off the bus right on time.

---

## 3. 100% Privacy-First & On-Device Processing
- **No Accounts Required**: Users can immediately search and start a journey without signing up or providing an email.
- **No Cloud Telemetry or Tracking**: GPS coordinates and location data are processed strictly on-device. Busnap does not upload, log, or sell location history.
- **Zero Ads & Analytics**: Free from third-party advertising SDKs and tracking brokers.

---

## 4. True Road Route Distance vs. Straight-Line Radius
- Generic proximity apps use naive straight-line radius ("as the crow flies"), which causes false early alarms when roads curve, loop, or highway detours exist.
- Busnap calculates **actual road network distances** using OpenStreetMap routing services (Nominatim place search, Valhalla, and OSRM turn-by-turn distance calculations).

---

## 5. Battery Optimization & Background Tracking
- **< 1% Battery Consumption**: Uses native Android Foreground Services with adaptive GPS throttling to minimize power drain during 30–60 minute commutes.
- **Works with Screen Locked**: Runs reliably when the phone is locked, asleep in your pocket, or while other apps (Spotify, podcasts, YouTube) are playing.

---

## 6. Custom Alarm Audio Support
- Supports custom alarm audio files from your device storage: **MP3, WAV, OGG, M4A**.
- Users can choose high-volume ringtones, soothing chimes, or loud tones in the Alarm Settings screen.

---

## 7. Permissions Required & Why
- `ACCESS_FINE_LOCATION`: Required for accurate GPS tracking during active journeys.
- `ACCESS_BACKGROUND_LOCATION`: Required to track distance while the phone screen is off or in your pocket.
- `FOREGROUND_SERVICE`: Required to maintain a persistent Android background service so the OS does not kill the tracking task.
- `POST_NOTIFICATIONS`: Required on Android 13+ to deliver alert notifications and sound alarms.

---

## 8. Download & Official Links
- **Google Play Store**: https://play.google.com/store/apps/details?id=com.busnap.app
- **GitHub Repository**: https://github.com/amjadlle/busnap
- **License**: 100% Open Source under the MIT License
- **Direct APK**: Available on GitHub Releases & Google Play Store
- **System Requirements**: Android 8.0 (Oreo) or higher; iOS supported.

---

## 9. Creator & Contact Information
- **Creator**: Amjad P A
- **Role**: Software Engineer & Mobile Developer
- **Email**: hire.amjad@gmail.com
- **Portfolio**: https://amjad.mapki.in
- **GitHub**: https://github.com/amjadlle
- **LinkedIn**: https://linkedin.com/in/amjadlle
- **X / Twitter**: https://x.com/amjadlle
- **YouTube**: https://youtube.com/@reputedculprit

---

## 10. Frequently Asked Questions (FAQ)

### Q: Will Busnap wake me if my phone is on silent mode?
A: Busnap uses the Android Alarm audio stream, which bypasses normal media mute settings to ensure the wake-up alarm is audible when approaching your destination.

### Q: Does it work on trains or subways?
A: Yes! It works on any above-ground transit where GPS satellite lock is maintained. In underground tunnels, it will catch up as soon as the train emerges or reaches surface stops.

### Q: Is Busnap completely free?
A: Yes, 100% free and open-source under the MIT license with zero paid tiers or subscription fees.
