# mo.nvim

[mo](https://github.com/k1LoW/mo) を Neovim から操作するプラグイン。

Markdown ファイルの追加・グループ管理・サーバー操作を Neovim 内で完結できます。  
snacks.nvim / Telescope / fzf-lua による複数ファイル選択にも対応。

## 必要なもの

- [mo](https://github.com/k1LoW/mo) >= 1.3.0（PATH に配置済み）
- Neovim >= 0.10
- （任意）[snacks.nvim](https://github.com/folke/snacks.nvim)、[telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)、または [fzf-lua](https://github.com/ibhagwan/fzf-lua)（`:MoPick` 用）

## インストール

### lazy.nvim

```lua
{
  "okm321/mo.nvim",
  ft = { "markdown" },
  opts = {},
}
```

### セットアップ

```lua
require("mo").setup({
  port = 6275,       -- mo サーバーのポート
  no_open = false,   -- ブラウザを自動で開かない
  auto_add = false,  -- BufEnter 時に自動追加
  target = nil,      -- デフォルトのターゲットグループ
})
```

## コマンド

| コマンド | 説明 |
|---------|------|
| `:MoAdd [target]` | 現在のファイルを mo に追加（target でグループ指定） |
| `:MoAddDir [path] [target]` | ディレクトリ内の Markdown を追加 |
| `:MoAddDiff [target]` | git で変更された Markdown を追加（staged / unstaged / untracked） |
| `:MoPick [target]` | ピッカーでファイルを選択して追加 |
| `:MoStatus` | サーバー状態を float window で表示 |
| `:MoWatch [patterns...]` | glob パターンで watch（`-t` でグループ指定可） |
| `:MoRestart` | サーバー再起動 |
| `:MoShutdown` | サーバー停止 |
| `:MoClear` | セッションクリア |

## MoPick

`:MoPick` でカレントディレクトリの Markdown ファイル一覧がピッカーで開きます。インストール済みのピッカーを自動検出します（優先順: snacks.nvim > Telescope > fzf-lua）。

- `<Tab>` で個別に選択をトグル
- `<CR>` で選択したファイルを mo に追加
- `<C-a>` で全選択（snacks.nvim / Telescope）

```vim
:MoPick           " default グループに追加
:MoPick design    " design グループに追加
```

## キーマップ例

```lua
vim.keymap.set("n", "<leader>mo", "<cmd>MoAdd<cr>", { desc = "Add to mo" })
vim.keymap.set("n", "<leader>mp", "<cmd>MoPick<cr>", { desc = "Pick files for mo" })
vim.keymap.set("n", "<leader>ms", "<cmd>MoStatus<cr>", { desc = "mo status" })
```

## ライセンス

MIT — [LICENSE](LICENSE) を参照

このプラグインは Ken'ichiro Oyama 氏の [mo](https://github.com/k1LoW/mo)（MIT ライセンス）をラップしています。
