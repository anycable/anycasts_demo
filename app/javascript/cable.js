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
        history: { since: this.restoreSince }
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
      return subscription.resolve(identifier)
    }

    if (type === 'reject_subscription') {
      let subscription = this.pendingSubscriptions[identifier]
      if (!subscription) {
        return this.logger.error('subscription not found', { identifier })
      }

      return subscription.reject(new SubscriptionRejectedError())
    }

    if (message) {
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

  recoverableClosure(err) {
    return false
  }
}

export default createConsumer({
  protocol: new ActionCableExtProtocol(),
  encoder: new JSONEncoder(),
  tokenRefresher: fetchTokenFromHTML()
});
