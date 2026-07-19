-- LazyVim デフォルト: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- 追加のキーマップはここに定義する

-- カーソルのあるペインを下記の比率（幅 / 高さ）へ拡大 ⇔ 均等に戻すトグル。好みで調整してよい
local expand_width_ratio = 0.45
local expand_height_ratio = 0.65

-- フォーカス移動に連動する自動拡大は「勝手に動いて使いづらい」ため廃止し、明示操作にした。
-- winfixwidth を持つウィンドウ（Claude Code 等のターミナル）の幅は減算して尊重する
-- （高さ側は winfixheight を考慮しない簡易版。固定高パネルは winminheight までしか縮まない）。
-- 拡大済みかの判定は実寸からの推測のため、拡大中にターミナル開閉等で目標値が変わると
-- 「戻す」ではなく再拡大になることがある（もう一度押せば均等化に落ちる）。
-- 全画面まで広げたいときは従来どおり Space w m（最大化トグル）を使う
local function toggle_expand_window()
  local cur = vim.api.nvim_get_current_win()
  local total = vim.o.columns
  local fixed = 0
  for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if w ~= cur and vim.api.nvim_win_get_config(w).relative == "" and vim.wo[w].winfixwidth then
      fixed = fixed + vim.api.nvim_win_get_width(w) + 1
    end
  end
  -- 拡大時に他の非固定ウィンドウへ最低1枚分残す予約幅（winminwidth + セパレータ1桁）。
  -- options.lua の winminwidth 変更に追従させるため値を直接書かない
  local reserve_w = vim.o.winminwidth + 1
  -- ステータスライン・コマンドライン・他ウィンドウの最低高のための予約行数（概算）。
  -- 「単一ウィンドウ等で高さが物理的に届かない場合も拡大済みとみなす」ための上限クランプに使う
  local reserve_h = 5
  local target_w = math.min(math.floor(total * expand_width_ratio), total - fixed - reserve_w)
  local target_h = math.floor(vim.o.lines * expand_height_ratio)
  local cur_w = vim.api.nvim_win_get_width(cur)
  local cur_h = vim.api.nvim_win_get_height(cur)
  if cur_w >= target_w and cur_h >= math.min(target_h, vim.o.lines - reserve_h) then
    vim.cmd("wincmd =") -- 既に拡大済みなら均等サイズへ戻す
  else
    if target_w > cur_w then
      vim.api.nvim_win_set_width(cur, target_w)
    end
    if target_h > cur_h then
      vim.api.nvim_win_set_height(cur, target_h)
    end
  end
end

vim.keymap.set("n", "<leader>m", toggle_expand_window, { desc = "ペインを拡大 ⇔ 均等に戻す" })

-- ターミナル（Claude Code 含む）から Normal モードへ抜けるキー。
-- 既定の Ctrl+\ Ctrl+n は日本語キーボードで押しづらいため F2 を割り当てる。
-- Esc 系は Claude Code 本体の機能（中断・前メッセージ編集）と衝突するため使わない
vim.keymap.set("t", "<F2>", [[<C-\><C-n>]], { desc = "ターミナルから Normal モードへ" })

