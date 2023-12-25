require("bluloco").setup({
    style       = "auto", -- "auto" | "dark" | "light"
    transparent = false,
    italics     = false,
    terminal    = vim.fn.has("gui_running") == 1, -- bluoco colors are enabled in gui terminals per default.
    guicursor   = true,
})

-- 外观
vim.opt.signcolumn = "yes"
vim.opt.background = "dark"
vim.opt.termguicolors = true
-- vim.cmd('colorscheme bluloco')
-- vim.cmd [[colorscheme tokyonight]]
-- vim.cmd[[colorscheme nord]]
vim.cmd [[colorscheme onenord]]
-- vim.cmd [[colorscheme vscode]]
