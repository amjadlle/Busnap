<script setup lang="ts">
import { ref, onMounted, onUnmounted } from 'vue'
import { 
  BellRing, 
  Sparkles, 
  Layers, 
  ShieldCheck, 
  HelpCircle, 
  Github, 
  Star,
  Download, 
  Menu, 
  X,
  User
} from 'lucide-vue-next'

const isScrolled = ref(false)
const isMobileMenuOpen = ref(false)

const handleScroll = () => {
  isScrolled.value = window.scrollY > 20
}

onMounted(() => {
  window.addEventListener('scroll', handleScroll)
})

onUnmounted(() => {
  window.removeEventListener('scroll', handleScroll)
})

const navLinks = [
  { name: 'Simulator', href: '#simulator', icon: BellRing },
  { name: 'Features', href: '#features', icon: Sparkles },
  { name: 'How It Works', href: '#how-it-works', icon: Layers },
  { name: 'Privacy', href: '#privacy', icon: ShieldCheck },
  { name: 'Author', href: '#creator', icon: User },
  { name: 'FAQ', href: '#faq', icon: HelpCircle },
]

const closeMobileMenu = () => {
  isMobileMenuOpen.value = false
}
</script>

<template>
  <header class="fixed top-3 sm:top-5 inset-x-0 mx-auto max-w-6xl z-50 px-3 sm:px-6 transition-all duration-300">
    <div 
      class="liquid-glass rounded-2xl px-3.5 sm:px-5 py-2 sm:py-2.5 flex items-center justify-between gap-2 sm:gap-4 lg:gap-6 transition-all duration-300 shadow-lg"
      :class="isScrolled ? 'shadow-2xl shadow-black/60 border-[#1DB56A]/40' : 'shadow-xl shadow-black/40'"
    >
      <!-- Brand Logo & Name -->
      <a href="#" class="flex items-center gap-2 shrink-0 group">
        <img src="/logo.png" alt="Busnap Logo" class="w-8 h-8 sm:w-8.5 sm:h-8.5 rounded-lg group-hover:scale-105 transition-transform" />
        <div class="flex items-center gap-1.5">
          <span class="font-bold text-base sm:text-lg tracking-tight text-white">Busnap</span>
          <span class="text-[10px] uppercase font-bold px-1.5 py-0.5 rounded-md bg-[#1DB56A]/20 text-[#1DB56A] border border-[#1DB56A]/30">v1.0</span>
        </div>
      </a>

      <!-- Desktop Nav Links -->
      <nav class="hidden md:flex items-center gap-1 lg:gap-2">
        <a 
          v-for="link in navLinks" 
          :key="link.name" 
          :href="link.href"
          class="px-2.5 lg:px-3 py-1.5 rounded-xl text-xs lg:text-sm font-semibold text-[#C5D6CC] hover:text-[#1DB56A] hover:bg-emerald-500/15 transition-all flex items-center gap-1.5 whitespace-nowrap"
        >
          <component :is="link.icon" class="w-3.5 h-3.5 opacity-85 text-[#1DB56A] hidden lg:inline-block" />
          <span>{{ link.name }}</span>
        </a>
      </nav>

      <!-- Right Action CTAs -->
      <div class="flex items-center gap-2 sm:gap-3 shrink-0 pl-1 sm:pl-2 md:border-l md:border-white/10">
        <!-- GitHub Star Button -->
        <a 
          href="https://github.com/amjadlle/busnap" 
          target="_blank" 
          rel="noopener noreferrer"
          class="hidden sm:flex items-center gap-1.5 px-2.5 sm:px-3 py-1.5 rounded-xl text-xs font-semibold text-[#E8F2EC] hover:text-white bg-white/5 hover:bg-white/10 border border-white/10 hover:border-white/20 transition-all whitespace-nowrap group cursor-pointer"
        >
          <Github class="w-3.5 h-3.5" />
          <span>Star</span>
          <Star class="w-3.5 h-3.5 text-amber-400 fill-amber-400 group-hover:scale-115 transition-transform" />
        </a>

        <!-- Download APK Button (Google Play) -->
        <a 
          href="https://play.google.com/store/apps/details?id=com.busnap.app" 
          target="_blank"
          rel="noopener noreferrer"
          class="bg-[#1DB56A] hover:bg-[#189b5a] active:scale-95 text-white text-xs sm:text-sm font-bold px-3.5 sm:px-4 py-1.5 sm:py-2 rounded-xl shadow-md shadow-[#1DB56A]/25 hover:shadow-lg hover:shadow-[#1DB56A]/35 transition-all flex items-center gap-1.5 whitespace-nowrap cursor-pointer shrink-0"
        >
          <Download class="w-3.5 h-3.5 sm:w-4 sm:h-4" />
          <span>Get App</span>
        </a>

        <!-- Mobile Menu Toggle Button -->
        <button 
          @click="isMobileMenuOpen = !isMobileMenuOpen"
          aria-label="Open Menu"
          class="md:hidden p-1.5 rounded-xl text-white hover:bg-white/10 transition-colors cursor-pointer"
        >
          <X v-if="isMobileMenuOpen" class="w-5 h-5" />
          <Menu v-else class="w-5 h-5" />
        </button>
      </div>
    </div>

    <!-- Mobile Dropdown Menu (Floating Glass) -->
    <Transition
      enter-active-class="transition duration-200 ease-out"
      enter-from-class="opacity-0 -translate-y-4 scale-95"
      enter-to-class="opacity-100 translate-y-0 scale-100"
      leave-active-class="transition duration-150 ease-in"
      leave-from-class="opacity-100 translate-y-0 scale-100"
      leave-to-class="opacity-0 -translate-y-4 scale-95"
    >
      <div 
        v-if="isMobileMenuOpen"
        class="md:hidden mt-2 liquid-glass rounded-2xl p-4 shadow-2xl border border-emerald-500/30 flex flex-col gap-2"
      >
        <a 
          v-for="link in navLinks" 
          :key="link.name" 
          :href="link.href"
          @click="closeMobileMenu"
          class="px-4 py-2.5 rounded-xl text-sm font-semibold text-[#E8F2EC] hover:bg-emerald-500/15 hover:text-[#1DB56A] transition-colors flex items-center gap-2.5"
        >
          <component :is="link.icon" class="w-4 h-4 text-[#1DB56A]" />
          {{ link.name }}
        </a>

        <div class="h-px bg-white/10 my-1"></div>

        <a 
          href="https://github.com/amjadlle/busnap"
          target="_blank"
          @click="closeMobileMenu"
          class="px-4 py-2.5 rounded-xl text-sm font-semibold text-[#C5D6CC] hover:bg-white/10 transition-colors flex items-center gap-2.5"
        >
          <Github class="w-4 h-4" />
          GitHub Repository
        </a>
      </div>
    </Transition>
  </header>
</template>
