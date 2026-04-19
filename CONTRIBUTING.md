# Contributing

Thanks for your interest in contributing to mo.nvim!

## Local development

Requires [mo](https://github.com/k1LoW/mo) to be installed on your `$PATH`.

Clone the repository and point your Neovim plugin manager at the local
checkout, or add it to `runtimepath` manually.

## Formatting

Code is formatted with [StyLua](https://github.com/JohnnyMorganz/StyLua):

```sh
stylua .
```

CI runs `stylua --check .` on every push and pull request.

## Linting

Static analysis is done with [luacheck](https://github.com/lunarmodules/luacheck):

```sh
luacheck lua plugin
```

## Documentation

User-facing changes must be reflected in:

- `README.md` and `README.ja.md`
- `doc/mo.txt` (run `:helptags ALL` locally to rebuild tags)
- `CHANGELOG.md` under `## [Unreleased]`

## Pull requests

- Keep each pull request focused on a single logical change.
- Explain the *why* in the description, not just the *what*.
- If the change affects commands or options, update the vimdoc and README.
- Commit messages can be in English or Japanese.

## Reporting issues

Please include:

- Neovim version (`nvim --version`)
- `mo` version (`mo --version`)
- Minimal reproduction steps
- Relevant messages from `:messages`
