import { Controller } from "@hotwired/stimulus"

const EYE_OPEN_SVG = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M2.062 12.348a1 1 0 0 1 0-.696 10.75 10.75 0 0 1 19.876 0 1 1 0 0 1 0 .696 10.75 10.75 0 0 1-19.876 0"/><circle cx="12" cy="12" r="3"/></svg>`
const EYE_OFF_SVG = `<svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M10.733 5.076a10.744 10.744 0 0 1 11.205 6.575 1 1 0 0 1 0 .696 10.747 10.747 0 0 1-1.444 2.49"/><path d="M14.084 14.158a3 3 0 0 1-4.242-4.242"/><path d="M17.479 17.499a10.75 10.75 0 0 1-15.417-5.151 1 1 0 0 1 0-.696 10.75 10.75 0 0 1 4.446-5.143"/><path d="m2 2 20 20"/></svg>`

export default class extends Controller {
  static targets = [
    "password",
    "confirmation",
    "strengthBar",
    "strengthLabel",
    "matchHint",
    "socialModal",
    "socialProviderInput",
    "socialProviderLabel",
    "socialEmailInput",
    "socialNameInput"
  ]

  togglePassword(event) {
    const button = event.currentTarget
    const wrapper = button.closest(".bpa-password-wrap")
    if (!wrapper) return

    const input = wrapper.querySelector("input")
    if (!input) return

    const showing = input.type === "text"
    input.type = showing ? "password" : "text"
    button.innerHTML = showing ? EYE_OPEN_SVG : EYE_OFF_SVG
    button.setAttribute("aria-label", showing ? "Mostrar contraseña" : "Ocultar contraseña")
  }

  evaluateStrength() {
    if (!this.hasPasswordTarget) return
    const val = this.passwordTarget.value
    let score = 0

    if (val.length >= 6) score += 1
    if (val.length >= 10) score += 1
    if (/[A-Z]/.test(val) && /[a-z]/.test(val)) score += 1
    if (/\d/.test(val) || /[^A-Za-z0-9]/.test(val)) score += 1

    const colors = ["#e7e3ed", "#f79009", "#fdb022", "#6027ed", "#12b76a"]
    const labels = [
      "Mínimo 6 caracteres",
      "Seguridad: Débil",
      "Seguridad: Aceptable",
      "Seguridad: Buena",
      "Seguridad: Fuerte"
    ]

    this.strengthBarTargets.forEach((bar, index) => {
      bar.style.backgroundColor = index < score ? colors[score] : "#e7e3ed"
    })

    if (this.hasStrengthLabelTarget) {
      this.strengthLabelTarget.textContent = val.length === 0 ? "Mínimo 6 caracteres" : labels[score]
      this.strengthLabelTarget.style.color = val.length === 0 ? "#96919f" : colors[score]
    }

    this.checkMatch()
  }

  checkMatch() {
    if (!this.hasPasswordTarget || !this.hasConfirmationTarget || !this.hasMatchHintTarget) return
    const pw = this.passwordTarget.value
    const conf = this.confirmationTarget.value

    if (!conf) {
      this.matchHintTarget.textContent = ""
      return
    }

    if (pw === conf) {
      this.matchHintTarget.textContent = "✓ Las contraseñas coinciden"
      this.matchHintTarget.style.color = "#12b76a"
    } else {
      this.matchHintTarget.textContent = "Las contraseñas aún no coinciden"
      this.matchHintTarget.style.color = "#f79009"
    }
  }

  openSocial(event) {
    const provider = event.currentTarget.dataset.provider || "google"
    const providerName = provider === "github" ? "GitHub" : "Google"

    if (this.hasSocialProviderInputTarget) {
      this.socialProviderInputTarget.value = provider
    }
    if (this.hasSocialProviderLabelTarget) {
      this.socialProviderLabelTarget.textContent = providerName
    }
    if (this.hasSocialModalTarget) {
      this.socialModalTarget.hidden = false
      setTimeout(() => {
        if (this.hasSocialEmailInputTarget) this.socialEmailInputTarget.focus()
      }, 20)
    }
  }

  closeSocial() {
    if (this.hasSocialModalTarget) {
      this.socialModalTarget.hidden = true
    }
  }
}
