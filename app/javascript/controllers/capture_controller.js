import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "statusBadge",
    "timer",
    "recordButton",
    "waveform",
    "bar",
    "transcriptEditor",
    "transcriptInput",
    "titleInput",
    "categoryInput",
    "durationInput",
    "audioDataInput",
    "proposalTitle",
    "proposalCategory",
    "proposalStep",
    "proposalStepsList",
    "micHint"
  ]

  static values = {
    previewUrl: String
  }

  connect() {
    this.recording = false
    this.seconds = parseInt(this.durationInputTarget.value || "0", 10)
    this.categories = ["Proyectos", "Personal", "Vida diaria"]
    this.recordedAudioUrl = null
    this.audioChunks = []
    this.updateTranscript()
  }

  disconnect() {
    this.stopRecordingInternal()
  }

  async toggleRecording() {
    if (this.recording) {
      this.stopRecordingInternal()
    } else {
      await this.startRecordingInternal()
    }
  }

  async startRecordingInternal() {
    this.recording = true
    this.statusBadgeTarget.textContent = "Escuchando tu micrófono…"
    this.statusBadgeTarget.parentElement.classList.add("is-live")
    this.recordButtonTarget.textContent = "Detener grabación"
    this.waveformTarget.classList.add("is-recording")

    if (this.hasMicHintTarget) {
      this.micHintTarget.textContent = "Habla en voz alta. Tu voz se transcribe y organiza en tiempo real."
    }

    this.startTimer()

    // 1. Iniciar captura de audio real con MediaRecorder + Web Audio Analyser
    try {
      if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
        this.stream = await navigator.mediaDevices.getUserMedia({ audio: true })
        this.audioChunks = []
        this.mediaRecorder = new MediaRecorder(this.stream)
        this.mediaRecorder.ondataavailable = (e) => {
          if (e.data && e.data.size > 0) this.audioChunks.push(e.data)
        }
        this.mediaRecorder.onstop = () => {
          const blob = new Blob(this.audioChunks, { type: "audio/webm" })
          this.recordedAudioUrl = URL.createObjectURL(blob)
          const reader = new FileReader()
          reader.onloadend = () => {
            if (this.hasAudioDataInputTarget) {
              this.audioDataInputTarget.value = reader.result
            }
          }
          reader.readAsDataURL(blob)
        }
        this.mediaRecorder.start()
        this.startAudioVisualizer(this.stream)
      }
    } catch (err) {
      if (this.hasMicHintTarget) {
        this.micHintTarget.textContent = "Modo dictado directo activado (puedes hablar o escribir abajo)."
      }
    }

    // 2. Iniciar reconocimiento de voz en español (Web Speech API)
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
    if (SpeechRecognition) {
      try {
        this.recognition = new SpeechRecognition()
        this.recognition.lang = "es-ES"
        this.recognition.continuous = true
        this.recognition.interimResults = true
        const baseText = this.transcriptEditorTarget.value.trim()

        this.recognition.onresult = (event) => {
          let interim = ""
          let finalTranscript = ""
          for (let i = 0; i < event.results.length; i++) {
            const piece = event.results[i][0].transcript
            if (event.results[i].isFinal) {
              finalTranscript += piece + " "
            } else {
              interim += piece
            }
          }
          const combined = [baseText, (finalTranscript + interim).trim()].filter(Boolean).join(" ")
          this.transcriptEditorTarget.value = combined
          this.updateTranscript()
        }
        this.recognition.start()
      } catch (e) {
        // Ignorar si ya está activo
      }
    }
  }

  stopRecordingInternal() {
    this.recording = false
    if (this.hasStatusBadgeTarget) {
      this.statusBadgeTarget.textContent = this.seconds > 0 ? "Grabación lista" : "Listo para grabar"
      this.statusBadgeTarget.parentElement.classList.remove("is-live")
    }
    if (this.hasRecordButtonTarget) {
      this.recordButtonTarget.textContent = this.seconds > 0 ? "Seguir grabando" : "Iniciar grabación por voz"
    }
    if (this.hasWaveformTarget) {
      this.waveformTarget.classList.remove("is-recording")
    }

    this.stopTimer()

    if (this.recognition) {
      try { this.recognition.stop() } catch (e) {}
      this.recognition = null
    }

    if (this.mediaRecorder && this.mediaRecorder.state !== "inactive") {
      try { this.mediaRecorder.stop() } catch (e) {}
    }

    if (this.stream) {
      this.stream.getTracks().forEach((t) => t.stop())
      this.stream = null
    }

    if (this.animFrame) {
      cancelAnimationFrame(this.animFrame)
      this.animFrame = null
    }

    if (this.audioCtx) {
      try { this.audioCtx.close() } catch (e) {}
      this.audioCtx = null
    }
  }

  startAudioVisualizer(stream) {
    try {
      const AudioContextClass = window.AudioContext || window.webkitAudioContext
      this.audioCtx = new AudioContextClass()
      const source = this.audioCtx.createMediaStreamSource(stream)
      const analyser = this.audioCtx.createAnalyser()
      analyser.fftSize = 64
      source.connect(analyser)
      const dataArray = new Uint8Array(analyser.frequencyBinCount)

      const renderFrame = () => {
        if (!this.recording) return
        analyser.getByteFrequencyData(dataArray)
        this.barTargets.forEach((bar, i) => {
          const val = dataArray[i % dataArray.length] || 10
          const height = Math.max(8, Math.min(48, Math.round((val / 255) * 48)))
          bar.style.height = `${height}px`
        })
        this.animFrame = requestAnimationFrame(renderFrame)
      }
      renderFrame()
    } catch (e) {}
  }

  startTimer() {
    this.stopTimer()
    this.interval = setInterval(() => {
      this.seconds += 1
      this.durationInputTarget.value = this.seconds
      const mins = String(Math.floor(this.seconds / 60)).padStart(2, "0")
      const secs = String(this.seconds % 60).padStart(2, "0")
      this.timerTarget.textContent = `${mins}:${secs}`
    }, 1000)
  }

  stopTimer() {
    if (this.interval) {
      clearInterval(this.interval)
      this.interval = null
    }
  }

  playPreview() {
    if (this.recordedAudioUrl) {
      const audio = new Audio(this.recordedAudioUrl)
      this.waveformTarget.classList.add("is-recording")
      audio.onended = () => this.waveformTarget.classList.remove("is-recording")
      audio.play()
      return
    }

    const text = this.transcriptEditorTarget.value.trim()
    if ("speechSynthesis" in window && text) {
      window.speechSynthesis.cancel()
      const utterance = new SpeechSynthesisUtterance(text.replace(/[«»]/g, ""))
      utterance.lang = "es-ES"
      this.waveformTarget.classList.add("is-recording")
      utterance.onend = () => this.waveformTarget.classList.remove("is-recording")
      window.speechSynthesis.speak(utterance)
    }
  }

  updateTranscript() {
    const raw = this.transcriptEditorTarget.value.trim()
    this.transcriptInputTarget.value = raw

    if (this.previewTimeout) clearTimeout(this.previewTimeout)
    this.previewTimeout = setTimeout(() => this.fetchServerProposal(raw), 180)
  }

  async fetchServerProposal(rawText) {
    if (!this.hasPreviewUrlValue) return
    try {
      const token = document.querySelector('meta[name="csrf-token"]')?.content
      const res = await fetch(this.previewUrlValue, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          "X-CSRF-Token": token
        },
        body: JSON.stringify({ transcript: rawText })
      })
      if (!res.ok) return
      const data = await res.json()
      this.proposalTitleTarget.value = data.title
      this.titleInputTarget.value = data.title
      this.proposalCategoryTarget.textContent = data.category
      this.categoryInputTarget.value = data.category
      this.proposalStepTarget.textContent = data.first_step
      if (this.hasProposalStepsListTarget && Array.isArray(data.steps)) {
        this.proposalStepsListTarget.innerHTML = data.steps
          .map((s) => `<li class="aml-preview-step-item">• ${s}</li>`)
          .join("")
      }
    } catch (e) {}
  }

  syncCustomTitle(event) {
    this.titleInputTarget.value = event.target.value
  }

  cycleCategory() {
    const current = this.proposalCategoryTarget.textContent.trim()
    const nextIdx = (this.categories.indexOf(current) + 1) % this.categories.length
    const nextCategory = this.categories[nextIdx]
    this.proposalCategoryTarget.textContent = nextCategory
    this.categoryInputTarget.value = nextCategory
  }

  loadExample(event) {
    const text = event.currentTarget.dataset.exampleText
    if (text) {
      this.transcriptEditorTarget.value = text
      this.seconds = 18
      this.durationInputTarget.value = 18
      this.timerTarget.textContent = "00:18"
      this.updateTranscript()
    }
  }
}
