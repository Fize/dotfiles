local opt = vim.opt

opt.syntax = "yes"

-- 行号
opt.relativenumber = true
opt.number = true

-- 缩进
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.autoindent = true

-- 光标行
opt.cursorline = true
opt.cursorcolumn = true
-- 上下移动光标时上方或下方至少保留的行数
opt.scrolloff = 7

-- 防止包裹
opt.wrap = false

-- 启用鼠标
opt.mouse:append("a")

-- 系统剪贴板
-- opt.clipboard:append("unnamedplus")

-- 默认新窗口右和下
opt.splitright = true
opt.splitbelow = true

-- 搜索
opt.ignorecase = true
opt.smartcase = true

-- 禁止创建备份文件
opt.backup = false
opt.writebackup = false
opt.swapfile = false

local g = vim.g

g.interestingWordsDefaultMappings = 0

-- g.FoldMethod = 0

local api = vim.api

api.nvim_create_autocmd("User", {
    pattern = "GoyoEnter",
    command = "Limelight",
})

api.nvim_create_autocmd("User", {
    pattern = "GoyoLeave",
    command = "Limelight!",
})

api.nvim_create_autocmd("Filetype", {
    pattern = "*",
    command = "AnyFoldActivate",
})

vim.cmd("set foldmethod=expr")
vim.cmd("set foldlevel=99")
vim.cmd("set foldexpr=nvim_treesitter#foldexpr()")
-- vim.cmd("set foldenable=false")
