return {
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
}
