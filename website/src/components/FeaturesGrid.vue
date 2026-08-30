<script setup lang="ts">
import { 
  BellRing, 
  ShieldCheck, 
  Route, 
  BatteryCharging, 
  Music, 
  Sparkles
} from 'lucide-vue-next'

const features = [
  {
    title: 'Multi-Stage Progressive Alarms',
    description: 'Never get startled or jump off unprepared. Busnap triggers tiered alerts at 5km (notification), 2km (preparation), and 1km (full wake-up alarm).',
    icon: BellRing,
    badge: 'Core Feature',
    gradient: 'from-emerald-500/10 via-emerald-500/5 to-transparent',
    colSpan: 'lg:col-span-8',
    highlight: '5 km ➔ 2 km ➔ 1 km'
  },
  {
    title: '100% Private & Zero Accounts',
    description: 'No email required. No passwords. No advertising trackers. Your GPS coordinates stay strictly on your phone.',
    icon: ShieldCheck,
    badge: 'Privacy First',
    gradient: 'from-teal-500/10 via-teal-500/5 to-transparent',
    colSpan: 'lg:col-span-4',
    highlight: 'Zero Telemetry'
  },
  {
    title: 'True Road Route Distances',
    description: 'Unlike primitive radius apps that use straight-line ("as the crow flies") distance, Busnap calculates the actual road journey distance via OpenStreetMap & OSRM.',
    icon: Route,
    badge: 'Smart OSM Routing',
    gradient: 'from-blue-500/10 via-blue-500/5 to-transparent',
    colSpan: 'lg:col-span-4',
    highlight: 'OSRM / Valhalla'
  },
  {
    title: 'Battery-Optimized Background Service',
    description: 'Uses native Android Foreground Services with smart throttling to keep battery consumption well under 1% for regular bus commutes.',
    icon: BatteryCharging,
    badge: '< 1% Drain',
    gradient: 'from-emerald-500/10 via-emerald-500/5 to-transparent',
    colSpan: 'lg:col-span-4',
    highlight: 'Foreground GPS'
  },
  {
    title: 'Custom Wakeup Alarm Tones',
    description: 'Heavy sleeper? Pick any custom audio track from your device (MP3, WAV, OGG, M4A) to make sure you never sleep through your stop.',
    icon: Music,
    badge: 'Audio Picker',
    gradient: 'from-purple-500/10 via-purple-500/5 to-transparent',
    colSpan: 'lg:col-span-4',
    highlight: 'MP3 / WAV / OGG'
  }
]
</script>

<template>
  <section id="features" class="py-16 sm:py-24 px-4 sm:px-6 max-w-7xl mx-auto scroll-mt-20">
    <!-- Section Header -->
    <div class="text-center max-w-2xl mx-auto space-y-3 mb-14">
      <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#1DB56A]/10 text-[#1DB56A] text-xs font-bold uppercase tracking-wider">
        <Sparkles class="w-3.5 h-3.5" />
        Built for Stress-Free Commuting
      </div>
      <h2 class="text-3xl sm:text-4xl font-extrabold text-[#17251C] dark:text-white tracking-tight">
        Engineered for peace of mind
      </h2>
      <p class="text-sm sm:text-base text-[#526458] dark:text-[#A4B8AB]">
        Every feature in Busnap is designed to do one job perfectly: wake you up right before your transit stop without invading your privacy.
      </p>
    </div>

    <!-- Bento Grid -->
    <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-12 gap-6">
      <div 
        v-for="f in features" 
        :key="f.title"
        :class="[f.colSpan, 'liquid-card rounded-3xl p-6 sm:p-8 flex flex-col justify-between relative overflow-hidden group']"
      >
        <!-- Card Background Gradient -->
        <div class="absolute inset-0 bg-gradient-to-br opacity-60 pointer-events-none group-hover:opacity-100 transition-opacity" :class="f.gradient"></div>

        <div>
          <!-- Top Row: Icon and Badge -->
          <div class="flex items-center justify-between mb-6 relative z-10">
            <div class="w-12 h-12 rounded-2xl bg-white dark:bg-[#182c20] shadow-md border border-emerald-500/20 text-[#1DB56A] flex items-center justify-center group-hover:scale-110 group-hover:bg-[#1DB56A] group-hover:text-white transition-all duration-300">
              <component :is="f.icon" class="w-6 h-6" />
            </div>
            <span class="text-xs font-bold px-3 py-1 rounded-full bg-emerald-500/10 text-emerald-700 dark:text-emerald-300 border border-emerald-500/20">
              {{ f.badge }}
            </span>
          </div>

          <!-- Title & Description -->
          <h3 class="text-xl font-bold text-[#17251C] dark:text-white mb-2.5 relative z-10">
            {{ f.title }}
          </h3>
          <p class="text-sm text-[#526458] dark:text-[#A4B8AB] leading-relaxed relative z-10">
            {{ f.description }}
          </p>
        </div>

        <!-- Bottom Highlight Tag -->
        <div class="mt-6 pt-4 border-t border-black/5 dark:border-white/5 flex items-center justify-between text-xs relative z-10">
          <span class="text-[#8A9C90] font-medium">Capability</span>
          <span class="font-mono font-bold text-[#1DB56A]">{{ f.highlight }}</span>
        </div>
      </div>
    </div>
  </section>
</template>
