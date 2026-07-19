-- 保存時整形をリポジトリのフォーマッタ oxfmt（pnpm format と同一）に差し替える。
-- プロジェクトの node_modules/.bin/oxfmt を stdin モードで呼ぶため、
-- .oxfmtrc.json の設定・バージョンとも CLI 実行時と完全に一致する。
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      local util = require("conform.util")
      opts.formatters = opts.formatters or {}
      opts.formatters.oxfmt = {
        -- 通常はファイル位置から上方向に node_modules/.bin/oxfmt を探す。
        -- app/ の外のファイル（.devcontainer/nvim/snippets/*.json 等）では見つからないため、
        -- リポジトリルート直下の app/node_modules へフォールバックする
        command = function(self, ctx)
          local cmd = util.from_node_modules("oxfmt")(self, ctx)
          if cmd ~= "oxfmt" then
            return cmd
          end
          local root = vim.fs.root(ctx.dirname, ".git")
          local fallback = root and (root .. "/app/node_modules/.bin/oxfmt")
          return (fallback and vim.fn.executable(fallback) == 1) and fallback or cmd
        end,
        args = { "--stdin-filepath", "$FILENAME" },
        -- 通常はファイル位置から上方向に .oxfmtrc.json / package.json を探して cwd にする。
        -- app/ の外のファイル（.devcontainer/nvim/snippets/*.json 等）では祖先に無く nil になり、
        -- app/.oxfmtrc.json の設定が効かず oxfmt 既定へ落ちてしまう。バイナリ解決と同様に
        -- リポジトリ直下の app/ を cwd のフォールバックにして、CLI 実行時と設定を一致させる
        cwd = function(self, ctx)
          local found = util.root_file({ ".oxfmtrc.json", "package.json" })(self, ctx)
          if found then
            return found
          end
          local root = vim.fs.root(ctx.dirname, ".git")
          local fallback = root and (root .. "/app")
          return (fallback and vim.fn.isdirectory(fallback) == 1) and fallback or nil
        end,
      }
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      -- json / jsonc も対象にする。lefthook の format glob（*.json 含む）と同じ扱いにして、
      -- スニペット定義など app/ 外の JSON も保存時に整形できるようにする
      for _, ft in ipairs({ "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc" }) do
        opts.formatters_by_ft[ft] = { "oxfmt" }
      end
      -- markdown の保存時自動整形は無効化する。LazyVim の markdown extra は
      -- markdownlint-cli2 --fix 等を登録するが、このリポジトリの docs/ は
      -- フォーマッタ管理されておらず、保存のたびに整形差分が PR に混入してしまう
      opts.formatters_by_ft.markdown = {}
      opts.formatters_by_ft["markdown.mdx"] = {}
      return opts
    end,
  },
}
