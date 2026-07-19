-- LazyVim デフォルト: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- 追加の autocmd はここに定義する

-- LazyVim は markdown / gitcommit / text で英語スペルチェックを有効にするが、
-- 日本語文書ではほぼ全文が誤検出（赤下波線）になるため無効化する。
-- LazyVim 側の autocmd より後に登録されるため、こちらの spell=false が勝つ。
-- 英文を書くときは :setlocal spell で一時的に有効化できる
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("no_spell_japanese_docs", { clear = true }),
  pattern = { "markdown", "gitcommit", "text" },
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- フォーカス移動に連動するペイン自動拡大は廃止した（勝手に動いて使いづらいため）。
-- 拡大は Space m（config/keymaps.lua の toggle_expand_window）で明示的に行う。
-- ターミナル（Claude Code 含む）には幅固定を付与し、均等化(Ctrl+w =)や
-- Space m の拡大時にも設定/手動で決めた幅を維持する
vim.api.nvim_create_autocmd("TermOpen", {
  group = vim.api.nvim_create_augroup("term_fixwidth", { clear = true }),
  callback = function()
    vim.opt_local.winfixwidth = true
  end,
})

-- カーソルのあるウィンドウだけ cursorline を表示し、アクティブな分割を判別しやすくする
local active_cursorline = vim.api.nvim_create_augroup("active_cursorline", { clear = true })
vim.api.nvim_create_autocmd({ "WinEnter", "FocusGained" }, {
  group = active_cursorline,
  callback = function()
    vim.opt_local.cursorline = true
  end,
})
vim.api.nvim_create_autocmd({ "WinLeave", "FocusLost" }, {
  group = active_cursorline,
  callback = function()
    vim.opt_local.cursorline = false
  end,
})
