import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["panel", "sublabel", "audioPlayer", "playButton"]
  static values = {
    transcript: String,
    duration: Number
  }

  toggle() {
    const isHidden = this.panelTarget.classList.toggle("is-hidden")
    const dur = this.durationValue || 18
    if (this.hasSublabelTarget) {
      this.sublabelTarget.textContent = isHidden
        ? `${dur} s · Ver transcripción y reproductor`
        : `${dur} s · Ocultar transcripción`
    }
  }

  playAudio(event) {
    event.stopPropagation()
    if (this.hasAudioPlayerTarget) {
      if (this.audioPlayerTarget.paused) {
        this.audioPlayerTarget.play()
      } else {
        this.audioPlayerTarget.pause()
      }
      return
    }

    if ("speechSynthesis" in window) {
      window.speechSynthesis.cancel()
      const clean = (this.transcriptValue || "").replace(/[«»]/g, "")
      const utterance = new SpeechSynthesisUtterance(clean)
      utterance.lang = "es-ES"
      window.speechSynthesis.speak(utterance)
    }
  }
}
