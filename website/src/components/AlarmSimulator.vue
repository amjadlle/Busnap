<script setup lang="ts">
import { ref, computed, watch, onUnmounted } from 'vue'
import { 
  Play, 
  Pause, 
  RotateCcw, 
  Bell, 
  BellRing, 
  Volume2, 
  VolumeX, 
  AlertTriangle, 
  CheckCircle, 
  Radio
} from 'lucide-vue-next'
import { useAudio } from '../composables/useAudio'

const { isPlaying, toggleSound, playChime, stopSound } = useAudio()

// Distance remaining in km (from 10.0 down to 0.0)
const distance = ref<number>(8.5)
const isAutoSimulating = ref(false)
let simulationInterval: number | null = null

// Slider progress (0 = Departure 10km, 10 = Arrival 0km)
const sliderProgress = computed({
  get: () => Number((10 - distance.value).toFixed(1)),
  set: (val: number) => {
    distance.value = Math.max(0, Math.min(10, Number((10 - val).toFixed(1))))
  }
})

// Thresholds
const STAGE_5KM = 5.0
const STAGE_2KM = 2.0
const STAGE_1KM = 1.0

const currentStage = computed(() => {
  if (distance.value <= 0.1) return 'arrived'
  if (distance.value <= STAGE_1KM) return 'alarm'
  if (distance.value <= STAGE_2KM) return 'warning'
  if (distance.value <= STAGE_5KM) return 'info'
  return 'cruising'
})

// Progress percentage from left (0%) to right (100%)
const progressPercent = computed(() => {
  return ((10 - distance.value) / 10) * 100
})

const startSimulation = () => {
  if (isAutoSimulating.value) {
    pauseSimulation()
    return
  }

  isAutoSimulating.value = true
  if (distance.value <= 0.1) {
    distance.value = 10.0
  }

  simulationInterval = window.setInterval(() => {
    if (distance.value > 0.1) {
      distance.value = Math.max(0, Number((distance.value - 0.2).toFixed(1)))
    } else {
      pauseSimulation()
    }
  }, 250)
}

const pauseSimulation = () => {
  isAutoSimulating.value = false
  if (simulationInterval) {
    clearInterval(simulationInterval)
    simulationInterval = null
  }
}

const resetSimulation = () => {
  pauseSimulation()
  distance.value = 8.5
  stopSound()
}

// Watch stage changes to trigger audio/chimes
const lastStage = ref(currentStage.value)
watch(currentStage, (newStage, oldStage) => {
  if (newStage !== oldStage) {
    if (newStage === 'info') {
      playChime('info')
    } else if (newStage === 'warning') {
      playChime('warning')
    } else if (newStage === 'alarm') {
      playChime('alarm')
    }
  }
  lastStage.value = newStage
})

onUnmounted(() => {
  pauseSimulation()
})
</script>

