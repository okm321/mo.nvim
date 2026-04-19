# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.1.0] - 2026-04-19

### Added

- Initial release.
- `:MoAdd` — add the current Markdown buffer to mo.
- `:MoAddDir` — add all `*.md` / `*.mdx` files in a directory.
- `:MoPick` — fuzzy-pick files via snacks.nvim / telescope.nvim / fzf-lua
  (auto-detected in that priority order).
- `:MoDiff` — add changed Markdown files from `git diff` (staged,
  unstaged, and untracked).
- `:MoWatch` — watch glob patterns, with `-t <target>` support.
- `:MoStatus` — show mo server status in a floating window.
- `:MoRestart`, `:MoShutdown`, `:MoClear` — server lifecycle controls.
- `auto_add` option to register Markdown buffers automatically on
  `BufEnter`.
- `target` option for a default target group.
- `port` and `no_open` options mapped to the corresponding mo CLI flags.
- `doc/mo.txt` (`:help mo.nvim`).

[Unreleased]: https://github.com/okm321/mo.nvim/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/okm321/mo.nvim/releases/tag/v0.1.0
