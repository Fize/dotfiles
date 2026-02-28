return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = { "latex" },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      -- 确保opts存在且有一个linters_by_ft表
      opts.linters_by_ft = opts.linters_by_ft or {}
      -- 为markdown文件类型设置一个空的linter列表
      opts.linters_by_ft.markdown = nil -- 或者设置为 {} 来完全禁用
      -- 如果你还想禁用markdown相关变体的linting
      -- opts.linters_by_ft["markdown.mdx"] = nil
      -- opts.linters_by_ft["markdown.cudown"] = nil
      return opts
    end,
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      heading = {
        -- 恢复默认图标，用 Nerd Font 图标替换 # 标记
        icons = { "󰲡 ", "󰲣 ", "󰲥 ", "󰲧 ", "󰲩 ", "󰲫 " },
        sign = true,
      },
    },
  },
}
