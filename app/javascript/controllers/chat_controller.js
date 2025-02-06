import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    userId: String
  }
  static targets = ["message"]

  connect() {
    this.scrollToBottom()
  }

  messageTargetConnected(element) {
    const newItemHeight = element.offsetHeight
    if (this.isScrolledToBottom(newItemHeight)) {
      this.scrollToBottom()
    }
    // mark message as mine
    const isMine = element.dataset.userId === this.userIdValue
    if (isMine) {
      element.classList.add("mine")
    }
  }

  scrollToBottom() {
    requestAnimationFrame(() => {
      this.element.scrollTo(0, this.element.scrollHeight)
    })
  }

  isScrolledToBottom(additionalHeight) {
    const buffer = 10 // px from bottom
    const position = this.element.scrollTop + this.element.clientHeight + additionalHeight
    const height = this.element.scrollHeight

    return position >= height - buffer
  }
}
