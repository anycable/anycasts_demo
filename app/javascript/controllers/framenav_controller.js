import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static values = { target: String, source: String };

  open() {
    const target = document.getElementById(this.targetValue);

    if (!target) {
      console.error(
        `Frame navigation target is not found: ${this.targetValue}`
      );
      return;
    }

    target.src = this.sourceValue;
  }
}
