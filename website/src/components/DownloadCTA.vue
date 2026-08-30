<script setup lang="ts">
import { ref, onMounted } from 'vue'
import { Download, Github, CheckCircle2, QrCode } from 'lucide-vue-next'
import QRCode from 'qrcode'

const qrSvg = ref<string>('')
const playStoreUrl = 'https://play.google.com/store/apps/details?id=com.busnap.app'
const githubReleasesUrl = 'https://github.com/amjadlle/busnap/releases'

onMounted(async () => {
  try {
    qrSvg.value = await QRCode.toString(playStoreUrl, {
      type: 'svg',
      margin: 1,
      color: {
        dark: '#1DB56A',
        light: '#00000000'
      }
    })
  } catch (err) {
    console.error('Failed to generate real QR code:', err)
  }
})
</script>

<template>
  <section id="download" class="py-16 sm:py-24 px-4 sm:px-6 max-w-6xl mx-auto scroll-mt-20">
    <div class="liquid-card rounded-3xl p-8 sm:p-12 md:p-14 border border-emerald-500/30 shadow-2xl relative overflow-hidden bg-gradient-to-br from-[#1DB56A]/10 via-transparent to-emerald-950/20">
      
      <!-- Glow ambient background -->
      <div class="absolute -top-24 -right-24 w-96 h-96 bg-emerald-500/20 rounded-full blur-3xl pointer-events-none"></div>

      <div class="grid grid-cols-1 lg:grid-cols-12 gap-10 items-center relative z-10">
        
        <!-- Left: Download Options -->
        <div class="lg:col-span-8 space-y-6 text-center lg:text-left">
          
          <div class="inline-flex items-center gap-2 px-3.5 py-1.5 rounded-full bg-[#1DB56A]/15 text-[#1DB56A] text-xs font-bold uppercase tracking-wider">
            <Download class="w-3.5 h-3.5" />
            Now Available on Google Play
          </div>

          <h2 class="text-3xl sm:text-4xl lg:text-5xl font-extrabold text-white tracking-tight leading-tight">
            Ready for stress-free commuting?
          </h2>

          <p class="text-base sm:text-lg text-[#A4B8AB] max-w-xl">
            Get Busnap directly from the Google Play Store or download the standalone open source APK. 100% free, no ads, zero tracking.
          </p>

          <!-- Buttons -->
          <div class="flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4 pt-2">
            <!-- Google Play Store Button -->
            <a 
              :href="playStoreUrl" 
              target="_blank"
              rel="noopener noreferrer"
              class="w-full sm:w-auto bg-[#1DB56A] hover:bg-[#189b5a] active:scale-95 text-white font-bold text-base px-8 py-4 rounded-xl shadow-lg shadow-[#1DB56A]/30 hover:shadow-xl hover:shadow-[#1DB56A]/40 transition-all flex items-center justify-center gap-3 group cursor-pointer"
            >
              <!-- Google Play Icon -->
              <svg class="w-5 h-5 fill-current" viewBox="0 0 24 24">
                <path d="M3.609 1.814L13.792 12 3.61 22.186a1.986 1.986 0 0 1-.22-.924V2.738c0-.34.08-.656.22-.924zm11.242 11.243l2.484 2.484-9.98 5.717 7.496-8.201zm0-2.114L7.355 2.742l9.98 5.717-2.484 2.484zm1.485 1.057l3.666 2.1a1.218 1.218 0 0 1 0 2.176l-3.666 2.1-1.748-1.748 1.748-4.628z"/>
              </svg>
              <span>Get on Google Play</span>
            </a>

            <!-- Direct APK / GitHub Link -->
            <a 
              :href="githubReleasesUrl" 
              target="_blank"
              rel="noopener noreferrer"
              class="w-full sm:w-auto liquid-glass hover:border-[#1DB56A]/50 text-white font-semibold text-base px-7 py-4 rounded-xl shadow-sm hover:shadow-md transition-all flex items-center justify-center gap-2.5 cursor-pointer"
            >
              <Github class="w-5 h-5" />
              <span>Direct APK / Source</span>
            </a>
          </div>

          <!-- Requirements Pill -->
          <div class="flex flex-wrap items-center justify-center lg:justify-start gap-4 pt-2 text-xs text-[#8A9C90]">
            <span class="flex items-center gap-1.5">
              <CheckCircle2 class="w-3.5 h-3.5 text-[#1DB56A]" />
              Android 8.0 (Oreo) or higher
            </span>
            <span>•</span>
            <span class="flex items-center gap-1.5">
              <CheckCircle2 class="w-3.5 h-3.5 text-[#1DB56A]" />
              Flutter SDK ^3.8.1
            </span>
            <span>•</span>
            <span class="flex items-center gap-1.5">
              <CheckCircle2 class="w-3.5 h-3.5 text-[#1DB56A]" />
              MIT License
            </span>
          </div>

        </div>

        <!-- Right: Real Scannable Google Play QR Code Card -->
        <div class="lg:col-span-4 flex justify-center">
          <div class="bg-[#122218] p-6 rounded-3xl border border-emerald-500/30 shadow-2xl text-center space-y-4 max-w-[270px] w-full">
            <div class="p-3 bg-white rounded-2xl border border-emerald-500/30 inline-block shadow-inner">
              <!-- Real Scannable Google Play QR Code -->
              <div 
                v-if="qrSvg" 
                v-html="qrSvg" 
                class="w-40 h-40 mx-auto [&_svg]:w-full [&_svg]:h-full"
              ></div>
              <div v-else class="w-40 h-40 flex items-center justify-center text-emerald-500">
                <QrCode class="w-12 h-12 animate-pulse" />
              </div>
            </div>

            <div>
              <div class="text-xs font-bold text-white flex items-center justify-center gap-1.5">
                <QrCode class="w-3.5 h-3.5 text-[#1DB56A]" />
                <span>Scan for Google Play</span>
              </div>
              <div class="text-[11px] text-[#8A9C90] mt-0.5">Instantly open on Android phone</div>
            </div>
          </div>
        </div>

      </div>

    </div>
  </section>
</template>
