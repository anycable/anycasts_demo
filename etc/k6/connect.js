// Build k6 with xk6-cable like this:
//    xk6 build v0.38.3 --with github.com/anycable/xk6-cable@v0.3.0

import { check, sleep, fail } from "k6";
import http from "k6/http";
import cable from "k6/x/cable";
import { randomIntBetween } from "https://jslib.k6.io/k6-utils/1.1.0/index.js";
import { textSummary } from 'https://jslib.k6.io/k6-summary/0.0.1/index.js';

import { Trend } from "k6/metrics";
let subscribeTrend = new Trend("subscribe_time", true);

// Load ENV from .env
function loadDotEnv() {
  try {
    let dotenv = open("./.env");
    dotenv.split(/[\n\r]/m).forEach((line) => {
      // Ignore comments
      if (line[0] === "#") return;

      let parts = line.split("=", 2);

      __ENV[parts[0]] = parts[1];
    });
  } catch (_err) {}
}

loadDotEnv();

let config = __ENV;

if (!config.CHANNEL_ID) throw "Specify CHANNEL_ID via env or .env";
if (!config.USER_IDS) throw "Specify USER_IDS via env or .env";

config.URL = config.URL || "http://localhost:3000";
config.TIME = (config.TIME || "60") | 0;

let channelId = config.CHANNEL_ID;
let userIds = config.USER_IDS.split(",").map((val) => parseInt(val));

let userId = userIds[__VU % userIds.length];

export const options = {
  scenarios: {
    default: {
      executor: "externally-controlled",
      vus: 1,
      maxVUs: 1000,
      duration: `${config.TIME}s`,
    },
    // default: {
    //   executor: 'ramping-vus',
    //   startVUs: 10,
    //   stages: [
    //     { duration: '30s', target: 200 },
    //     { duration: '30s', target: 500 },
    //     { duration: '15s', target: 500 },
    //     { duration: '30s', target: 200 },
    //     { duration: '30s', target: 0 },
    //   ],
    //   gracefulRampDown: `${config.TIME}s`,
    // }
  },
  summaryTrendStats: ["avg", "min", "max", "p(95)", "count"],
};

export function handleSummary(data) {
  // Only show metrics we want to see
  let {
    checks,
    http_req_duration,
    subscribe_time,
    ws_connecting,
    ws_msgs_received,
    ws_msgs_sent,
    ws_sessions,
  } = data.metrics;

  data.metrics = { checks, http_req_duration, subscribe_time, ws_connecting, ws_msgs_received, ws_msgs_sent, ws_sessions };

  return {
    stdout: textSummary(data, { indent: " ", enableColors: true }),
  };
}

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

  return {
    streamName: el.attr("signed-stream-name"),
    channelName: el.attr("channel") || "Turbo::StreamsChannel",
  };
}

export default function () {
  let cableOptions = {
    receiveTimeoutMs: 15000,
  };

  let url = config.URL;

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
    wsUrl = `${url.replace(/^http/, "ws")}${wsUrl}`;
  }

  let client = cable.connect(wsUrl, cableOptions);

  if (
    !check(client, {
      "successful connection": (obj) => obj,
    })
  ) {
    fail("connection failed");
  }

  let { streamName, channelName } = turboStreamName(html);

  if (!streamName) {
    fail("couldn't find a turbo stream element");
  }

  let start = Date.now();

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

  let end = Date.now();
  subscribeTrend.add(end - start);

  // Wait for the configured amout of time
  sleep(config.TIME * 1000);

  client.disconnect();
}
