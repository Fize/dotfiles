vim.g.mapleader = ","

local keymap = vim.keymap

-- 插入模式
keymap.set("i", "kj", "<ESC>")
keymap.set("n", "<leader>q", ":q<CR>") -- 退出
keymap.set("n", "<leader>qq", ":q!<CR>") -- 强制退出
keymap.set("n", "<leader>w", ":w<CR>") -- 保存

-- ------视觉模式------
-- 单行或多行移动
keymap.set("v", "J", ":m '>+1<CR>gv=gv")
keymap.set("v", "K", ":m '<-2<CR>gv=gv")

-- ------正常模式------
-- 窗口
keymap.set("n", "<leader>sv", "<C-w>v") -- 水平新增窗口
keymap.set("n", "<leader>sh", "<C-w>s") -- 垂直新增窗口

-- 取消高亮
keymap.set("n", "<leader>/", ":nohl<CR>")

-- ------插件------ --
-- nvim-tree
keymap.set("n", "<leader>n", ":NvimTreeToggle<CR>")

-- 切换buffer
keymap.set("n", "L", ":bnext<CR>")
keymap.set("n", "H", ":bprevious<CR>")

-- 撤销
keymap.set("n", "U", "<C-r>")

-- goyo
keymap.set("n", "<leader>c", ":Goyo<CR>")
keymap.set("n", "<leader>cc", ":Goyo!<CR>")

-- keyword heigh light
keymap.set("n", "<leader>k", ":call InterestingWords('n')<cr>")
keymap.set("n", "<leader>kk", ":call UncolorAllWords()<cr>")

keymap.set("n", "<leader>zz", ":call ToggleFold()<cr>")
