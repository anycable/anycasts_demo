[![Build](https://github.com/anycable/anycasts_demo/actions/workflows/test.yml/badge.svg?branch=main)](https://github.com/anycable/anycasts_demo/actions/workflows/test.yml)

# AnyCasts Demo

Demo application used in AnyCasts.

You can access the app at [anycasts-demo.fly.dev](https://anycasts-demo.fly.dev). Use `jack` or `alice` as a username and `qwerty` as a password.

## Ideas/suggestions

The flow is the following:
- Ideas/suggestions go to [Discussions](https://github.com/anycable/anycasts_demo/discussions).
- Approved/selected ideas go to [the public backlog](https://github.com/orgs/anycable/projects/5).

## Running locally

```sh
bin/setup

bin/dev
```

And that's it!

To run tests (RSpec), execute the following command:

```sh
bundle exec rspec
```

## Deploying with Kamal

### Prerequisites

- Two domain names (or subdomains) pointing to your server's public IP address (one for the app, one for WebSockets).
- Kamal installed on your local machine. If you don't have it, [follow the official installation guide](https://kamal-deploy.org/docs/installation/).

### Setup
#### 1: Create Configuration Files

The repository includes sample configuration files. 
Copy them to create your local `.env` and `.kamal/secrets` files.

```bash
cp .env.sample .env
cp .kamal/secrets.sample .kamal/secrets
```

#### 2: Configure Environment Variables

Open the .env file and fill in the values:


| Variable                  | Description                                                                          |
|---------------------------|--------------------------------------------------------------------------------------|
| `WEB_HOST`                | The public IP address of your server                                                 |
| `PROXY_HOST`              | The domain for the main web application (e.g. `anycasts-demo.yourdomain.com`)        |
| `WS_PROXY_HOST`           | The domain for the WebSocket server (e. g. `ws.yourdomain.com`)                      |
| `WS_ALLOWED_ORIGINS`      | The domain of the main app, to allow WebSocket connections (e.g. `*.yourdomain.com`) |
| `KAMAL_REGISTRY_SERVER`   | Docker registry hostname (e.g. `registry.digitalocean.com`)                          |
| `KAMAL_REGISTRY_USERNAME` | Username for the Docker registry                                                     |
| `KAMAL_REGISTRY_PASSWORD` | Password the Docker registry                                                         |
| `ANYCABLE_SECRET`         | A strong secret for AnyCable. (use the default `s3cЯeT`)                             |
| `RUBY_VERSION`            | Ruby version (default `3.3.6`)                                                       |
| `WS_NATS_CLUSTER_HOST`    | Hostname or IP for the NATS cluster seed node (for cluster mode)                     |
| `WS_NATS_HOST`            | Hostname or IP for the secondary NATS node (for cluster mode)                        |


#### 3: Deploy the Application


```bash

kamal setup
```

### Alternative: Single-Server Embedded NATS Configuration

Use `deploy_single_server_nats.yml` to run a single AnyCable‑Go instance hosting both WebSocket server and embedded NATS

```bash
kamal setup --config-file=config/deploy_single_server_nats.yml

# or
kamal deploy --config-file=config/deploy_single_server_nats.yml
```

### Cluster-Mode Embedded NATS Configuration

For a multi-node NATS cluster, use `deploy_cluster_nats.yml`. 
This configuration brings up two AnyCable‑Go accessories:

- Seed node (websocket-cluster): runs embedded NATS (client port 4242, cluster port 4243) on `WS_NATS_CLUSTER_HOST`.

- Join node (websocket): runs embedded NATS (client port 4322, cluster port 4323) on WS_NATS_HOST, and routes to the seed's cluster port.

```bash 
kamal setup --config-file=config/deploy_cluster_nats.yml
kamal deploy --config-file=config/deploy_cluster_nats.yml
```

The variables `WS_NATS_CLUSTER_HOST` and `WS_NATS_HOST` must each point to the respective host/IP where the accessory runs. 
Rails/RPC processes will connect to the cluster via these seed and join addresses.

