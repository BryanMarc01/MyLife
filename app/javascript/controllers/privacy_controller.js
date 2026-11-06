import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["amount"]
  static values = {
    balance: String,
    hiddenByDefault: Boolean
  }

  connect() {
    this.hidden = this.hiddenByDefaultValue || false
  }

  toggle() {
    this.hidden = !this.hidden
    if (this.hidden) {
      this.amountTarget.textContent = "•••• €"
      this.amountTarget.style.letterSpacing = "3px"
    } else {
      this.amountTarget.textContent = this.balanceValue || "2.480,00 €"
      this.amountTarget.style.letterSpacing = "-1px"
    }
  }
}
