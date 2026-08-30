<script setup lang="ts">
import Navbar from './components/Navbar.vue'
import HeroSection from './components/HeroSection.vue'
import AlarmSimulator from './components/AlarmSimulator.vue'
import FeaturesGrid from './components/FeaturesGrid.vue'
import HowItWorks from './components/HowItWorks.vue'
import PrivacyMatrix from './components/PrivacyMatrix.vue'
import DownloadCTA from './components/DownloadCTA.vue'
import AuthorSection from './components/AuthorSection.vue'
import FaqSection from './components/FaqSection.vue'
import Footer from './components/Footer.vue'
</script>

<template>
  <div class="relative min-h-screen selection:bg-[#1DB56A]/20 selection:text-[#1DB56A]">
    <!-- Floating Liquid Glass Navbar -->
    <Navbar />

    <!-- Main Content Flow -->
    <main>
      <HeroSection />
      <AlarmSimulator />
      <FeaturesGrid />
      <HowItWorks />
      <PrivacyMatrix />
      <DownloadCTA />
      <AuthorSection />
      <FaqSection />
    </main>

    <!-- Footer -->
    <Footer />
  </div>
</template>
