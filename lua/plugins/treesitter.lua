require 'nvim-treesitter.configs'.setup {
    -- 不同的语言
    ensure_installed = { "lua", "vim", "vimdoc", "query" },

    sync_install = false,

    auto_install = true,

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
