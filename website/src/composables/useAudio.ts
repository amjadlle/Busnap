import { ref } from 'vue'

const isPlaying = ref(false)
let audioInstance: HTMLAudioElement | null = null

export function useAudio() {
  const toggleSound = (soundUrl: string = '/alarm.mp3') => {
    if (isPlaying.value && audioInstance) {
      audioInstance.pause()
      audioInstance.currentTime = 0
      isPlaying.value = false
      return
    }

    if (!audioInstance) {
      audioInstance = new Audio(soundUrl)
      audioInstance.onended = () => {
        isPlaying.value = false
      }
    } else {
      audioInstance.src = soundUrl
    }

    audioInstance.play()
      .then(() => {
        isPlaying.value = true
      })
      .catch((err) => {
        console.warn('Audio autoplay blocked or failed:', err)
        isPlaying.value = false
      })
  }

  const stopSound = () => {
    if (audioInstance) {
      audioInstance.pause()
      audioInstance.currentTime = 0
    }
    isPlaying.value = false
  }

  // Play a brief synthesized notification chime via Web Audio API as well
  const playChime = (type: 'info' | 'warning' | 'alarm' = 'info') => {
    try {
      const ctx = new (window.AudioContext || (window as unknown as { webkitAudioContext: typeof AudioContext }).webkitAudioContext)()
      const osc = ctx.createOscillator()
      const gain = ctx.createGain()

      osc.connect(gain)
      gain.connect(ctx.destination)

      const now = ctx.currentTime
      if (type === 'info') {
        osc.frequency.setValueAtTime(587.33, now) // D5
        osc.frequency.setValueAtTime(880, now + 0.1) // A5
        gain.gain.setValueAtTime(0.15, now)
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.35)
        osc.start(now)
        osc.stop(now + 0.35)
      } else if (type === 'warning') {
        osc.frequency.setValueAtTime(659.25, now) // E5
        osc.frequency.setValueAtTime(987.77, now + 0.12) // B5
        gain.gain.setValueAtTime(0.2, now)
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.45)
        osc.start(now)
        osc.stop(now + 0.45)
      } else {
        // Alarm urgency
        osc.type = 'sawtooth'
        osc.frequency.setValueAtTime(880, now)
        osc.frequency.setValueAtTime(1046.5, now + 0.1)
        gain.gain.setValueAtTime(0.25, now)
        gain.gain.exponentialRampToValueAtTime(0.001, now + 0.5)
        osc.start(now)
        osc.stop(now + 0.5)
      }
    } catch {
      // Audio context might be disabled in background
    }
  }

  return {
    isPlaying,
    toggleSound,
    stopSound,
    playChime,
  }
}
