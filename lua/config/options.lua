-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

vim.g.lazyvim_prettier_needs_config = false
vim.g.lazyvim_picker = "telescope"

local opt = vim.opt

opt.tabstop = 4 -- number of visual spaces per TAB
opt.softtabstop = 4 -- number of spacesin tab when editing
opt.shiftwidth = 4 -- insert 4 spaces on a tab
opt.expandtab = true -- tabs are spaces, mainly because of python

opt.clipboard = "unnamedplus" -- 使用系统剪贴板
opt.completeopt = { "menu", "menuone", "noselect", "preview" } -- 显示补全菜单，默认不选中
opt.mouse = "a" -- 允许使用鼠标
opt.syntax = "yes" -- 语法
opt.showcmd = false

-- UI
opt.relativenumber = true -- add numbers to each line on the left side
opt.cursorline = true -- highlight cursor line underneath the cursor horizontally
opt.splitbelow = true -- open new vertical split bottom
opt.splitright = true -- open new horizontal splits right
-- vim.opt.termguicolors = true        -- enabl 24-bit RGB color in the TUI
opt.showmode = false -- we are experienced, wo don't need the "-- INSERT --" mode hint
opt.wrap = true -- auto wrap
opt.scrolloff = 7 -- 上下移动时，至少保留的行数

-- Searching
opt.incsearch = true -- search as characters are entered
opt.hlsearch = false -- do not highlight matches
opt.ignorecase = true -- ignore case in searches by default
opt.smartcase = true -- but make it case sensitive if an uppercase is entered

-- Backup File
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- ColorScheme catppuccin-latte, catppuccin-frappe, catppuccin-macchiato, catppuccin-mocha
opt.signcolumn = "yes"
opt.background = "dark"
opt.termguicolors = true
-- vim.cmd [[colorscheme nord]]
-- vim.cmd([[colorscheme catppuccin-frappe]])
