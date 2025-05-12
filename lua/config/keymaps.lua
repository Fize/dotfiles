-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local map = vim.keymap.set

-- 插入模式
map("i", "kj", "<ESC>")
map("n", "<leader>q", ":q<CR>") -- 退出
map("n", "<leader>qq", ":q!<CR>") -- 强制退出
map("n", "<leader>w", ":w<CR>") -- 保存

-- ------视觉模式------
-- 单行或多行移动
map("v", "J", ":m '>+1<CR>gv=gv")
map("v", "K", ":m '<-2<CR>gv=gv")

-- ------正常模式------
-- 窗口
map("n", "<leader>sv", "<C-w>v") -- 水平新增窗口
map("n", "<leader>sh", "<C-w>s") -- 垂直新增窗口

-- 取消高亮
map("n", "<leader>h", ":nohl<CR>")

-- ------插件------ --
-- nvim-tree
map("n", "<leader>e", ":Neotree toggle<CR>")

-- 切换buffer
map("n", "L", ":bnext<CR>")
map("n", "H", ":bprevious<CR>")

-- 撤销
map("n", "U", "<C-r>")

-- goyo
map("n", "<leader>bc", ":Goyo<CR>")
map("n", "<leader>bq", ":Goyo!<CR>")

-- keyword heigh light
map("n", "<leader>k", ":call InterestingWords('n')<cr>")
map("n", "<leader>kk", ":call UncolorAllWords()<cr>")

-- map("n", "<leader>zz", ":call ToggleFold()<cr>")

-- neo-tree
-- map("n", "<C-h>", ":wincmd p<CR>")
-- map("n", "<C-l>", ":wincmd p<CR>")

-- map Tree
map("n", "<leader>mt", "<cmd>AerialToggle!<CR>")

-- telescope
local builtin = require("telescope.builtin")

map("n", "<leader>ff", builtin.find_files, {})
map("n", "<leader>fg", builtin.live_grep, {}) -- 要安ripgrep
map("n", "<leader>fb", builtin.buffers, {})
map("n", "<leader>fh", builtin.help_tags, {})
