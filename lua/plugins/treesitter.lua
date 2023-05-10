require'nvim-treesitter.configs'.setup {
  -- 不同的语言
  ensure_installed = { "lua", "vim", "bash", "sql", "toml", "vue",
  "json", "yaml", "javascript", "go", "gomod", "gosum", "python", "html", "css"},


  highlight = { enable = true },
  indent = { enable = true },

  -- 不同括号颜色区分
  rainbow = {
    enable = true,
    -- Which query to use for finding delimiters
    query = 'rainbow-parens',
    -- Highlight the entire buffer all at once
    strategy = require 'ts-rainbow'.strategy.global,
  }
}
