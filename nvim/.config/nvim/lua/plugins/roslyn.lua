-- C#（Unity）向け LSP。Roslyn Language Server を Mason 経由で導入する
return {
  -- Roslyn LS は Mason 公式レジストリに未収録のため、追加レジストリを登録する。
  -- registries はリストなので LazyVim 既定を上書きする形になる。公式レジストリを
  -- 先頭に残しておかないと他の LSP が引けなくなる点に注意
  {
    "mason-org/mason.nvim",
    opts = {
      registries = {
        "github:mason-org/mason-registry",
        "github:Crashdummyy/mason-registry",
      },
    },
  },

  -- Roslyn LSP（Unity 対応フォーク: sln/csproj の選択強化・複数 sln 対応）
  {
    "ownself/roslyn.nvim",
    ft = { "cs" },
    opts = {
      -- "auto" は Unity のような大規模プロジェクトで保存毎に数秒フリーズするため off。
      -- 代償として外部でファイルが変わったら Space l r（LspRestart）で手動再起動する
      filewatching = "off",
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = { ensure_installed = { "c_sharp" } },
  },
}
