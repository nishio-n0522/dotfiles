-- LazyVim デフォルト: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- devcontainer 内（docker exec 経由、$SSH_TTY なし）ではクリップボードプロバイダが
-- 自動選択されないため OSC 52 を明示する。コピーはターミナル(Windows Terminal 等)経由で
-- ホストへ届く。ペーストは OSC 52 のクリップボード読み出しに未対応のターミナルで
-- ハングするため、nvim 内のレジスタを返すフォールバックにする（ホスト側からの貼り付けは
-- ターミナルのペースト機能 Ctrl+Shift+V を使う）。
local function paste_from_register()
  return { vim.fn.split(vim.fn.getreg('"'), "\n"), vim.fn.getregtype('"') }
end

vim.g.clipboard = {
  name = "osc52-copy-only",
  copy = {
    ["+"] = require("vim.ui.clipboard.osc52").copy("+"),
    ["*"] = require("vim.ui.clipboard.osc52").copy("*"),
  },
  paste = {
    ["+"] = paste_from_register,
    ["*"] = paste_from_register,
  },
}

-- ステータスラインを分割ウィンドウごとに表示する。
-- LazyVim 既定の 3（画面全体で1本）だと分割時に各ウィンドウのファイル名が出ず、
-- どの分割に何が開いているか判別しづらい。lualine は起動時に laststatus==3 かで
-- global/per-window を切り替えるため、plugins より先に読まれるここで設定する。
vim.opt.laststatus = 2

-- シンボルチェーンは dropbar（ウィンドウ上部のパンくず）で表示するため、
-- ステータスライン側の Trouble シンボル表示は外して混雑を減らす
vim.g.trouble_lualine = false

-- root ディレクトリ検出の優先順位。LazyVim 既定は { "lsp", { ".git", "lua" }, "cwd" } で
-- LSP のルートが最優先だが、本リポジトリはモノレポで .git はリポジトリ直下、package.json /
-- tsconfig.json は app/ 配下にある。そのため app/ 内の TS ファイルを開いた状態だと
-- tsserver のルート（app/）が root と判定され、Space e のエクスプローラーが app/ で開いてしまう。
-- .git を LSP より前に置き、常にリポジトリルート（.git のある場所）を root にする
vim.g.root_spec = { ".git", "lsp", "cwd" }

-- ペイン拡大（Space m）で他のウィンドウが縮む際の下限幅。
-- 完全に潰れて見えなくなるのを防ぐ（自動拡大は廃止済み、拡大は明示操作のみ）
vim.opt.winminwidth = 12
