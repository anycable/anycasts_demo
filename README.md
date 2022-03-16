[![Build](https://github.com/anycable/anycasts_demo/actions/workflows/build.yml/badge.svg?branch=main)](https://github.com/anycable/anycasts_demo/actions/workflows/build.yml)
[![Lint](https://github.com/anycable/anycasts_demo/actions/workflows/lint.yml/badge.svg?branch=main)](https://github.com/anycable/anycasts_demo/actions/workflows/lint.yml)

# AnyCasts Demo

Demo application used in AnyCasts.

## Ideas/suggestions

The flow is the following:
- Ideas/suggestions go to [Discussions](https://github.com/anycable/anycasts_demo/discussions).
- Approved/selected ideas go to [the public backlog](https://github.com/orgs/anycable/projects/5).

## Docs

- [Docker for Development](docs/docker_for_dev.md)
- [Local Development](docs/local_dev.md)

## Git hooks for development

This project is configured with [Lefthook](https://github.com/evilmartians/lefthook) git hook manager.<br>
Follow this guide for setup it locally <https://github.com/evilmartians/lefthook/blob/master/docs/other.md>.

## GraphQL API

API available on `api/graphql` endpoint

## Specs

### System

System tests configured for running in local & docker environments.<br>
For docker environment [dip](https://github.com/bibendi/dip) using.<br>
Use this command if you want to run all suites:

```sh
dip rspec systems
```

Or this one for run specific spec:

```sh
dip rspec system spec/system/channel_spec.rb
```

Launching in local is simple:

```sh
bundle exec rspec --pattern spec/system/**/*_spec.rb
```

See [dip.yml](dip.yml) for additional info.
