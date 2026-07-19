-- LSP 挙動の調整
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      -- インレイヒント（引数名・推論型の仮想テキスト）を既定で表示しない。
      -- 見たいときは Space u h でバッファ単位にトグルできる
      inlay_hints = { enabled = false },
      -- 診断フロート（Space c d）に枠線を付けて本文と区別しやすくする
      -- （背景色は ui.lua の NormalFloat / FloatBorder で調整）
      diagnostics = {
        float = { border = "rounded" },
      },
    },
  },
}
