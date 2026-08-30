<script setup lang="ts">
import { ref } from 'vue'
import { 
  Navigation, 
  Volume2, 
  MapPin, 
  BatteryCharging, 
  Wifi, 
  Signal, 
  Clock, 
  ShieldCheck
} from 'lucide-vue-next'
import { useAudio } from '../composables/useAudio'

const { isPlaying, toggleSound, playChime } = useAudio()
const activeStagePreview = ref<number>(1) // 1 (5km), 2 (2km), 3 (1km)

const selectStage = (stage: number) => {
  activeStagePreview.value = stage
  if (stage === 1) playChime('info')
  else if (stage === 2) playChime('warning')
  else if (stage === 3) playChime('alarm')
}

const triggerTestAlarm = () => {
  toggleSound('/alarm.mp3')
}
</script>

<template>
  <div class="relative mx-auto w-full max-w-[320px] sm:max-w-[340px] md:max-w-[360px] select-none py-4 sm:py-6">
    
    <!-- Ambient Phone Glow -->
    <div class="absolute inset-0 bg-[#1DB56A]/20 blur-3xl rounded-full pointer-events-none -z-10"></div>

    <!-- Floating Badge (Top Right) - Positioned with clean clearance -->
    <div class="absolute -top-1 sm:top-6 -right-2 sm:-right-8 liquid-glass px-3.5 py-2 rounded-xl shadow-2xl border border-emerald-500/30 flex items-center gap-2 animate-float z-30">
      <div class="p-1 rounded-lg bg-emerald-500/20 text-[#1DB56A]">
        <ShieldCheck class="w-3.5 h-3.5" />
      </div>
      <div class="text-left">
        <div class="text-[11px] font-bold text-white leading-none">100% On-Device</div>
        <div class="text-[9px] text-[#8A9C90] mt-0.5">No Cloud Telemetry</div>
      </div>
    </div>

    <!-- Floating Badge (Bottom Left) - Positioned with clean clearance -->
    <div class="absolute -bottom-2 sm:bottom-12 -left-2 sm:-left-8 liquid-glass px-3.5 py-2 rounded-xl shadow-2xl border border-emerald-500/30 flex items-center gap-2 animate-float z-30" style="animation-delay: 2.5s;">
      <div class="w-2.5 h-2.5 rounded-full bg-emerald-400 animate-pulse"></div>
      <div class="text-left">
        <div class="text-[11px] font-bold text-white leading-none">Background GPS</div>
        <div class="text-[9px] text-[#8A9C90] mt-0.5">&lt; 1% Battery Drain</div>
      </div>
    </div>

    <!-- Outer Phone Bezel with Titanium/Glass Glow -->
    <div class="relative rounded-[44px] p-3.5 bg-gradient-to-b from-[#223629] via-[#122017] to-[#09100c] shadow-[0_30px_70px_-15px_rgba(0,0,0,0.8)] ring-1 ring-white/15">
      
      <!-- Hardware side button accents -->
      <div class="absolute -left-[2.5px] top-24 w-[2.5px] h-8 bg-[#334d3c] rounded-l-sm"></div>
      <div class="absolute -left-[2.5px] top-36 w-[2.5px] h-11 bg-[#334d3c] rounded-l-sm"></div>
      <div class="absolute -right-[2.5px] top-28 w-[2.5px] h-12 bg-[#334d3c] rounded-r-sm"></div>

      <!-- Phone Screen Container -->
      <div class="relative rounded-[34px] bg-[#0c1611] overflow-hidden border border-emerald-500/20 text-[#E8F2EC] flex flex-col h-[570px] sm:h-[600px]">
        
        <!-- Status Bar -->
        <div class="pt-3 px-5 pb-1 flex items-center justify-between text-[11px] font-medium text-[#8A9C90] z-20">
          <span>09:41</span>
          <!-- Dynamic Island cutout -->
          <div class="w-20 h-4 bg-black rounded-full mx-auto flex items-center justify-center">
            <div class="w-1.5 h-1.5 rounded-full bg-emerald-500/60 mr-2"></div>
            <div class="w-2 h-2 rounded-full bg-[#16241b] border border-white/20"></div>
          </div>
          <div class="flex items-center gap-1.5">
            <Signal class="w-3 h-3" />
            <Wifi class="w-3 h-3" />
            <BatteryCharging class="w-3.5 h-3.5 text-[#1DB56A]" />
          </div>
        </div>

        <!-- App Header in Mockup -->
        <div class="px-4 pt-1.5 pb-2.5 flex items-center justify-between z-20">
          <div class="flex items-center gap-2">
            <img src="/logo.png" alt="Busnap" class="w-6 h-6 rounded-md shadow-sm" />
            <span class="font-bold text-sm tracking-tight text-white">Busnap</span>
          </div>
          <div class="flex items-center gap-1.5 bg-[#1DB56A]/20 border border-[#1DB56A]/30 px-2 py-0.5 rounded-full text-[9px] font-bold text-[#1DB56A]">
            <span class="w-1.5 h-1.5 rounded-full bg-[#1DB56A] animate-ping"></span>
            ACTIVE TRACKING
          </div>
        </div>

        <!-- Simulated Map / Route View Area -->
        <div class="relative flex-1 bg-gradient-to-b from-[#112017] to-[#0c1611] overflow-hidden p-3.5 flex flex-col justify-between">
          
          <!-- Map Grid Background SVG -->
          <svg class="absolute inset-0 w-full h-full opacity-25 stroke-[#1DB56A]/40" xmlns="http://www.w3.org/2000/svg">
            <defs>
              <pattern id="phone-grid" width="28" height="28" patternUnits="userSpaceOnUse">
                <path d="M 28 0 L 0 0 0 28" fill="none" stroke-width="0.5" />
              </pattern>
            </defs>
            <rect width="100%" height="100%" fill="url(#phone-grid)" />
            <!-- Route Track Curve -->
            <path d="M 50 480 Q 140 330 170 240 T 250 80" fill="none" stroke="#1DB56A" stroke-width="4" stroke-linecap="round" stroke-dasharray="6,6" class="animate-pulse" />
          </svg>

          <!-- Radar Pulsing Waves at Current Location -->
          <div class="absolute top-[48%] left-1/2 -translate-x-1/2 -translate-y-1/2 pointer-events-none">
            <div class="relative w-36 h-36 flex items-center justify-center">
              <div class="absolute inset-0 rounded-full bg-[#1DB56A]/10 animate-radar"></div>
              <div class="absolute inset-4 rounded-full bg-[#1DB56A]/15 animate-radar" style="animation-delay: 0.8s;"></div>
              <div class="absolute inset-8 rounded-full bg-[#1DB56A]/25 animate-radar" style="animation-delay: 1.6s;"></div>
              
              <!-- Bus Moving Marker -->
              <div class="relative z-10 w-11 h-11 rounded-full bg-[#1DB56A] text-white flex items-center justify-center shadow-lg shadow-[#1DB56A]/50 ring-4 ring-[#0c1611]">
                <Navigation class="w-5 h-5 rotate-45" />
              </div>
            </div>
          </div>

          <!-- Top Destination Status Card -->
          <div class="relative z-10 liquid-glass p-3 rounded-2xl border border-emerald-500/30 shadow-lg">
            <div class="flex items-start gap-2.5">
              <div class="p-2 rounded-xl bg-emerald-500/20 text-[#1DB56A] shrink-0 mt-0.5">
                <MapPin class="w-4 h-4" />
              </div>
              <div class="flex-1 min-w-0">
                <div class="flex items-center justify-between">
                  <span class="text-[9px] uppercase font-bold text-[#8A9C90] tracking-wider">Destination</span>
                  <span class="text-[9px] font-bold text-[#1DB56A] bg-[#1DB56A]/15 px-1.5 py-0.2 rounded">Line 4 Transit</span>
                </div>
                <div class="text-xs font-bold truncate text-white mt-0.5">Central Transit Metro Hub</div>
                <div class="text-[11px] text-[#A4B8AB] flex items-center gap-2 mt-1">
                  <span class="font-mono font-bold text-[#1DB56A]">3.4 km remaining</span>
                  <span>•</span>
                  <span class="flex items-center gap-1"><Clock class="w-3 h-3" /> ETA 5 min</span>
                </div>
              </div>
            </div>

            <!-- Mini Progress Bar on Route -->
            <div class="w-full h-1.5 bg-white/10 rounded-full mt-2.5 overflow-hidden">
              <div class="h-full bg-gradient-to-r from-emerald-500 to-[#1DB56A] w-[66%] rounded-full"></div>
            </div>
          </div>

          <!-- Bottom Action Area -->
          <div class="relative z-10 space-y-2">
            <!-- 3 Proximity Stages Badge Bar (Interactive) -->
            <div class="liquid-glass p-2.5 rounded-2xl border border-emerald-500/25 shadow-md">
              <div class="text-[10px] font-bold text-[#8A9C90] uppercase mb-1.5 flex items-center justify-between">
                <span>Multi-Stage Alert Triggers</span>
                <span class="text-[9px] text-[#1DB56A] font-semibold">Tap to test</span>
              </div>
              <div class="grid grid-cols-3 gap-1 text-center text-[10px]">
                <button 
                  @click="selectStage(1)"
                  class="py-1 px-1 rounded-lg text-emerald-300 font-semibold border transition-all cursor-pointer"
                  :class="activeStagePreview === 1 ? 'bg-emerald-500/30 border-emerald-400 ring-1 ring-emerald-400' : 'bg-emerald-950/40 border-emerald-500/20 hover:bg-emerald-500/20'"
                >
                  <span class="block text-[8px] opacity-75">Step 1</span>
                  5 km (Notif)
                </button>
                <button 
                  @click="selectStage(2)"
                  class="py-1 px-1 rounded-lg text-amber-300 font-semibold border transition-all cursor-pointer"
                  :class="activeStagePreview === 2 ? 'bg-amber-500/30 border-amber-400 ring-1 ring-amber-400' : 'bg-amber-950/40 border-amber-500/20 hover:bg-amber-500/20'"
                >
                  <span class="block text-[8px] opacity-75">Step 2</span>
                  2 km (Prep)
                </button>
                <button 
                  @click="selectStage(3)"
                  class="py-1 px-1 rounded-lg text-rose-300 font-semibold border transition-all cursor-pointer"
                  :class="activeStagePreview === 3 ? 'bg-rose-500/30 border-rose-400 ring-1 ring-rose-400' : 'bg-rose-950/40 border-rose-500/20 hover:bg-rose-500/20'"
                >
                  <span class="block text-[8px] opacity-75">Step 3</span>
                  1 km (Alarm)
                </button>
              </div>
            </div>

            <!-- Sound Preview Button with Equalizer Wave -->
            <button 
              @click="triggerTestAlarm"
              class="w-full py-2.5 px-3 rounded-2xl bg-gradient-to-r from-[#1DB56A] to-[#158f53] hover:from-[#1ebc6f] hover:to-[#179a5a] text-white text-xs font-bold shadow-lg shadow-emerald-500/25 active:scale-98 flex items-center justify-center gap-2 transition-all cursor-pointer"
            >
              <!-- Animated Equalizer Bars when playing -->
              <div v-if="isPlaying" class="flex items-center gap-0.5 h-3.5">
                <span class="w-1 bg-white rounded-full animate-pulse h-2"></span>
                <span class="w-1 bg-white rounded-full animate-pulse h-3.5" style="animation-delay: 0.2s;"></span>
                <span class="w-1 bg-white rounded-full animate-pulse h-2.5" style="animation-delay: 0.4s;"></span>
              </div>
              <Volume2 v-else class="w-4 h-4" />
              <span>{{ isPlaying ? 'Stop Wakeup Tone' : 'Preview Real Wakeup Alarm' }}</span>
            </button>
          </div>

        </div>

        <!-- Phone Home Indicator Bar -->
        <div class="py-2 flex justify-center bg-[#0c1611]">
          <div class="w-24 h-1 bg-white/20 rounded-full"></div>
        </div>

      </div>
    </div>
  </div>
</template>
