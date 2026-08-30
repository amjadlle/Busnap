<script setup lang="ts">
import { ref } from 'vue'
import { ChevronDown, HelpCircle } from 'lucide-vue-next'

const faqs = [
  {
    question: 'How does Busnap alert me while my phone is locked or screen is off?',
    answer: 'Busnap uses a native Android Foreground Service with continuous background GPS tracking. This guarantees the operating system will not kill or suspend the app while you are napping, ensuring your 5km, 2km, and 1km alarms trigger reliably.'
  },
  {
    question: 'Will keeping GPS active in the background drain my battery?',
    answer: 'No. Busnap is specifically optimized for public transit commutes. It uses smart geofencing and distance throttling to poll location efficiently, consuming less than 1% battery for typical 30–60 minute commutes.'
  },
  {
    question: 'Can I use custom alarm sounds instead of the default tone?',
    answer: 'Yes! In the Busnap Alarm Settings, you can choose any audio file from your device storage (MP3, WAV, OGG, M4A) so you can wake up to your favorite chime or high-volume sound.'
  },
  {
    question: 'Are my location or search queries tracked or saved on remote servers?',
    answer: 'Never. Busnap has no user accounts, no analytics SDKs, and no Busnap backend database. Nominatim and OpenStreetMap routing are queried directly to calculate routes, and all distance math is computed strictly on your device.'
  },
  {
    question: 'Does Busnap calculate straight-line distance or actual road distance?',
    answer: 'Busnap calculates the actual road route network distance using OpenStreetMap Valhalla & OSRM routing, not naive straight-line radius ("as the crow flies"). This prevents premature alarms when roads curve or loop.'
  },
  {
    question: 'What permissions are required and why?',
    answer: 'Busnap requires Location (GPS coordinates), Background Location (to alert you with the screen locked), Foreground Service (persistent notification to prevent Android task killing), and Notification permissions (to ring alarms on Android 13+).'
  }
]

const openIndex = ref<number | null>(0)

const toggle = (idx: number) => {
  openIndex.value = openIndex.value === idx ? null : idx
}
</script>

<template>
  <section id="faq" class="py-16 sm:py-24 px-4 sm:px-6 max-w-4xl mx-auto scroll-mt-20">
    <div class="text-center max-w-2xl mx-auto space-y-3 mb-14">
      <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#1DB56A]/10 text-[#1DB56A] text-xs font-bold uppercase tracking-wider">
        <HelpCircle class="w-3.5 h-3.5" />
        Frequently Asked Questions
      </div>
      <h2 class="text-3xl sm:text-4xl font-extrabold text-[#17251C] dark:text-white tracking-tight">
        Got questions? We've got answers.
      </h2>
    </div>

    <!-- Accordion List -->
    <div class="space-y-4">
      <div 
        v-for="(faq, idx) in faqs" 
        :key="faq.question"
        class="liquid-card rounded-2xl border border-emerald-500/15 overflow-hidden transition-all duration-200"
      >
        <button 
          @click="toggle(idx)"
          class="w-full p-5 sm:p-6 text-left flex items-center justify-between gap-4 font-bold text-base sm:text-lg text-[#17251C] dark:text-white cursor-pointer select-none"
        >
          <span>{{ faq.question }}</span>
          <div 
            class="p-1.5 rounded-full bg-emerald-500/10 text-[#1DB56A] shrink-0 transition-transform duration-200"
            :class="{ 'rotate-180 bg-[#1DB56A] text-white': openIndex === idx }"
          >
            <ChevronDown class="w-4 h-4" />
          </div>
        </button>

        <Transition
          enter-active-class="transition duration-200 ease-out"
          enter-from-class="opacity-0 -translate-y-2 max-h-0"
          enter-to-class="opacity-100 translate-y-0 max-h-96"
          leave-active-class="transition duration-150 ease-in"
          leave-from-class="opacity-100 translate-y-0 max-h-96"
          leave-to-class="opacity-0 -translate-y-2 max-h-0"
        >
          <div v-show="openIndex === idx" class="px-5 sm:px-6 pb-6 text-sm sm:text-base text-[#526458] dark:text-[#A4B8AB] leading-relaxed border-t border-black/5 dark:border-white/5 pt-4">
            {{ faq.answer }}
          </div>
        </Transition>
      </div>
    </div>
  </section>
</template>
