# Busnap Landing Page (Vue 3 + Vite + TypeScript)

This is the modern, responsive landing page for [Busnap](https://github.com/amjadlle/busnap), built with **Vite**, **Vue 3 (Composition API)**, **TypeScript**, and **Tailwind CSS**.

## ✨ Features Included

- **Floating Liquid Glass Navbar:** Compact, pill-shaped frosted glassmorphic navigation bar with blur, subtle emerald border glow, dark/light theme switcher, and mobile hamburger drawer.
- **Hero & Interactive Phone Mockup:** Animated radar pulse, live route mock, destination card, and instant alarm audio test button.
- **Interactive Proximity Alarm Sandbox (`AlarmSimulator.vue`):**
  - Interactive distance slider (10 km &rarr; 0 km) and auto-play journey simulator.
  - Live 3-stage trigger updates:
    - 🟢 **5 km**: Heads-up notification
    - 🟡 **2 km**: Bag packing & prep reminder
    - 🔴 **1 km**: High-volume wake-up alarm
- **Bento Grid Feature Showcase:** Highlight core capabilities (Multi-stage alerts, 100% on-device GPS, battery-saving foreground service, custom audio, OSM road routing).
- **How It Works Flow:** 3-step visual guide.
- **Privacy Comparison Table:** Busnap vs. tracking-heavy commercial map apps.
- **Direct Download & QR Code Section:** APK download button, GitHub release link, and printable QR code for phone scanning.
- **Interactive FAQ Accordion:** Vue transition-powered accordion answering common transit questions.

---

## 🛠️ Development & Local Run

```bash
# Navigate to website directory
cd website

# Install dependencies
npm install

# Start local dev server
npm run dev
```

---

## 🚀 Deploying to Cloudflare Pages

### Method 1: Cloudflare Dashboard (Git Integration)
1. Go to **Cloudflare Dashboard** &rarr; **Compute (Workers & Pages)** &rarr; **Create application** &rarr; **Pages** &rarr; **Connect to Git**.
2. Select your repository.
3. Configure build settings:
   - **Framework preset:** `Vite` (or `None`)
   - **Root directory:** `website`
   - **Build command:** `npm run build`
   - **Build output directory:** `dist`
4. Click **Save and Deploy**.

### Method 2: Direct Deploy via Wrangler CLI
```bash
cd website
npm run build
npx wrangler pages deploy dist --project-name busnap
```
