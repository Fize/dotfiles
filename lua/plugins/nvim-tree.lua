-- 默认启动时不开启nvim-tree
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- 设置术语颜色以启用突出显示组
vim.opt.termguicolors = true

-- empty setup using defaults
require("nvim-tree").setup()
