// Build k6 with xk6-cable like this:
//    xk6 build v0.38.3 --with github.com/anycable/xk6-cable@v0.3.0

import { check, sleep, fail } from "k6";
import http from "k6/http";
import cable from "k6/x/cable";
import { randomIntBetween } from "https://jslib.k6.io/k6-utils/1.1.0/index.js";
import { cableUrl, turboStreamSource } from 'https://anycable.io/xk6-cable/jslib/k6-rails/0.1.0/index.js'
import { loadDotEnv } from './dotenv.js';

loadDotEnv()

let config = __ENV

if(!config.CHANNEL_ID) throw "Specify CHANNEL_ID via env or .env"
if(!config.USER_ID) throw "Specify USER_ID via env or .env"

let url = config.URL || "http://localhost:3000"
let channelId = config.CHANNEL_ID
let userId = config.USER_ID;
let region = config.REGION;

export default function () {
  let headers = {};

  if (region) {
    headers["fly-prefer-region"] = region;
  }

  let cableOptions = {
    receiveTimeoutMs: 15000,
    headers
  }

  // Manually set authentication cookies
  let jar = http.cookieJar();
  jar.set(url, "user_id", `${userId}`);

  sleep(randomIntBetween(5, 10) / 5);

  let res = http.get(`${url}/channels/${channelId}`, { headers });

  if (
    !check(res, {
      "is status 200": (r) => r.status === 200,
    })
  ) {
    fail(`couldn't open channel page: ${res.status_text}`);
  }

  const html = res.html();
  let wsUrl = cableUrl(html);

  if (!wsUrl) {
    fail("couldn't find cable url on the page");
  }

  if (wsUrl.startsWith("/")) {
    wsUrl = `${url.replace('http', 'ws')}${wsUrl}`
  }

  let client = cable.connect(wsUrl, cableOptions);

  if (
    !check(client, {
      "successful connection": (obj) => obj,
    })
  ) {
    fail("connection failed");
  }

  let { streamName, channelName } = turboStreamSource(html, "#messages");

  if (!streamName) {
    fail("couldn't find a turbo stream element");
  }

  let channel = client.subscribe(channelName, {
    signed_stream_name: streamName,
  });

  if (
    !check(channel, {
      "successful subscription": (obj) => obj,
    })
  ) {
    fail("failed to subscribe");
  }

  sleep(randomIntBetween(1, 2));

  // We have an HTML form to submit chat messages,
  // submitting it initiates a broadcasting
  let formRes = res.submitForm({
    formSelector: `#chat_channel_${channelId} form`,
    fields: { "message[content]": config.MESSAGE || `hello from ${userId}` },
    params: { headers }
  });

  if (
    !check(formRes, {
      "is status 200": (r) => r.status === 200,
    })
  ) {
    fail(`couldn't submit message form: ${formRes.status_text}`);
  }

  // Msg here is an HTML element (<turbo-stream>) or a JSON,
  // we use data attributes to indicate the message author,
  // so, here we're looking for our messages
  let message = channel.receive((msg) => {
    if (msg.user_id) {
      return msg.user_id === userId
    } else {
      return msg.includes(`data-user-id="${userId}"`);
    }
  });

  if (
    !check(message, {
      "received its own message": (obj) => obj,
    })
  ) {
    fail("expected message hasn't been received");
  }

  sleep(randomIntBetween(5, 10) / 10);

  client.disconnect();
}
