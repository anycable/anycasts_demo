import { Controller } from "@hotwired/stimulus"
import cable from "cable"

// memoize the channel
let channel
const subscribeToOnlineChannel = () => {
  if (channel) return channel

  channel = cable.subscribeTo("OnlineChannel")
  return channel
}

export default class extends Controller {
  static targets = ["user"];

  async connect() {
    this.channel = subscribeToOnlineChannel();
    this.unlistener = this.channel.on("presence", this.handlePresence.bind(this));

    this.userTargets.forEach(this.userTargetConnected.bind(this));
  }

  disconnect() {
    if (this.unlistener) {
      this.unlistener();
    }
  }

  async userTargetConnected(el) {
    const userId = el.dataset.id;
    if (!userId) return;

    if (!this.channel) return;

    const presence = await this.channel.presence.info();
    if (presence[userId]) {
      el.classList.add("online");
    }
  }

  handlePresence(event) {
    const { type, id } = event;

    if (!(type === "join" || type === "leave")) return;

    this.userTargets.forEach(el => {
      if (el.dataset.id === id) {
        el.classList.toggle("online", type === "join");
      }
    });
  }
}
