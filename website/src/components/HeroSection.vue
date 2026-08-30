<script setup lang="ts">
import { 
  Play, 
  Sparkles, 
  Battery,
  MapPinOff
} from 'lucide-vue-next'
import PhoneMockup from './PhoneMockup.vue'
</script>

<template>
  <section class="relative pt-28 sm:pt-36 lg:pt-40 pb-16 lg:pb-24 px-4 sm:px-6 max-w-7xl mx-auto overflow-hidden">
    
    <!-- Background Glow Blobs -->
    <div class="absolute top-1/4 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] sm:w-[700px] h-[500px] sm:h-[700px] bg-emerald-400/15 dark:bg-emerald-500/10 blur-[120px] rounded-full pointer-events-none -z-10"></div>
    <div class="absolute top-1/3 right-10 w-72 h-72 bg-teal-400/10 blur-[90px] rounded-full pointer-events-none -z-10"></div>

    <div class="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
      
      <!-- Left Content Column -->
      <div class="lg:col-span-7 text-center lg:text-left space-y-6 sm:space-y-8">
        
        <!-- Pill Badge -->
        <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full liquid-glass shadow-sm border border-emerald-500/30 text-xs sm:text-sm font-semibold text-[#DCF8E7]">
          <span class="flex h-2 w-2 relative">
            <span class="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
            <span class="relative inline-flex rounded-full h-2 w-2 bg-[#1DB56A]"></span>
          </span>
          <span>Zero Tracking • 100% On-Device GPS • Open Source</span>
        </div>

        <!-- Main Headline -->
        <h1 class="text-4xl sm:text-5xl lg:text-6xl font-extrabold tracking-tight text-white leading-[1.12]">
          Nap peacefully on your commute.
          <span class="block mt-1 sm:mt-2 bg-gradient-to-r from-[#1DB56A] via-[#34d399] to-[#059669] bg-clip-text text-transparent">
            Never miss your stop.
          </span>
        </h1>

        <!-- Subheading Description -->
        <p class="text-base sm:text-lg lg:text-xl text-[#A4B8AB] max-w-2xl mx-auto lg:mx-0 leading-relaxed font-normal">
          Busnap tracks your transit journey silently in the background and rings smart, progressive proximity alarms at 
          <strong class="text-white font-semibold">5 km</strong>, 
          <strong class="text-white font-semibold">2 km</strong>, and 
          <strong class="text-white font-semibold">1 km</strong> before your stop. No accounts, no data telemetry.
        </p>

        <!-- CTA Action Buttons -->
        <div class="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-3 sm:gap-4 pt-2">
          <!-- Download Button -->
          <a 
            href="https://play.google.com/store/apps/details?id=com.busnap.app" 
            target="_blank"
            rel="noopener noreferrer"
            class="w-full sm:w-auto bg-[#1DB56A] hover:bg-[#189b5a] active:scale-95 text-white font-bold text-base px-7 py-3.5 rounded-xl shadow-lg shadow-[#1DB56A]/30 hover:shadow-xl hover:shadow-[#1DB56A]/40 transition-all flex items-center justify-center gap-2.5 group cursor-pointer"
          >
            <!-- Google Play Icon -->
            <svg class="w-5 h-5 fill-current" viewBox="0 0 24 24">
              <path d="M3.609 1.814L13.792 12 3.61 22.186a1.986 1.986 0 0 1-.22-.924V2.738c0-.34.08-.656.22-.924zm11.242 11.243l2.484 2.484-9.98 5.717 7.496-8.201zm0-2.114L7.355 2.742l9.98 5.717-2.484 2.484zm1.485 1.057l3.666 2.1a1.218 1.218 0 0 1 0 2.176l-3.666 2.1-1.748-1.748 1.748-4.628z"/>
            </svg>
            <span>Get on Google Play</span>
          </a>

          <!-- Live Simulator Button -->
          <a 
            href="#simulator" 
            class="w-full sm:w-auto liquid-glass hover:border-[#1DB56A]/50 text-white font-semibold text-base px-6 py-3.5 rounded-xl shadow-sm hover:shadow-md transition-all flex items-center justify-center gap-2 group cursor-pointer"
          >
            <Play class="w-4 h-4 text-[#1DB56A] fill-[#1DB56A] group-hover:scale-110 transition-transform" />
            <span>Try Interactive Simulator</span>
          </a>
        </div>

        <!-- Trust Badges List -->
        <div class="pt-4 border-t border-emerald-500/10 grid grid-cols-3 gap-2 sm:gap-4 max-w-xl mx-auto lg:mx-0">
          <div class="flex items-center gap-2 justify-center lg:justify-start">
            <div class="p-1.5 rounded-lg bg-emerald-500/10 text-[#1DB56A]">
              <MapPinOff class="w-4 h-4" />
            </div>
            <div class="text-left">
              <div class="text-xs font-bold text-white">No Cloud</div>
              <div class="text-[11px] text-[#8A9C90]">Zero Tracking</div>
            </div>
          </div>

          <div class="flex items-center gap-2 justify-center lg:justify-start">
            <div class="p-1.5 rounded-lg bg-emerald-500/10 text-[#1DB56A]">
              <Battery class="w-4 h-4" />
            </div>
            <div class="text-left">
              <div class="text-xs font-bold text-white">&lt; 1% Battery</div>
              <div class="text-[11px] text-[#8A9C90]">Optimized GPS</div>
            </div>
          </div>

          <div class="flex items-center gap-2 justify-center lg:justify-start">
            <div class="p-1.5 rounded-lg bg-emerald-500/10 text-[#1DB56A]">
              <Sparkles class="w-4 h-4" />
            </div>
            <div class="text-left">
              <div class="text-xs font-bold text-white">100% Free</div>
              <div class="text-[11px] text-[#8A9C90]">MIT License</div>
            </div>
          </div>
        </div>

      </div>

      <!-- Right Visual Column (Phone Mockup) -->
      <div class="lg:col-span-5 flex justify-center lg:justify-end">
        <PhoneMockup />
      </div>

    </div>
  </section>
</template>
