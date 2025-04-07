-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
-- lvim.lsp.installer.setup.automatic_installation = true

-- lvim.builtin.treesitter.indent = { enable = true, disable = { "go", "python", "bash" } }
vim.opt.shiftwidth = 4 -- the number of spaces inserted for each indentation
vim.opt.tabstop = 4    -- insert 2 spaces for a tab

-- lvim.colorscheme = 'vscode'
-- lvim.colorscheme = 'onenord'
lvim.colorscheme = 'tokyonight'
-- lvim.colorscheme = 'sonokai'

-- default, lvim, none
lvim.builtin.lualine.style = "lvim"

lvim.plugins = {
    {
        "iamcco/markdown-preview.nvim",
        build = "cd app && npm install",
        ft = "markdown",
        config = function()
            vim.g.mkdp_auto_start = 1
        end,
    },

    {
        'stevearc/aerial.nvim',
        opts = {},
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-tree/nvim-web-devicons"
        },
    },

    -- golang plugin
    { 'fatih/vim-go' },
    -- theme
    { 'Mofiqul/vscode.nvim' },
    { 'rmehri01/onenord.nvim' },
    { 'sainnhe/sonokai' },

    { 'mg979/vim-visual-multi' },
    { "lfv89/vim-interestingwords" },

    { "tpope/vim-repeat" },
    { "tpope/vim-surround" },

    { "junegunn/goyo.vim" },
    { "junegunn/limelight.vim" },

    {
        "ggandor/leap.nvim",
        name = "leap",
        config = function()
            require("leap").add_default_mappings()
        end,
    },

    {
        "folke/todo-comments.nvim",
        event = "BufRead",
        config = function()
            require("todo-comments").setup()
        end,
    },

    {
        "zbirenbaum/copilot.lua",
        cmd = "Copilot",
        event = "InsertEnter",
        config = function()
            require("copilot").setup({})
        end,
    },

    {
        "zbirenbaum/copilot-cmp",
        config = function()
            require("copilot_cmp").setup()
        end
    },

    {
        "CopilotC-Nvim/CopilotChat.nvim",
        branch = "main",
        dependencies = {
          { "zbirenbaum/copilot.lua" }, -- or github/copilot.vim
          { "nvim-lua/plenary.nvim" }, -- for curl, log wrapper
        },
        build = "make tiktoken", -- Only on MacOS or Linux
        opts = {
          debug = true, -- Enable debugging
          -- See Configuration section for rest
        },
        -- See Commands section for default commands if you want to lazy load on them
    },

    -- instead of using the default installer
    { "numToStr/FTerm.nvim" }
}

lvim.keys.normal_mode["<leader>bc"] = ":Goyo<CR>"
lvim.keys.normal_mode["<leader>bq"] = ":Goyo!<CR>"

lvim.keys.normal_mode["<C-s>"] = ":MarkdownPreview<CR>"
lvim.keys.normal_mode["<M-s>"] = ":MarkdownPreviewStop<CR>"
lvim.keys.normal_mode["<C-p>"] = ":MarkdownPreviewToggle<CR>"

lvim.keys.normal_mode["<leader>mt"] = "<cmd>AerialToggle!<CR>"

lvim.keys.normal_mode["L"] = ":bnext<CR>"
lvim.keys.normal_mode["H"] = ":bprevious<CR>"

lvim.keys.normal_mode["<leader>sv"] = "<C-w>v"
lvim.keys.normal_mode["<leader>sh"] = "<C-w>s"

lvim.keys.insert_mode["kj"] = "<ESC>"

-- keyword heigh light
lvim.keys.normal_mode["<leader>k"] = ":call InterestingWords('n')<cr>"
lvim.keys.normal_mode["<leader>kk"] = ":call UncolorAllWords()<cr>"

-- 取消高亮
lvim.keys.normal_mode["<leader>h"] = ":nohl<CR>"

lvim.keys.normal_mode["<leader>ai"] = ":CopilotChatToggle<CR>"

local fterm = require("FTerm")

lvim.keys.normal_mode['<A-i>'] = function()
    fterm:toggle()
end

-- 打开 k9s
local k9s = fterm:new({
    ft = 'fterm_k9s', -- You can also override the default filetype, if you want
    cmd = "k9s",
    dimensions = {
        height = 0.9,
        width = 0.9
    }
})

-- Use this to toggle gitui in a floating terminal
lvim.keys.normal_mode['<leader>d'] = function()
    k9s:toggle()
end

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
lvim.keys.normal_mode['<leader>g'] = function()
    tig:toggle()
end

-- 打开glances系统信息
local btop = fterm:new({
    ft = 'fterm_btop',
    cmd = "btop"
})

-- Use this to toggle btop in a floating terminal
lvim.keys.normal_mode['<leader>b'] = function()
    btop:toggle()
end
