-- カラースキーム: VS Code Dark Modern 風（vscode.nvim は Dark+/Dark Modern の再現テーマ）
return {
  {
    "Mofiqul/vscode.nvim",
    opts = {
      group_overrides = {
        -- 分割ウィンドウの境界線（非アクティブ側）。VS Code の通常ボーダー相当のグレー。
        -- アクティブウィンドウの枠は colorful-winsep が青で上描きする
        WinSeparator = { fg = "#454545" },
        -- 非アクティブウィンドウは背景・文字ともはっきり暗くし、アクティブなペインだけが
        -- 明るく「点灯」して見えるようにする
        NormalNC = { bg = "#101010", fg = "#767676" },
        -- Dark Modern の行ハイライトは背景とほぼ同色で見えないため、視認できる明るさに
        CursorLine = { bg = "#3c3c3c" },
        -- カーソル行の行番号を VS Code のアクセント色で強調
        CursorLineNr = { fg = "#0078d4", bold = true },
        -- flash.nvim の減光表示。既定は Comment にリンクされるが、VS Code 配色では
        -- コメントが緑（#6a9955）のため「画面が緑になる」ように見える。グレーの減光にする
        FlashBackdrop = { fg = "#5a5a5a" },
        -- フロート（診断 Space c d・ホバー K 等）の背景がエディタ背景(#1f1f1f)と
        -- ほぼ同色で区別できないため、一段明るいパネル色 + 枠線で分離する
        -- （#2d2d30 は VS Code のメニュー/ウィジェット背景色）
        NormalFloat = { bg = "#2d2d30" },
        FloatBorder = { fg = "#8a8a8a", bg = "#2d2d30" },
        FloatTitle = { fg = "#d4d4d4", bg = "#2d2d30", bold = true },
        -- カーソル下と同一シンボルのハイライト（snacks words / LSP documentHighlight）。
        -- 既定の #343b41 は背景と近すぎて気づけないため、VS Code Dark Modern の
        -- wordHighlight（#575757b8）/ wordHighlightStrong（#004972b8）をエディタ背景
        -- （#1f1f1f）に合成した実効色にする。Write（代入箇所）だけ青系で区別される
        LspReferenceText = { bg = "#474747" },
        LspReferenceRead = { bg = "#474747" },
        LspReferenceWrite = { bg = "#083d5a" },
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = { colorscheme = "vscode" },
  },

  -- アクティブなウィンドウの周囲だけ境界線を青く強調表示する
  -- （VS Code の「フォーカス中エディタの枠線」に相当）
  {
    "nvim-zh/colorful-winsep.nvim",
    event = "WinNew",
    opts = {
      highlight = "#0078d4",
    },
  },

  -- 各ウィンドウ上部に VS Code 式のパンくずリスト（パス + シンボルチェーン）を表示する。
  -- ステータスラインは幅が狭いと情報が押し出されて読めないため、パンくずは専用行に分離する。
  -- クリックでもジャンプ可能。キーボードからは <leader>; でピックモード
  {
    "Bekaboo/dropbar.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>;",
        function()
          require("dropbar.api").pick()
        end,
        desc = "パンくずから選んでジャンプ",
      },
    },
    opts = {
      icons = {
        ui = {
          bar = {
            -- 既定の区切りは Nerd Font 専用グリフで、フォントによっては ◆? に化ける。
            -- どのフォントにもある一般的な文字にする
            separator = " › ",
            extends = "…",
          },
        },
      },
    },
  },

  -- Explorer・ファイル検索・横断検索で隠しファイル（.devcontainer / .claude 等）も
  -- 既定で表示・検索対象にする。.gitignore されているもの（node_modules 等）は従来どおり非表示。
  -- 一時的な切り替えはピッカー内 Alt+h（隠しファイル）/ Alt+i（gitignore 対象）
  {
    "folke/snacks.nvim",
    opts = {
      picker = {
        sources = {
          explorer = { hidden = true },
          files = { hidden = true },
          grep = { hidden = true },
        },
      },
    },
  },

  -- テストコード（*.test.ts / *.spec.ts 等）に専用アイコンを割り当てる。
  -- VS Code の Material Icon Theme がテストファイルをフラスコ型で区別するのと同じ意図。
  -- mini.icons は最初のドット以降を「拡張子」として解決するため（foo.test.ts → "test.ts"）、
  -- 複合拡張子をキーに登録すれば通常の .ts / .tsx とは別のアイコンにできる。
  -- Explorer・bufferline・dropbar など mini.icons 経由の全表示に反映される。
  {
    "nvim-mini/mini.icons",
    opts = {
      extension = {
        ["test.ts"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
        ["test.tsx"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
        ["test.js"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
        ["test.jsx"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
        ["spec.ts"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
        ["spec.tsx"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
        ["spec.js"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
        ["spec.jsx"] = { glyph = "󰙨", hl = "MiniIconsGreen" },
      },
    },
  },

  -- tokyonight（LazyVim 既定テーマ）に戻す場合に備えた境界線設定。
  -- colorscheme を "tokyonight" に切り替えるだけで有効になる
  {
    "folke/tokyonight.nvim",
    opts = {
      on_highlights = function(hl, c)
        hl.WinSeparator = { fg = c.blue, bold = true }
      end,
    },
  },
}