-- プロジェクト全体の型チェック（app/ で tsc --noEmit）を実行し、結果を quickfix に一覧表示する。
-- LSP の診断（Space x x）は「このセッションで開いたことのあるファイル」しか対象にならないため、
-- 未オープンのファイルも含めて型エラーを洗いたいときはこちらを使う。
-- 一覧は Enter でジャンプ、閉じても ]q / [q でファイル横断の巡回ができる
local function typecheck_project()
  local repo = vim.fs.root(vim.fn.getcwd(), ".git") or vim.fn.getcwd()
  local app = repo .. "/app"
  vim.notify("tsc --noEmit 実行中…（数十秒かかることがあります）", vim.log.levels.INFO)
  vim.system(
    { "pnpm", "exec", "tsc", "--noEmit", "--pretty", "false" },
    { cwd = app, text = true },
    vim.schedule_wrap(function(out)
      local raw = (out.stdout or "") .. "\n" .. (out.stderr or "")
      local lines = {}
      for line in raw:gmatch("[^\r\n]+") do
        -- 「src/foo.ts(12,3): error TS2322: …」形式の行だけ拾い、app/ からの
        -- 相対パスを nvim のカレントディレクトリに依らず解決できる絶対パスへ直す
        local file, rest = line:match("^(.-%.%a+)(%(%d+,%d+%).*)$")
        if file and rest then
          table.insert(lines, app .. "/" .. file .. rest)
        end
      end
      vim.fn.setqflist({}, " ", { title = "tsc --noEmit", lines = lines, efm = "%f(%l\\,%c): %m" })
      if #lines > 0 then
        vim.notify(#lines .. " 件の型エラー", vim.log.levels.WARN)
        vim.cmd("copen")
      elseif out.code ~= 0 then
        -- 型エラー行を1件も拾えていないのに tsc が非ゼロ終了 = tsc 自体の失敗。
        -- tsconfig エラーやクラッシュ、グローバルエラー（TS18003 等）はファイル接頭辞を
        -- 持たず上の正規表現に載らないため、成功（型エラーなし）と誤認しないよう
        -- 生の出力を添えてエラー通知する
        vim.notify("tsc 実行に失敗しました (code " .. out.code .. ")\n" .. vim.trim(raw), vim.log.levels.ERROR)
        vim.cmd("cclose")
      else
        vim.notify("型エラーなし", vim.log.levels.INFO)
        vim.cmd("cclose")
      end
    end)
  )
end

vim.api.nvim_create_user_command("Typecheck", typecheck_project, {})
vim.keymap.set(
  "n",
  "<leader>xc",
  typecheck_project,
  { desc = "型チェック（プロジェクト全体 → quickfix）" }
)

-- 開いているファイルのパスをクリップボードへコピーする（VS Code の Copy Path 相当）。
-- 相対パスは nvim を起動したディレクトリ（:pwd）基準。+ レジスタ経由なので
-- OSC 52 設定によりホスト（Windows Terminal 等）のクリップボードにも届く
local function yank_file_path(expr)
  return function()
    -- プラグイン由来のバッファ名は oil:// のような URI であってファイルパスではないため除外する。
    -- ターミナルは既定名が term://… だが :file で改名できるので buftype でも判定する。
    -- 名前なしバッファ（起動直後・:enew・quickfix 等）も同様に除外。
    -- なお buftype 全体では絞らない。help は実ファイルを指すのでコピーでき、
    -- acwrite（実ファイル相当のバッファ）を巻き込まずに済む
    local name = vim.api.nvim_buf_get_name(0)
    if name == "" or vim.bo.buftype == "terminal" or name:match("^%a[%w+.-]*://") then
      vim.notify("バッファにファイルパスがありません", vim.log.levels.WARN)
      return
    end
    local path = vim.fn.expand(expr)
    vim.fn.setreg("+", path)
    vim.notify("コピー: " .. path)
  end
end

vim.keymap.set("n", "<leader>fy", yank_file_path("%:."), { desc = "ファイルの相対パスをコピー" })
vim.keymap.set("n", "<leader>fY", yank_file_path("%:p"), { desc = "ファイルの絶対パスをコピー" })

-- gd の別ペイン版: 定義を「隣のウィンドウ」で開く（VS Code の「横に定義を開く」相当）。
-- 隣の通常ファイルウィンドウ（ターミナル・フロート除く）があればそこで開き、
-- なければ左右分割を作って開く。呼び出し元のペインはカーソル位置ごとそのまま残る。
-- 定義が複数あるとき（オーバーロード等）は先頭を採用する簡易版
local function definition_in_other_window()
  local cur = vim.api.nvim_get_current_win()
  vim.lsp.buf.definition({
    on_list = function(list)
      local item = list.items and list.items[1]
      if not item then
        vim.notify("定義が見つかりません", vim.log.levels.WARN)
        return
      end
      local target
      for _, w in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
        if w ~= cur and vim.api.nvim_win_get_config(w).relative == "" then
          local b = vim.api.nvim_win_get_buf(w)
          if vim.bo[b].buftype == "" then
            target = w
            break
          end
        end
      end
      if target then
        vim.api.nvim_set_current_win(target)
      else
        vim.cmd("vsplit")
      end
      local buf = item.bufnr or vim.fn.bufadd(item.filename)
      vim.bo[buf].buflisted = true
      vim.api.nvim_win_set_buf(0, buf)
      vim.api.nvim_win_set_cursor(0, { item.lnum, math.max((item.col or 1) - 1, 0) })
      vim.cmd("normal! zz")
    end,
  })
end

vim.keymap.set("n", "gV", definition_in_other_window, { desc = "定義を隣のペインで開く" })

-- LSP サーバの再起動。Roslyn（C#）は plugins/roslyn.lua で filewatching を off に
-- しているため、Unity 側でのファイル生成・外部ツールでの変更を検知しない。
-- .cs の追加や Regenerate Project Files の後はこれで拾い直す
vim.keymap.set("n", "<leader>lr", function()
  vim.cmd("LspRestart")
end, { noremap = true, desc = "LSP サーバを再起動" })
