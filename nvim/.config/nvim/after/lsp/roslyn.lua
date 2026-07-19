-- Roslyn LS 固有設定（nvim 0.11+ の vim.lsp.config 機構で自動的に読み込まれる）。
-- インレイヒントの「中身」をここで有効化する。表示自体のトグルは lsp.lua 側の
-- inlay_hints 設定と Space u h に従う
return {
  settings = {
    ["csharp|inlay_hints"] = {
      csharp_enable_inlay_hints_for_implicit_variable_types = true,
      csharp_enable_inlay_hints_for_types = true,
      dotnet_enable_inlay_hints_for_parameters = true,
    },
  },
}
