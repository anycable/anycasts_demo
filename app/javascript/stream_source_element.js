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
    this.subscription = cable.subscriptions.create(this.channel,
      {
        received: this.dispatchMessageEvent.bind(this)
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

  get channel() {
    const channel = this.getAttribute("channel")
    const signed_stream_name = this.getAttribute("signed-stream-name")
    return { channel, signed_stream_name, ...snakeize({ ...this.dataset }) }
  }
}

customElements.define("turbo-cable-stream-source", TurboCableStreamSourceElement)
