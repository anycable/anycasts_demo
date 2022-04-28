import { createConsumer, fetchTokenFromHTML } from "@anycable/web"
import { NoopLogger, SubscriptionRejectedError, DisconnectedError, JSONEncoder } from "@anycable/core"

const now = () => (Date.now() / 1000) | 0

const renderDateFromMeta = () => {
  let element = document.head.querySelector(`meta[name='action-cable-render-time']`)

  if (element) {
    return (element.getAttribute('content') | 0)
  }
}

class ActionCableExtProtocol {
  constructor(opts = {}) {
    let { logger } = opts
    this.logger = logger || new NoopLogger()
    this.pendingSubscriptions = {}
    this.streamsPositions = {}
    this.subscriptionStreams = {}
    this.restoreSince = renderDateFromMeta() || now()
    this.sessionId = undefined;
  }

  attached(cable) {
    this.cable = cable
  }

  subscribe(channel, params) {
    let subscriptionPayload = { channel }
    if (params) {
      Object.assign(subscriptionPayload, params)
    }

    return new Promise((resolve, reject) => {
      let identifier = JSON.stringify(subscriptionPayload)

      this.pendingSubscriptions[identifier] = { resolve, reject }

      this.cable.send({
        command: 'subscribe',
        identifier,
        history: this.historyRequestFor(identifier)
      })
    })
  }

  unsubscribe(identifier) {
    this.cable.send({
      command: 'unsubscribe',
      identifier
    })

    return Promise.resolve()
  }

  perform(identifier, action, payload) {
    if (!payload) {
      payload = {}
    }

    payload.action = action

    this.cable.send({
      command: 'message',
      identifier,
      data: JSON.stringify(payload)
    })

    return Promise.resolve()
  }

  receive(msg) {
    /* eslint-disable consistent-return */
    if (typeof msg !== 'object') {
      this.logger.error('unsupported message format', { message: msg })
      return
    }

    let { type, identifier, message, reason, reconnect } = msg

    if (type === 'ping') {
      this.restoreSince = now()
      return this.cable.keepalive(msg.message)
    }

    if (type === 'welcome') {
      this.sessionId = msg.sid

      if (this.sessionId) {
        this.addSessionIdToUrl()
      }

      if (msg.restored) {
        this.cable.restored()

        for (let identifier in this.subscriptionStreams) {
          this.cable.send({
            identifier,
            command: "history",
            history: this.historyRequestFor(identifier)
          })
        }
      }

      return this.cable.connected()
    }

    if (type === 'disconnect') {
      let err = new DisconnectedError(reason)
      this.reset(err)

      if (reconnect === false) {
        this.cable.close(err)
      } else {
        this.cable.disconnected(err)
      }
      return
    }

    if (type === 'confirm_subscription') {
      let subscription = this.pendingSubscriptions[identifier]
      if (!subscription) {
        return this.logger.error('subscription not found', { identifier })
      }

      this.subscriptionStreams[identifier] = new Set()

      return subscription.resolve(identifier)
    }

    if (type === 'reject_subscription') {
      let subscription = this.pendingSubscriptions[identifier]
      if (!subscription) {
        return this.logger.error('subscription not found', { identifier })
      }

      delete this.subscriptionStreams[identifier]

      return subscription.reject(new SubscriptionRejectedError())
    }

    if (message) {
      this.trackStreamPosition(identifier, msg.stream_id, msg.epoch, msg.offset)
      return { identifier, message }
    }

    this.logger.warn(`unknown message type: ${type}`, { message: msg })
  }

  reset(err) {
    // Reject pending subscriptions
    for (let identifier in this.pendingSubscriptions) {
      this.pendingSubscriptions[identifier].reject(err)
    }

    this.pendingSubscriptions = {}
  }

  // TODO: Check for DisconnectedError (is not recoverable)
  recoverableClosure(err) {
    return !!this.sessionId
  }

  historyRequestFor(identifier) {
    let streams = {}

    if (this.subscriptionStreams[identifier]) {
      for (let stream of this.subscriptionStreams[identifier]) {
        let record = this.streamsPositions[stream]
        if (record) {
          streams[stream] = record
        }
      }
    }

    return { since: this.restoreSince, streams }
  }

  trackStreamPosition(identifier, stream, epoch, offset) {
    if (!this.subscriptionStreams[identifier]) {
      this.logger.warn(`received a message for an unknown subscription: ${identifier}`)
      return
    }

    this.subscriptionStreams[identifier].add(stream)
    this.streamsPositions[stream] = {epoch, offset}
  }

  addSessionIdToUrl() {
    const transport = this.cable.transport;
    const url = new URL(transport.url);

    url.searchParams.set("sid", this.sessionId);

    const newURL = `${url.protocol}//${url.host}${url.pathname}?${url.searchParams}`;

    transport.setURL(newURL);
  }
}

export default createConsumer({
  protocol: new ActionCableExtProtocol(),
  encoder: new JSONEncoder(),
  tokenRefresher: fetchTokenFromHTML()
});
