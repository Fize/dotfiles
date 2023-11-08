-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny
lvim.lsp.installer.setup.automatic_installation = true

-- lvim.builtin.treesitter.indent = { enable = true, disable = { "go", "python", "bash" } }
vim.opt.shiftwidth = 4 -- the number of spaces inserted for each indentation
vim.opt.tabstop = 4    -- insert 2 spaces for a tab

-- lvim.colorscheme = 'vscode'
lvim.colorscheme = 'onenord'

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

    { 'Mofiqul/vscode.nvim' },
    { 'rmehri01/onenord.nvim' },
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
    }
}

lvim.keys.normal_mode["<leader>bc"] = ":Goyo<CR>"
lvim.keys.normal_mode["<leader>bq"] = ":Goyo!<CR>"

lvim.keys.normal_mode["<C-s>"] = ":MarkdownPreview<CR>"
lvim.keys.normal_mode["<M-s>"] = ":MarkdownPreviewStop<CR>"
lvim.keys.normal_mode["<C-p>"] = ":MarkdownPreviewToggle<CR>"

lvim.keys.normal_mode["<leader>mt"] = "<cmd>AerialToggle!<CR>"

lvim.keys.normal_mode["L"] = ":bnext<CR>"
lvim.keys.normal_mode["H"] = ":bprevious<CR>"

lvim.keys.normal_mode["<leader>ts"] = "<C-w>v"
lvim.keys.normal_mode["<leader>th"] = "<C-w>s"

lvim.keys.insert_mode["kj"] = "<ESC>"

-- keyword heigh light
lvim.keys.normal_mode["<leader>k"] = ":call InterestingWords('n')<cr>"
lvim.keys.normal_mode["<leader>kk"] = ":call UncolorAllWords()<cr>"
