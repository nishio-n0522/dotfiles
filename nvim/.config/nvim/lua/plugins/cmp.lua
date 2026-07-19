-- 補完（blink.cmp）の調整
return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        -- メニュー表示直後は未選択（Tab を押して初めて候補にフォーカスが当たる）。
        -- これにより未選択の間は j/k も通常の文字入力として使える
        list = {
          selection = { preselect = false },
        },
      },
      keymap = {
        -- VSCode 風のフロー: メニュー表示中に Tab で先頭候補にフォーカス →
        -- j / k で上下移動 → もう一度 Tab（または Enter）で確定。
        -- 候補が未選択の間、j / k はそのまま文字として入力される。
        -- メニュー非表示時の Tab は従来どおり snippet ジャンプ → AI 補完 → タブ文字挿入
        ["<Tab>"] = {
          function(cmp)
            if not cmp.is_menu_visible() then
              return
            end
            if cmp.get_selected_item() then
              return cmp.accept()
            end
            return cmp.select_next()
          end,
          LazyVim.cmp.map({ "snippet_forward", "ai_nes", "ai_accept" }),
          "fallback",
        },
        ["j"] = {
          function(cmp)
            if cmp.is_menu_visible() and cmp.get_selected_item() then
              return cmp.select_next()
            end
          end,
          "fallback",
        },
        ["k"] = {
          function(cmp)
            if cmp.is_menu_visible() and cmp.get_selected_item() then
              return cmp.select_prev()
            end
          end,
          "fallback",
        },
      },
      sources = {
        providers = {
          snippets = {
            opts = {
              -- typescriptreact(.tsx) では typescript 用スニペットも候補に出す。
              -- 運用ルール: .ts / .tsx 両方で使うスニペットは snippets/typescript.json に、
              -- JSX を含む .tsx 専用のものだけ snippets/typescriptreact.json に書く
              extended_filetypes = {
                typescriptreact = { "typescript" },
              },
            },
          },
        },
      },
    },
  },
}
