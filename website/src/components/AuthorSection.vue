<script setup lang="ts">
import { ref } from 'vue'
import { 
  Mail, 
  Globe, 
  Github, 
  Linkedin, 
  Twitter, 
  Youtube, 
  Instagram, 
  Sparkles, 
  ExternalLink, 
  MessageCircle, 
  Copy, 
  Check 
} from 'lucide-vue-next'

const author = {
  name: 'Amjad P A',
  role: 'Software Engineer & Creator of Busnap',
  email: 'hire.amjad@gmail.com',
  portfolio: 'https://amjad.mapki.in',
  headshot: 'https://doting-octopus-124.convex.cloud/api/storage/730e2173-8a2f-4d38-8976-7624a53bbc88',
  bio: 'Passionate about building fast, delightful, privacy-first mobile and web applications that solve real daily commuter problems.',
  tags: ['Flutter', 'Dart', 'OpenStreetMap', 'Vue 3', 'Privacy First'],
  socials: [
    { name: 'GitHub', username: '@amjadlle', url: 'https://github.com/amjadlle', icon: Github, color: 'hover:text-white hover:border-white/30' },
    { name: 'LinkedIn', username: 'in/amjadlle', url: 'https://linkedin.com/in/amjadlle', icon: Linkedin, color: 'hover:text-blue-400 hover:border-blue-400/30' },
    { name: 'X / Twitter', username: '@amjadlle', url: 'https://x.com/amjadlle', icon: Twitter, color: 'hover:text-sky-400 hover:border-sky-400/30' },
    { name: 'YouTube', username: '@reputedculprit', url: 'https://youtube.com/@reputedculprit', icon: Youtube, color: 'hover:text-red-400 hover:border-red-400/30' },
    { name: 'Instagram', username: '@amjadlle', url: 'https://instagram.com/amjadlle', icon: Instagram, color: 'hover:text-pink-400 hover:border-pink-400/30' },
    { name: 'Threads', username: '@amjadlle', url: 'https://www.threads.net/@amjadlle', icon: MessageCircle, color: 'hover:text-slate-200 hover:border-white/30' },
  ]
}

const copied = ref(false)
const copyEmail = () => {
  navigator.clipboard.writeText(author.email)
  copied.value = true
  setTimeout(() => {
    copied.value = false
  }, 2000)
}
</script>

