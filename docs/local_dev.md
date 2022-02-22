# Local Development

## Linters

For using Rubocop you should install all required gems from `gemfiles/linters.gemfile`.
This repo is configured for use linters by [Pronto](https://github.com/prontolabs/pronto) under _git_ pre-commit hook see `lefthook.yml`.
By the way you should also install [Lefthook](https://github.com/evilmartians/lefthook/blob/master/docs/other.md) for running linters on only changed files.

__WARNING__: If you see errors during the installation something with `rugged` gem and you have macOS.
Please do following:

```sh
brew install cmake pkg-config
```
