import { Turbo, cable } from "@hotwired/turbo-rails";

const { connectStreamSource, disconnectStreamSource } = Turbo;
const { subscribeTo } = cable;

class StreamSourceElement extends HTMLElement {
  async connectedCallback() {
    connectStreamSource(this);
    let element = this;
    let presenceId;

    this.subscription = await subscribeTo(this.channel, {
      initialized() {
        this.pending = true
        this.pendingMessages = []
      },
      disconnected() {
        this.pending = true
        this.stopPresence()
      },
      received(data) {
        if (data.type === "history_ack") {
          this.pending = false
          while(this.pendingMessages.length > 0){
            this.received(this.pendingMessages.shift())
          }
          return
        }
        if (this.pending) {
          return this.pendingMessages.push(data)
        }

        element.dispatchMessageEvent(data)
      },
      connected() {
        let selector = element.getAttribute("cursor-selector")
        if (!selector) return

        let el = document.querySelector(selector)
        if (!el) return

        let cursor = el.getAttribute("data-cursor")
        if (!cursor) return

        this.perform("history", { cursor })

        this.startPresence()
      },
      startPresence() {
        presenceId = setInterval(() => this.perform("presence_keepalive"), 60000)
      },
      stopPresence() {
        if (presenceId) clearInterval(presenceId)
      }
    });
  }

  disconnectedCallback() {
    disconnectStreamSource(this);
    if (this.subscription) this.subscription.unsubscribe();
  }

  dispatchMessageEvent(data) {
    const event = new MessageEvent("message", { data });
    return this.dispatchEvent(event);
  }

  get channel() {
    const channel = this.getAttribute("channel");
    const signed_stream_name = this.getAttribute("signed-stream-name");

    let params = {};

    const paramsJSON = this.getAttribute("params");

    if (paramsJSON) {
      params = JSON.parse(paramsJSON);
    }

    const presence = this.getAttribute("presence");

    return { ...params, channel, signed_stream_name, presence };
  }
}

customElements.define("turbo-cable-stream-source-history", StreamSourceElement);
