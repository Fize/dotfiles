vim.g.mapleader = " "

local map = vim.keymap.set

-- 插入模式
map("i", "kj", "<ESC>")
map("n", "<leader>q", ":q<CR>")   -- 退出
map("n", "<leader>qq", ":q!<CR>") -- 强制退出
map("n", "<leader>w", ":w<CR>")   -- 保存

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
map("n", "<leader>e", ":NvimTreeToggle<CR>")

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

-- map("n", "<leader>zz", ":call ToggleFold()<cr>")

-- Tree
map('n', '<leader>tt', '<cmd>AerialToggle!<CR>')

-- FTerm
map('n', '<F12>', '<CMD>lua require("FTerm").toggle()<CR>')
map('t', '<F12>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')

local fterm = require("FTerm")

-- 打开 tig
local tig = fterm:new({
    ft = 'fterm_tig', -- You can also override the default filetype, if you want
    cmd = "tig",
    dimensions = {
        height = 0.9,
        width = 0.9
    }
})

-- Use this to toggle gitui in a floating terminal
map('n', '<leader>g', function()
    tig:toggle()
end)

-- 打开btop系统信息
local btop = fterm:new({
    ft = 'fterm_btop',
    cmd = "btop"
})

-- Use this to toggle btop in a floating terminal
map('n', '<leader>b', function()
    btop:toggle()
end)

-- telescope
local builtin = require('telescope.builtin')

map('n', '<leader>ff', builtin.find_files, {})
map('n', '<leader>fg', builtin.live_grep, {}) -- 要安ripgrep
map('n', '<leader>fb', builtin.buffers, {})
map('n', '<leader>fh', builtin.help_tags, {})
