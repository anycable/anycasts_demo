import { connectStreamSource, disconnectStreamSource } from "@hotwired/turbo"
import cable from "cable"

function snakeize(obj) {
  if (!obj || typeof obj !== 'object') return obj;
  if (obj instanceof Date || obj instanceof RegExp) return obj;
  if (Array.isArray(obj)) return obj.map(snakeize);
  return Object.keys(obj).reduce(function (acc, key) {
      var camel = key[0].toLowerCase() + key.slice(1).replace(/([A-Z]+)/g, function (m, x) {
          return '_' + x.toLowerCase();
      });
      acc[camel] = snakeize(obj[key]);
      return acc;
  }, {});
};

class TurboCableStreamSourceElement extends HTMLElement {
  async connectedCallback() {
    connectStreamSource(this)
    this.historyReceived = false
    this.pendingMessages = []

    this.subscription = cable.subscriptions.create(this.channel,
      {
        received: this.receive.bind(this),
        connected: this.requestHistory.bind(this),
        disconnected: this.handleDisconnect.bind(this)
      }
    )
  }

  disconnectedCallback() {
    disconnectStreamSource(this)
    if (this.subscription) this.subscription.unsubscribe()
  }

  dispatchMessageEvent(data) {
    const event = new MessageEvent("message", { data })
    return this.dispatchEvent(event)
  }

  receive(data){
    if (data.type === "history_ack") {
      this.historyReceived = true

      this.pendingMessages.forEach((data) => {
        this.dispatchMessageEvent(data)
      })

      this.pendingMessages.length = 0

      return
    }

    if (!this.historyReceived) {
      this.pendingMessages.push(data)
      return
    }

    this.dispatchMessageEvent(data)
  }

  handleDisconnect() {
    this.historyReceived = false
  }

  requestHistory() {
    let selector = this.getAttribute("history_selector")
    if (!selector) {
      this.historyReceived = true
      return
    }

    let lastElement = document.querySelector(selector)

    if (!lastElement) {
      this.historyReceived = true
      return
    }

    this.subscription.perform("history", {last_message_id: lastElement.dataset.id})
  }

  get channel() {
    const channel = this.getAttribute("channel")
    const signed_stream_name = this.getAttribute("signed-stream-name")
    return { channel, signed_stream_name, ...snakeize({ ...this.dataset }) }
  }
}

customElements.define("turbo-cable-stream-source", TurboCableStreamSourceElement)
