<script setup lang="ts">
import { Github, Globe } from 'lucide-vue-next'

const currentYear = new Date().getFullYear()
</script>

<template>
  <footer class="border-t border-emerald-500/10 bg-[#09120d]/90 py-12 px-4 sm:px-6 mt-16 transition-colors">
    <div class="max-w-7xl mx-auto flex flex-col md:flex-row items-center justify-between gap-6 text-center md:text-left">
      
      <!-- Brand & Description -->
      <div class="space-y-2">
        <div class="flex items-center justify-center md:justify-start gap-2.5">
          <img src="/logo.png" alt="Busnap Logo" class="w-7 h-7 rounded-lg shadow-sm" />
          <span class="font-extrabold text-lg tracking-tight text-white">Busnap</span>
          <span class="text-[10px] uppercase font-bold px-2 py-0.5 rounded-full bg-[#1DB56A]/15 text-[#1DB56A] border border-[#1DB56A]/30">Open Source</span>
        </div>
        <p class="text-xs sm:text-sm text-[#8A9C90] max-w-sm">
          A smart, privacy-first proximity alarm app built with Flutter. Created by <a href="https://amjad.mapki.in" target="_blank" class="text-white font-semibold hover:text-[#1DB56A] underline decoration-emerald-500/50">Amjad P A</a>.
        </p>
      </div>

      <!-- Quick Nav Links -->
      <div class="flex flex-wrap items-center justify-center gap-5 text-xs sm:text-sm font-medium text-[#A4B8AB]">
        <a href="#simulator" class="hover:text-[#1DB56A] transition-colors">Simulator</a>
        <a href="#features" class="hover:text-[#1DB56A] transition-colors">Features</a>
        <a href="#how-it-works" class="hover:text-[#1DB56A] transition-colors">How It Works</a>
        <a href="#creator" class="hover:text-[#1DB56A] transition-colors">Author</a>
        <a href="#faq" class="hover:text-[#1DB56A] transition-colors">FAQ</a>
        <a href="https://amjad.mapki.in" target="_blank" class="hover:text-[#1DB56A] transition-colors flex items-center gap-1">
          <Globe class="w-3.5 h-3.5" />
          Portfolio
        </a>
        <a href="https://github.com/amjadlle/busnap" target="_blank" class="hover:text-[#1DB56A] transition-colors flex items-center gap-1">
          <Github class="w-3.5 h-3.5" />
          GitHub
        </a>
      </div>

      <!-- License & Copyright -->
      <div class="text-xs text-[#8A9C90] space-y-1">
        <div>Licensed under the <a href="https://github.com/amjadlle/busnap/blob/main/LICENSE" target="_blank" class="underline hover:text-[#1DB56A]">MIT License</a>.</div>
        <div>&copy; {{ currentYear }} <a href="https://amjad.mapki.in" target="_blank" class="hover:text-white">Amjad P A</a>. All rights reserved.</div>
      </div>

    </div>
  </footer>
</template>
