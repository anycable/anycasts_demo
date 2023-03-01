// Build k6 with xk6-cable like this:
//    xk6 build v0.38.3 --with github.com/anycable/xk6-cable@v0.3.0

import { check, sleep, fail } from "k6";
import http from "k6/http";
import cable from "k6/x/cable";
import { randomIntBetween } from "https://jslib.k6.io/k6-utils/1.1.0/index.js";

export const externalOptions = {
  scenarios: {
    default: {
      executor: 'externally-controlled',
      vus: 30,
      maxVUs: 500,
      duration: '5m'
    }
  }
};

export const options = __ENV.SKIP_OPTIONS ? {} : externalOptions;

import { Trend } from "k6/metrics";
let commandTrend = new Trend("command_duration", true);

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

let url = config.URL || "http://localhost:3000"
let channelId = config.CHANNEL_ID
let channelName = config.CHANNEL_NAME || "BenchmarkChannel"
let userIds = config.USER_IDS.split(",").map(val => parseInt(val));

let userId = userIds[__VU % userIds.length];

let delay = parseFloat(config.DELAY || '0.1')

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

  return { streamName: el.attr("signed-stream-name"), channelName: el.attr("channel") || "Turbo::StreamsChannel" };
}

export default function () {
  let cableOptions = {
    receiveTimeoutMs: 15000
  }

  // Manually set authentication cookies
  let jar = http.cookieJar();
  jar.set(url, "user_id", `${userId}`);

  sleep(randomIntBetween(5, 10) / 5);

  let res = http.get(`${url}/channels/${channelId}`);

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

  let channel = client.subscribe(channelName);

  if (
    !check(channel, {
      "successful subscription": (obj) => obj,
    })
  ) {
    fail("failed to subscribe");
  }

  for (let i = 0; i < 10; i++) {
    let start = Date.now();
    channel.perform("echo", { ts: start, content: `hello from ${__VU} numero ${i+1}`, delay: delay });

    sleep(randomIntBetween(5, 10) / 100);

    let incoming = channel.receiveAll(1);

    for(let message of incoming) {
      let received = message.__timestamp__ || Date.now();

      if (message.action == "echo") {
        let ts = message.ts;
        commandTrend.add(received - ts);
      }
    }

    sleep(randomIntBetween(5, 10) / 100);
  }

  sleep(randomIntBetween(2, 5));

  client.disconnect();
}
