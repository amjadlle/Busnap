<script setup lang="ts">
import { Check, X, Lock } from 'lucide-vue-next'

const comparisons = [
  {
    feature: 'No Account or Sign-in Required',
    busnap: true,
    others: false,
    note: 'Open the app and use it immediately without registering'
  },
  {
    feature: '100% On-Device GPS Processing',
    busnap: true,
    others: false,
    note: 'Your current location is never uploaded to any Busnap servers'
  },
  {
    feature: 'Zero Advertising or Analytics Trackers',
    busnap: true,
    others: false,
    note: 'No Google Analytics, Facebook SDKs, or data brokers'
  },
  {
    feature: 'Multi-Stage Progressive Alarms (5km, 2km, 1km)',
    busnap: true,
    others: false,
    note: 'Progressive preparation alerts so you never rush'
  },
  {
    feature: 'Custom MP3/Audio File Alarm Support',
    busnap: true,
    others: false,
    note: 'Choose any audio file from your device storage'
  },
  {
    feature: '100% Free & Open Source (MIT)',
    busnap: true,
    others: false,
    note: 'Fully auditable, transparent codebase on GitHub'
  }
]
</script>

<template>
  <section id="privacy" class="py-16 sm:py-24 px-4 sm:px-6 max-w-5xl mx-auto scroll-mt-20">
    <div class="text-center max-w-2xl mx-auto space-y-3 mb-12">
      <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#1DB56A]/10 text-[#1DB56A] text-xs font-bold uppercase tracking-wider">
        <Lock class="w-3.5 h-3.5" />
        Privacy by Design
      </div>
      <h2 class="text-3xl sm:text-4xl font-extrabold text-[#17251C] dark:text-white tracking-tight">
        Why Busnap is Different
      </h2>
      <p class="text-sm sm:text-base text-[#526458] dark:text-[#A4B8AB]">
        We believe a transit alarm shouldn't come at the cost of your digital privacy or battery life.
      </p>
    </div>

    <!-- Comparison Table Card -->
    <div class="liquid-card rounded-3xl p-4 sm:p-8 border border-emerald-500/20 shadow-xl overflow-hidden">
      <div class="overflow-x-auto">
        <table class="w-full text-left border-collapse min-w-[540px]">
          <thead>
            <tr class="border-b border-emerald-900/10 dark:border-emerald-500/10">
              <th class="py-4 px-4 text-sm font-bold text-[#17251C] dark:text-white w-1/2">Features & Privacy</th>
              <th class="py-4 px-4 text-center text-sm font-bold text-[#1DB56A] w-1/4 bg-emerald-500/10 rounded-t-2xl">
                <div class="flex items-center justify-center gap-1.5">
                  <img src="/logo.png" alt="Busnap" class="w-4 h-4 rounded" />
                  <span>Busnap</span>
                </div>
              </th>
              <th class="py-4 px-4 text-center text-sm font-bold text-[#526458] dark:text-[#8A9C90] w-1/4">
                Other Map Apps
              </th>
            </tr>
          </thead>
          <tbody class="divide-y divide-emerald-900/5 dark:divide-emerald-500/10 text-sm">
            <tr v-for="item in comparisons" :key="item.feature" class="hover:bg-emerald-500/5 transition-colors">
              <td class="py-4 px-4">
                <div class="font-semibold text-[#17251C] dark:text-white">{{ item.feature }}</div>
                <div class="text-xs text-[#8A9C90] mt-0.5">{{ item.note }}</div>
              </td>
              <td class="py-4 px-4 text-center bg-emerald-500/5 font-bold text-[#1DB56A]">
                <div class="inline-flex p-1.5 rounded-full bg-emerald-500/20 text-[#1DB56A]">
                  <Check class="w-4 h-4 stroke-[3]" />
                </div>
              </td>
              <td class="py-4 px-4 text-center text-[#8A9C90]">
                <div class="inline-flex p-1.5 rounded-full bg-rose-500/10 text-rose-500 dark:text-rose-400">
                  <X class="w-4 h-4 stroke-[3]" />
                </div>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </section>
</template>
