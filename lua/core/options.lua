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
opt.clipboard:append("unnamedplus")

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

