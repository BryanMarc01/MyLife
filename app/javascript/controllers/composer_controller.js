import { Controller } from "@hotwired/stimulus"

const SECTION_META = {
  ideas: {
    label: "Nueva idea",
    placeholder: "¿Qué estás pensando?",
    color: "#eeeaf8"
  },
  tasks: {
    label: "Nueva tarea",
    placeholder: "¿Qué necesitas hacer?",
    color: "#e8e1f3"
  },
  money: {
    label: "Nuevo gasto",
    placeholder: "¿En qué gastaste?",
    color: "#f3f0f8"
  }
}

export default class extends Controller {
  static targets = [
    "modal",
    "typeInput",
    "titleInput",
    "amountWrapper",
    "amountInput",
    "label",
    "submitButton",
    "typeButton",
    "micButton"
  ]

  static values = {
    defaultType: { type: String, default: "ideas" }
  }

  connect() {
    this.currentType = this.defaultTypeValue || "ideas"
    this.recognition = null
    this.isDictating = false
  }

  open(event) {
    const requestedType = event?.params?.type || event?.currentTarget?.dataset?.composerType || this.defaultTypeValue || "ideas"
    this.setType(requestedType)
    if (this.hasTitleInputTarget) this.titleInputTarget.value = ""
    if (this.hasAmountInputTarget) this.amountInputTarget.value = ""
    this.syncSubmitState()

    if (this.hasModalTarget) {
      this.modalTarget.hidden = false
      setTimeout(() => {
        if (this.hasTitleInputTarget) this.titleInputTarget.focus()
      }, 20)
    }
  }

  close() {
    this.stopDictation()
    if (this.hasModalTarget) {
      this.modalTarget.hidden = true
    }
  }

  backdropClose(event) {
    if (event.target === this.modalTarget) {
      this.close()
    }
  }

  switchType(event) {
    const newType = event.currentTarget.dataset.type
    if (newType) {
      this.setType(newType)
      if (this.hasTitleInputTarget) this.titleInputTarget.focus()
    }
  }

  setType(type) {
    const meta = SECTION_META[type] || SECTION_META.ideas
    this.currentType = type

    if (this.hasTypeInputTarget) {
      this.typeInputTarget.value = type
    }
    if (this.hasLabelTarget) {
      this.labelTarget.textContent = meta.label
    }
    if (this.hasTitleInputTarget) {
      this.titleInputTarget.placeholder = meta.placeholder
    }
    if (this.hasAmountWrapperTarget) {
      this.amountWrapperTarget.hidden = type !== "money"
    }

    this.typeButtonTargets.forEach((btn) => {
      const btnType = btn.dataset.type
      const isSelected = btnType === type
      btn.classList.toggle("is-active", isSelected)
      btn.style.background = isSelected ? SECTION_META[btnType].color : ""
    })
  }

  syncSubmitState() {
    if (!this.hasSubmitButtonTarget || !this.hasTitleInputTarget) return
    const valid = this.titleInputTarget.value.trim().length > 0
    this.submitButtonTarget.disabled = !valid
  }

  toggleDictation() {
    if (this.isDictating) {
      this.stopDictation()
      return
    }

    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
    if (!SpeechRecognition) {
      if (this.hasTitleInputTarget) this.titleInputTarget.focus()
      return
    }

    this.recognition = new SpeechRecognition()
    this.recognition.lang = "es-ES"
    this.recognition.interimResults = true
    this.recognition.continuous = false

    this.isDictating = true
    if (this.hasMicButtonTarget) this.micButtonTarget.classList.add("is-recording")

    this.recognition.onresult = (event) => {
      let text = ""
      for (let i = 0; i < event.results.length; i++) {
        text += event.results[i][0].transcript
      }
      if (this.hasTitleInputTarget && text.trim()) {
        this.titleInputTarget.value = text.trim()
        this.syncSubmitState()
      }
    }

    this.recognition.onend = () => {
      this.isDictating = false
      if (this.hasMicButtonTarget) this.micButtonTarget.classList.remove("is-recording")
    }

    this.recognition.onerror = () => {
      this.isDictating = false
      if (this.hasMicButtonTarget) this.micButtonTarget.classList.remove("is-recording")
    }

    this.recognition.start()
  }

  stopDictation() {
    if (this.recognition && this.isDictating) {
      try {
        this.recognition.stop()
      } catch (_e) {}
    }
    this.isDictating = false
    if (this.hasMicButtonTarget) this.micButtonTarget.classList.remove("is-recording")
  }
}
