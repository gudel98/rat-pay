import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.element.addEventListener("input", this.format.bind(this))
  }

  format() {
    this.element.value = this.element.value.replace(/\D/g, "")
  }
}
