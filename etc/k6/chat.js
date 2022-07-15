// Build k6 with xk6-cable like this:
//    xk6 build v0.38.3 --with github.com/anycable/xk6-cable@v0.3.0

import { check, sleep, fail } from "k6";
import http from "k6/http";
import cable from "k6/x/cable";
import { randomIntBetween } from "https://jslib.k6.io/k6-utils/1.1.0/index.js";

import { Trend } from "k6/metrics";
let rttTrend = new Trend("rtt", true);

// Load ENV from .env
function loadDotEnv() {
  try {
    let dotenv = open("./.env")
    dotenv.split(/[\n\r]/m).forEach( (line) => {
      // Ignore comments
      if (line[0] === "#") return

      let parts = line.split("=", 2)

      __ENV[parts[0]] = parts[1]
    })
  } catch(_err) {
  }
}

loadDotEnv()

let config = __ENV

if(!config.CHANNEL_ID) throw "Specify CHANNEL_ID via env or .env"
if(!config.USER_IDS) throw "Specify USER_IDS via env or .env"

let channelId = config.CHANNEL_ID
let userIds = config.USER_IDS.split(",").map(val => parseInt(val));

let userId = userIds[__VU % userIds.length];

// Find and return action-cable-url on the page
function cableUrl(doc) {
  let el = doc.find('meta[name="action-cable-url"]');
  if (!el) return;

  return el.attr("content");
}

// Find and return the Turbo stream name
function turboStreamName(doc) {
  let el = doc.find("#messages turbo-cable-stream-source");
  if (!el) return;

  return el.attr("signed-stream-name");
}

export default function () {
  let cableOptions = {
    receiveTimeoutMs: 5000
  }

  // Manually set authentication cookies
  let jar = http.cookieJar();
  jar.set("http://localhost:3000", "user_id", `${userId}`);

  sleep(randomIntBetween(5, 10) / 5);

  let res = http.get(`http://localhost:3000/channels/${channelId}`);

  if (
    !check(res, {
      "is status 200": (r) => r.status === 200,
    })
  ) {
    fail("couldn't open channel");
  }

  const html = res.html();
  let wsUrl = cableUrl(html);

  if (!wsUrl) {
    fail("couldn't find cable url on the page");
  }

  if (wsUrl.startsWith("/")) {
    wsUrl = `ws://localhost:3000${wsUrl}`
  }

  let client = cable.connect(wsUrl, cableOptions);

  if (
    !check(client, {
      "successful connection": (obj) => obj,
    })
  ) {
    fail("connection failed");
  }

  let streamName = turboStreamName(html);

  if (!streamName) {
    fail("couldn't find a turbo stream element");
  }

  let channel = client.subscribe("Turbo::StreamsChannel", {
    signed_stream_name: streamName,
  });

  if (
    !check(channel, {
      "successful subscription": (obj) => obj,
    })
  ) {
    fail("failed to subscribe");
  }

  for (let i = 0; i < 5; i++) {
    let startMessage = Date.now();

    // We have an HTML form to submit chat messages,
    // submitting it initiates a broadcasting
    let formRes = res.submitForm({
      formSelector: `#chat_channel_${channelId} form`,
      fields: { "message[content]": `hello from ${userId} numero ${i+1}` },
    });

    if (
      !check(formRes, {
        "is status 200": (r) => r.status === 200,
      })
    ) {
      fail("couldn't submit message form");
    }

    // Msg here is an HTML element (<turbo-stream>),
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

    let endMessage = Date.now();
    rttTrend.add(endMessage - startMessage);

    sleep(randomIntBetween(5, 10) / 10);
  }

  sleep(randomIntBetween(5, 10) / 10);

  client.disconnect();
}