<template>
  <section id="creator" class="py-16 sm:py-24 px-4 sm:px-6 max-w-5xl mx-auto scroll-mt-20">
    <!-- Section Heading -->
    <div class="text-center max-w-2xl mx-auto space-y-3 mb-12">
      <div class="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-[#1DB56A]/15 text-[#1DB56A] text-xs font-bold uppercase tracking-wider">
        <Sparkles class="w-3.5 h-3.5" />
        Meet the Creator
      </div>
      <h2 class="text-3xl sm:text-4xl font-extrabold text-white tracking-tight">
        Behind the Project
      </h2>
      <p class="text-sm sm:text-base text-[#A4B8AB]">
        Crafted with care to make public transit commutes smoother, safer, and stress-free.
      </p>
    </div>

    <!-- Creator Glass Profile Card -->
    <div class="liquid-card rounded-3xl p-6 sm:p-10 md:p-12 border border-emerald-500/25 shadow-2xl relative overflow-hidden bg-gradient-to-br from-[#122419]/90 via-[#0e1b13]/80 to-[#09120d]/90">
      
      <!-- Background Ambient Light -->
      <div class="absolute -top-24 -left-24 w-80 h-80 bg-emerald-500/15 rounded-full blur-3xl pointer-events-none"></div>

      <div class="flex flex-col md:flex-row items-center md:items-start gap-8 relative z-10 text-center md:text-left">
        
        <!-- Avatar Column -->
        <div class="flex flex-col items-center shrink-0 space-y-3">
          <div class="relative group">
            <!-- Glowing Ring Effect -->
            <div class="absolute -inset-1 bg-gradient-to-r from-[#1DB56A] to-emerald-400 rounded-3xl blur opacity-40 group-hover:opacity-75 transition duration-500"></div>
            <div class="relative w-32 h-32 sm:w-36 sm:h-36 rounded-2xl overflow-hidden ring-2 ring-emerald-500/50 shadow-2xl bg-[#0e1b13]">
              <img 
                :src="author.headshot" 
                :alt="author.name" 
                class="w-full h-full object-cover object-center group-hover:scale-105 transition-transform duration-300"
                loading="lazy"
              />
            </div>
          </div>

          <!-- Status Pill -->
          <div class="inline-flex items-center gap-1.5 text-[11px] font-bold px-3 py-1 rounded-full bg-emerald-500/15 text-[#34d399] border border-emerald-500/30">
            <span class="w-2 h-2 rounded-full bg-emerald-400 animate-pulse"></span>
            Available for Hire
          </div>
        </div>

        <!-- Info & Bio Column -->
        <div class="flex-1 space-y-5">
          
          <div class="space-y-1.5">
            <h3 class="text-2xl sm:text-3xl font-extrabold text-white tracking-tight">
              {{ author.name }}
            </h3>
            <p class="text-xs sm:text-sm font-semibold text-[#1DB56A]">
              {{ author.role }}
            </p>
          </div>

          <p class="text-sm sm:text-base text-[#A4B8AB] leading-relaxed max-w-xl">
            {{ author.bio }}
          </p>

          <!-- Tech Tags -->
          <div class="flex flex-wrap items-center justify-center md:justify-start gap-1.5">
            <span 
              v-for="tag in author.tags" 
              :key="tag"
              class="px-2.5 py-0.5 rounded-md bg-white/5 border border-white/10 text-[#C5D6CC] text-[11px] font-medium font-mono"
            >
              {{ tag }}
            </span>
          </div>

          <!-- Primary Action Buttons (Email & Portfolio) -->
          <div class="flex flex-wrap items-center justify-center md:justify-start gap-3 pt-1">
            <a 
              :href="`mailto:${author.email}`" 
              class="bg-[#1DB56A] hover:bg-[#189b5a] active:scale-95 text-white text-xs sm:text-sm font-bold px-4 sm:px-5 py-2.5 rounded-xl shadow-md shadow-emerald-500/25 transition-all flex items-center gap-2 cursor-pointer"
            >
              <Mail class="w-4 h-4" />
              <span>hire.amjad@gmail.com</span>
            </a>

            <button 
              @click="copyEmail"
              class="p-2.5 rounded-xl bg-white/5 hover:bg-white/15 border border-white/10 text-white text-xs font-semibold transition-all cursor-pointer flex items-center gap-1.5"
              :title="copied ? 'Copied!' : 'Copy Email'"
            >
              <Check v-if="copied" class="w-4 h-4 text-emerald-400" />
              <Copy v-else class="w-4 h-4 text-[#A4B8AB]" />
              <span class="text-[11px]">{{ copied ? 'Copied!' : 'Copy' }}</span>
            </button>

            <a 
              :href="author.portfolio" 
              target="_blank" 
              rel="noopener noreferrer"
              class="liquid-glass hover:border-[#1DB56A]/50 text-white text-xs sm:text-sm font-semibold px-4 sm:px-5 py-2.5 rounded-xl shadow-sm hover:shadow-md transition-all flex items-center gap-1.5 cursor-pointer"
            >
              <Globe class="w-4 h-4 text-[#1DB56A]" />
              <span>amjad.mapki.in</span>
              <ExternalLink class="w-3.5 h-3.5 text-[#8A9C90]" />
            </a>
          </div>

          <!-- Social Links Matrix (2-col on mobile, 4-col on desktop) -->
          <div class="pt-4 border-t border-white/10">
            <div class="text-[11px] uppercase font-bold text-[#8A9C90] tracking-wider mb-2.5 text-center md:text-left">
              Connect Across the Web
            </div>
            <div class="grid grid-cols-2 sm:grid-cols-3 lg:grid-cols-4 gap-2">
              <a 
                v-for="s in author.socials"
                :key="s.name"
                :href="s.url"
                target="_blank"
                rel="noopener noreferrer"
                class="px-3 py-2 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-[#C5D6CC] transition-all flex items-center gap-2 text-xs font-semibold group cursor-pointer"
                :class="s.color"
              >
                <component :is="s.icon" class="w-4 h-4 shrink-0 group-hover:scale-110 transition-transform" />
                <span class="truncate">{{ s.name }}</span>
              </a>

              <!-- Reddit Link -->
              <a 
                href="https://www.reddit.com/user/reputed_culprit/"
                target="_blank"
                rel="noopener noreferrer"
                class="px-3 py-2 rounded-xl bg-white/5 hover:bg-white/10 border border-white/10 text-[#C5D6CC] hover:text-orange-400 hover:border-orange-400/30 transition-all flex items-center gap-2 text-xs font-semibold group cursor-pointer"
              >
                <span class="font-bold font-mono text-sm leading-none text-orange-400">r/</span>
                <span class="truncate">Reddit</span>
              </a>
            </div>
          </div>

        </div>

      </div>

    </div>
  </section>
</template>
