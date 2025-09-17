import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("input", this.format.bind(this))
  }

  format(e) {
    let value = this.inputTarget.value.replace(/\D/g, "")

    if (value.length > 4) {
      value = value.slice(0, 4)
    }

    if (value.length > 2) {
      value = value.slice(0, 2) + "/" + value.slice(2)
    }

    this.element.value = value
  }
}
