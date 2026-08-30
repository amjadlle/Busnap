<script setup lang="ts">
import { Search, Moon, BellRing, CheckCircle2 } from 'lucide-vue-next'

const steps = [
  {
    step: '01',
    title: 'Search Your Bus Stop',
    description: 'Type any landmark, bus terminal, or street address. Busnap quickly finds the exact coordinates using OpenStreetMap Nominatim.',
    icon: Search,
    detail: 'Instant autocomplete & local history',
  },
  {
    step: '02',
    title: 'Start Journey & Nap',
    description: 'Press Start and lock your phone. The native foreground service monitors distance silently without killing your battery or interrupting music.',
    icon: Moon,
    detail: 'Runs reliably with screen turned off',
  },
  {
    step: '03',
    title: 'Wake Up on Schedule',
    description: 'Receive a heads-up at 5km, prep reminder at 2km, and high-volume wake alarm at 1km. Collect your belongings and exit calmly.',
    icon: BellRing,
    detail: 'Custom ringtones & vibrations',
  },
]
</script>

<template>
  <section id="how-it-works" class="py-16 sm:py-24 px-4 sm:px-6 max-w-7xl mx-auto scroll-mt-20">
    <div class="text-center max-w-2xl mx-auto space-y-3 mb-16">
      <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#1DB56A]/10 text-[#1DB56A] text-xs font-bold uppercase tracking-wider">
        Simple 3-Step Flow
      </div>
      <h2 class="text-3xl sm:text-4xl font-extrabold text-[#17251C] dark:text-white tracking-tight">
        How Busnap Works
      </h2>
      <p class="text-sm sm:text-base text-[#526458] dark:text-[#A4B8AB]">
        Getting started takes less than 5 seconds before you board your bus or train.
      </p>
    </div>

    <!-- Steps Horizontal Grid with Connecting Elements -->
    <div class="grid grid-cols-1 md:grid-cols-3 gap-8 relative">
      
      <!-- Connecting Line in Desktop -->
      <div class="hidden md:block absolute top-1/2 left-[15%] right-[15%] h-0.5 bg-gradient-to-r from-emerald-500/20 via-emerald-500/40 to-emerald-500/20 -translate-y-8 pointer-events-none z-0"></div>

      <div 
        v-for="s in steps" 
        :key="s.step"
        class="liquid-card rounded-3xl p-6 sm:p-8 flex flex-col justify-between relative z-10 hover:-translate-y-2 transition-transform duration-300"
      >
        <!-- Step Number & Icon -->
        <div>
          <div class="flex items-center justify-between mb-6">
            <span class="text-2xl sm:text-3xl font-extrabold font-mono text-[#1DB56A] bg-emerald-500/10 px-3 py-1 rounded-xl">
              {{ s.step }}
            </span>
            <div class="w-12 h-12 rounded-2xl bg-white dark:bg-[#182c20] shadow-md border border-emerald-500/20 text-[#1DB56A] flex items-center justify-center">
              <component :is="s.icon" class="w-6 h-6" />
            </div>
          </div>

          <h3 class="text-xl font-bold text-[#17251C] dark:text-white mb-2.5">
            {{ s.title }}
          </h3>

          <p class="text-sm text-[#526458] dark:text-[#A4B8AB] leading-relaxed">
            {{ s.description }}
          </p>
        </div>

        <!-- Detail Badge -->
        <div class="mt-6 pt-4 border-t border-black/5 dark:border-white/5 flex items-center gap-2 text-xs font-semibold text-[#1DB56A]">
          <CheckCircle2 class="w-4 h-4" />
          <span>{{ s.detail }}</span>
        </div>
      </div>

    </div>
  </section>
</template>