<template>
  <section id="simulator" class="py-16 sm:py-24 px-4 sm:px-6 max-w-6xl mx-auto scroll-mt-20">
    <!-- Section Heading -->
    <div class="text-center max-w-2xl mx-auto space-y-3 mb-12">
      <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#1DB56A]/10 text-[#1DB56A] text-xs font-bold uppercase tracking-wider">
        <Radio class="w-3.5 h-3.5 animate-pulse" />
        Interactive Journey Sandbox
      </div>
      <h2 class="text-3xl sm:text-4xl font-extrabold text-[#17251C] dark:text-white tracking-tight">
        Experience the 3-Stage Alert System
      </h2>
      <p class="text-sm sm:text-base text-[#526458] dark:text-[#A4B8AB]">
        Drag the distance slider or click play to see how Busnap alerts you progressively before reaching your stop.
      </p>
    </div>

    <!-- Main Interactive Card -->
    <div class="liquid-card rounded-3xl p-6 sm:p-8 md:p-10 border border-emerald-500/20 shadow-2xl relative overflow-hidden">
      
      <!-- Background Ambient Glow based on current stage -->
      <div 
        class="absolute -right-20 -bottom-20 w-80 h-80 rounded-full blur-[100px] pointer-events-none transition-all duration-700 opacity-40"
        :class="{
          'bg-emerald-500': currentStage === 'cruising' || currentStage === 'info',
          'bg-amber-500': currentStage === 'warning',
          'bg-rose-500': currentStage === 'alarm',
          'bg-cyan-500': currentStage === 'arrived'
        }"
      ></div>

      <div class="grid grid-cols-1 lg:grid-cols-12 gap-8 items-center">
        
        <!-- Left: Simulator Controls & Route Progress -->
        <div class="lg:col-span-7 space-y-6">
          
          <!-- Distance Counter Display -->
          <div class="flex items-center justify-between bg-[#F4FBF6] dark:bg-[#122218] p-4 sm:p-5 rounded-2xl border border-emerald-500/20">
            <div>
              <div class="text-xs uppercase font-bold text-[#8A9C90] tracking-wider">Distance to Destination</div>
              <div class="text-3xl sm:text-4xl font-extrabold font-mono text-[#17251C] dark:text-white mt-1">
                {{ distance.toFixed(1) }} <span class="text-lg font-sans font-semibold text-[#1DB56A]">km</span>
              </div>
            </div>

            <!-- ETA Estimation -->
            <div class="text-right">
              <div class="text-xs uppercase font-bold text-[#8A9C90] tracking-wider">Estimated Time</div>
              <div class="text-2xl sm:text-3xl font-extrabold font-mono text-[#526458] dark:text-[#A4B8AB] mt-1">
                ~{{ Math.ceil(distance * 1.8) }} <span class="text-sm font-sans font-semibold">min</span>
              </div>
            </div>
          </div>

          <!-- Interactive Track / Distance Slider -->
          <div class="space-y-3">
            <div class="flex justify-between text-[11px] sm:text-xs font-bold text-[#8A9C90]">
              <span class="text-white">🚩 Departure (10 km)</span>
              <span class="text-emerald-400">5 km (Notif)</span>
              <span class="text-amber-400">2 km (Prep)</span>
              <span class="text-rose-400">1 km (Alarm)</span>
              <span class="text-white">🏁 Stop (0 km)</span>
            </div>

            <!-- Custom Interactive Slider Track -->
            <div class="relative py-3">
              <!-- Background Rail -->
              <div class="absolute top-1/2 left-0 right-0 h-3 bg-[#112217] rounded-full -translate-y-1/2 border border-white/10 pointer-events-none"></div>

              <!-- Filled Active Route Rail -->
              <div 
                class="absolute top-1/2 left-0 h-3 bg-gradient-to-r from-emerald-500 via-[#1DB56A] to-emerald-400 rounded-full pointer-events-none -translate-y-1/2 transition-all duration-100 shadow-[0_0_12px_rgba(29,181,106,0.5)]" 
                :style="{ width: `${progressPercent}%` }"
              ></div>

              <!-- Milestone Markers (50% = 5km, 80% = 2km, 90% = 1km) -->
              <div 
                class="absolute top-1/2 left-[50%] -translate-x-1/2 -translate-y-1/2 w-4 h-4 rounded-full border-2 transition-all pointer-events-none z-10" 
                :class="progressPercent >= 50 ? 'bg-emerald-400 border-white shadow-[0_0_8px_rgba(52,211,153,0.8)]' : 'bg-[#182c20] border-emerald-500/40'"
                title="5 km Notification Threshold"
              ></div>
              <div 
                class="absolute top-1/2 left-[80%] -translate-x-1/2 -translate-y-1/2 w-4 h-4 rounded-full border-2 transition-all pointer-events-none z-10" 
                :class="progressPercent >= 80 ? 'bg-amber-400 border-white shadow-[0_0_8px_rgba(251,191,36,0.8)]' : 'bg-[#252212] border-amber-500/40'"
                title="2 km Preparation Threshold"
              ></div>
              <div 
                class="absolute top-1/2 left-[90%] -translate-x-1/2 -translate-y-1/2 w-4 h-4 rounded-full border-2 transition-all pointer-events-none z-10" 
                :class="progressPercent >= 90 ? 'bg-rose-500 border-white shadow-[0_0_8px_rgba(244,63,94,0.8)]' : 'bg-[#2c151a] border-rose-500/40'"
                title="1 km Alarm Threshold"
              ></div>

              <!-- Native Range Slider Input Overlay (controlling progress 0 to 10) -->
              <input 
                type="range" 
                min="0" 
                max="10" 
                step="0.1" 
                v-model.number="sliderProgress"
                class="relative w-full h-3 opacity-0 cursor-ew-resize z-20"
                aria-label="Journey distance slider"
              />

              <!-- Visual Glowing Bus Thumb on current position -->
              <div 
                class="absolute top-1/2 -translate-y-1/2 -translate-x-1/2 w-7 h-7 rounded-full bg-white text-[#17251C] shadow-[0_0_15px_rgba(255,255,255,0.8)] flex items-center justify-center pointer-events-none z-30 transition-all duration-75 text-xs font-bold ring-2 ring-emerald-500"
                :style="{ left: `${progressPercent}%` }"
              >
                🚌
              </div>
            </div>
          </div>

          <!-- Simulation Action Buttons -->
          <div class="flex flex-wrap items-center gap-3 pt-2">
            <button 
              @click="startSimulation"
              class="flex-1 sm:flex-none bg-[#1DB56A] hover:bg-[#189b5a] active:scale-95 text-white font-semibold text-sm px-6 py-3 rounded-2xl shadow-md shadow-emerald-500/20 transition-all flex items-center justify-center gap-2 cursor-pointer"
            >
              <Pause v-if="isAutoSimulating" class="w-4 h-4" />
              <Play v-else class="w-4 h-4 fill-white" />
              <span>{{ isAutoSimulating ? 'Pause Simulation' : 'Start Auto Journey' }}</span>
            </button>

            <button 
              @click="resetSimulation"
              class="p-3 rounded-2xl bg-black/5 dark:bg-white/10 hover:bg-black/10 dark:hover:bg-white/15 text-[#17251C] dark:text-white transition-all cursor-pointer"
              title="Reset Distance"
            >
              <RotateCcw class="w-4 h-4" />
            </button>

            <button 
              @click="toggleSound('/alarm.mp3')"
              class="flex items-center gap-2 px-4 py-3 rounded-2xl border border-emerald-500/30 text-xs font-semibold text-[#17251C] dark:text-white hover:bg-emerald-500/10 transition-colors cursor-pointer"
            >
              <Volume2 v-if="!isPlaying" class="w-4 h-4 text-[#1DB56A]" />
              <VolumeX v-else class="w-4 h-4 text-rose-500" />
              <span>{{ isPlaying ? 'Stop Audio' : 'Test Alarm Tone' }}</span>
            </button>
          </div>

        </div>

        <!-- Right: Real-time Live Stage Reaction Card -->
        <div class="lg:col-span-5">
          <div 
            class="rounded-3xl p-6 sm:p-7 border transition-all duration-500 shadow-xl relative overflow-hidden"
            :class="{
              'bg-emerald-50/90 dark:bg-emerald-950/40 border-emerald-500/40': currentStage === 'cruising',
              'bg-emerald-100/90 dark:bg-emerald-900/50 border-emerald-500': currentStage === 'info',
              'bg-amber-50/90 dark:bg-amber-950/50 border-amber-500': currentStage === 'warning',
              'bg-rose-50/95 dark:bg-rose-950/60 border-rose-500 ring-4 ring-rose-500/20': currentStage === 'alarm',
              'bg-cyan-50/90 dark:bg-cyan-950/50 border-cyan-500': currentStage === 'arrived',
            }"
          >
            <!-- Stage Icon & Badge -->
            <div class="flex items-center justify-between mb-4">
              <span 
                class="px-3 py-1 rounded-full text-xs font-bold uppercase tracking-wider"
                :class="{
                  'bg-emerald-500/20 text-emerald-800 dark:text-emerald-300': currentStage === 'cruising' || currentStage === 'info',
                  'bg-amber-500/20 text-amber-800 dark:text-amber-300': currentStage === 'warning',
                  'bg-rose-500/20 text-rose-800 dark:text-rose-300 animate-bounce': currentStage === 'alarm',
                  'bg-cyan-500/20 text-cyan-800 dark:text-cyan-300': currentStage === 'arrived',
                }"
              >
                {{ 
                  currentStage === 'cruising' ? 'Cruising & Napping' :
                  currentStage === 'info' ? 'Stage 1: 5 km Alert' :
                  currentStage === 'warning' ? 'Stage 2: 2 km Alert' :
                  currentStage === 'alarm' ? 'Stage 3: 1 km WAKE UP!' :
                  'Destination Reached'
                }}
              </span>

              <div 
                class="w-10 h-10 rounded-2xl flex items-center justify-center shadow-md"
                :class="{
                  'bg-emerald-500 text-white': currentStage === 'cruising' || currentStage === 'info',
                  'bg-amber-500 text-white': currentStage === 'warning',
                  'bg-rose-500 text-white animate-pulse': currentStage === 'alarm',
                  'bg-cyan-500 text-white': currentStage === 'arrived',
                }"
              >
                <Bell v-if="currentStage === 'cruising'" class="w-5 h-5" />
                <BellRing v-else-if="currentStage === 'info'" class="w-5 h-5" />
                <AlertTriangle v-else-if="currentStage === 'warning'" class="w-5 h-5" />
                <Volume2 v-else-if="currentStage === 'alarm'" class="w-5 h-5 animate-spin" />
                <CheckCircle v-else class="w-5 h-5" />
              </div>
            </div>

            <!-- Dynamic Message Description -->
            <h3 class="text-xl font-bold text-[#17251C] dark:text-white mb-2">
              {{ 
                currentStage === 'cruising' ? 'Relax & Close Your Eyes' :
                currentStage === 'info' ? 'Heads-up Notification Sent' :
                currentStage === 'warning' ? 'Pack Your Bags & Prepare' :
                currentStage === 'alarm' ? '🚨 WAKE UP! Bus Stop Approaching' :
                'You Have Arrived!'
              }}
            </h3>

            <p class="text-sm text-[#526458] dark:text-[#C5D6CC] leading-relaxed">
              {{ 
                currentStage === 'cruising' ? 'Busnap is silently monitoring GPS road distance in the background with zero battery drain.' :
                currentStage === 'info' ? 'A gentle vibration & notification chime reminds you that you have entered the 5km zone.' :
                currentStage === 'warning' ? 'A distinctive chime alerts you at 2km so you can gather your phone, bag, and jacket.' :
                currentStage === 'alarm' ? 'Full volume alarm rings continuously until dismissed to ensure you step off the bus on time!' :
                'Journey completed safely without missing your stop. Trip ended locally.'
              }}
            </p>

            <!-- Vibration / Pulse Wave Visualization -->
            <div class="mt-6 pt-4 border-t border-black/10 dark:border-white/10 flex items-center justify-between text-xs">
              <span class="font-medium text-[#8A9C90]">Hardware Action:</span>
              <span class="font-bold flex items-center gap-1.5" :class="currentStage === 'alarm' ? 'text-rose-600 dark:text-rose-400' : 'text-[#1DB56A]'">
                <span class="w-2 h-2 rounded-full" :class="currentStage === 'alarm' ? 'bg-rose-500 animate-ping' : 'bg-emerald-500'"></span>
                {{ 
                  currentStage === 'cruising' ? 'Silent Background GPS' :
                  currentStage === 'info' ? 'Single Vibration + Tone' :
                  currentStage === 'warning' ? 'Double Vibration + Tone' :
                  currentStage === 'alarm' ? 'Continuous Alarm Audio + Vibrate' :
                  'Service Stopped'
                }}
              </span>
            </div>

          </div>
        </div>

      </div>
    </div>
  </section>
</template>
