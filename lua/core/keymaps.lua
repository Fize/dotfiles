vim.g.mapleader = ","

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
map("n", "<leader>/", ":nohl<CR>")

-- ------插件------ --
-- nvim-tree
map("n", "<leader>n", ":NvimTreeToggle<CR>")

-- 切换buffer
map("n", "L", ":bnext<CR>")
map("n", "H", ":bprevious<CR>")

-- 撤销
map("n", "U", "<C-r>")

-- goyo
map("n", "<leader>c", ":Goyo<CR>")
map("n", "<leader>cc", ":Goyo!<CR>")

-- keyword heigh light
map("n", "<leader>k", ":call InterestingWords('n')<cr>")
map("n", "<leader>kk", ":call UncolorAllWords()<cr>")

map("n", "<leader>zz", ":call ToggleFold()<cr>")
