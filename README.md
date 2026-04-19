# mo.nvim

A Neovim plugin for [mo](https://github.com/k1LoW/mo), a Markdown viewer that opens `.md` files in a browser with live-reload.

Add files, manage groups, and control the mo server without leaving Neovim. Supports multi-file selection via snacks.nvim, Telescope, or fzf-lua.

## Requirements

- [mo](https://github.com/k1LoW/mo) (installed and in PATH)
- Neovim >= 0.10
- (Optional) [snacks.nvim](https://github.com/folke/snacks.nvim), [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim), or [fzf-lua](https://github.com/ibhagwan/fzf-lua) for `:MoPick`

## Installation

### lazy.nvim

```lua
{
  "your-name/mo.nvim",
  ft = { "markdown" },
  opts = {},
}
```

### Setup

```lua
require("mo").setup({
  port = 6275,       -- mo server port
  no_open = false,   -- don't auto-open browser
  auto_add = false,  -- auto-add markdown files on BufEnter
  target = nil,      -- default target group
})
```

## Commands

| Command | Description |
|---------|-------------|
| `:MoAdd [target]` | Add current file to mo (optional: target group) |
| `:MoAddDir [path] [target]` | Add all Markdown files in a directory |
| `:MoPick [target]` | Pick files to add via snacks.nvim / Telescope / fzf-lua |
| `:MoStatus` | Show server status in a floating window |
| `:MoWatch [patterns...]` | Watch glob patterns (e.g., `:MoWatch **/*.md -t docs`) |
| `:MoRestart` | Restart the mo server |
| `:MoShutdown` | Shut down the mo server |
| `:MoClear` | Clear the mo session |

## MoPick

`:MoPick` opens a file picker listing all Markdown files in the current directory. It auto-detects installed pickers (priority: snacks.nvim > Telescope > fzf-lua).

- `<Tab>` to toggle selection on individual files
- `<CR>` to add selected files to mo
- `<C-a>` to select all (snacks.nvim / Telescope)

```vim
:MoPick           " Add to default group
:MoPick design    " Add to "design" group
```

## Keymap Examples

```lua
vim.keymap.set("n", "<leader>mo", "<cmd>MoAdd<cr>", { desc = "Add to mo" })
vim.keymap.set("n", "<leader>mp", "<cmd>MoPick<cr>", { desc = "Pick files for mo" })
vim.keymap.set("n", "<leader>ms", "<cmd>MoStatus<cr>", { desc = "mo status" })
```

## License

MIT — See [LICENSE](LICENSE)

This plugin wraps [mo](https://github.com/k1LoW/mo) by Ken'ichiro Oyama, also licensed under MIT.
