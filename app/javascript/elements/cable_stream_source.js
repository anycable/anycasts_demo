import { Turbo, cable } from "@hotwired/turbo-rails";

const { connectStreamSource, disconnectStreamSource } = Turbo;
const { subscribeTo } = cable;

class StreamSourceElement extends HTMLElement {
  async connectedCallback() {
    connectStreamSource(this);
    this.subscription = await subscribeTo(this.channel, {
      received: this.dispatchMessageEvent.bind(this),
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

    return { ...params, channel, signed_stream_name };
  }
}

customElements.define("turbo-cable-stream-source-ext", StreamSourceElement);
