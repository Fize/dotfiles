require'FTerm'.setup({
    border = 'double',
    dimensions  = {
        height = 0.9,
        width = 0.9,
    },
})

vim.keymap.set('n', '<F12>', '<CMD>lua require("FTerm").toggle()<CR>')
vim.keymap.set('t', '<F12>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>')

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
vim.keymap.set('n', '<leader>g', function()
    tig:toggle()
end)

-- 打开btop系统信息
local btop = fterm:new({
    ft = 'fterm_btop',
    cmd = "btop"
})

 -- Use this to toggle btop in a floating terminal
vim.keymap.set('n', '<leader>b', function()
    btop:toggle()
end)

