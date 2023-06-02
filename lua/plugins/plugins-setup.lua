-- 自动安装packer
local ensure_packer = function()
    local fn = vim.fn
    local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
    if fn.empty(fn.glob(install_path)) > 0 then
        fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
        vim.cmd [[packadd packer.nvim]]
        return true
    end
    return false
end

local packer_bootstrap = ensure_packer()

-- 保存此文件自动更新安装软件
vim.cmd([[
  augroup packer_user_config
    autocmd!
    autocmd BufWritePost plugins-setup.lua source <afile> | PackerSync
  augroup end
]])

return require('packer').startup(function(use)
    use 'wbthomason/packer.nvim'
    -- 主题
    use 'dracula/vim'
    use {
        'uloco/bluloco.nvim',
        requires = { 'rktjmp/lush.nvim' }
    }
    use 'folke/tokyonight.nvim'
    use 'shaunsingh/nord.nvim'

    use {
        'nvim-lualine/lualine.nvim',                              -- 状态栏
        requires = { 'kyazdani42/nvim-web-devicons', opt = true } -- 状态栏图标
    }
    use {
        'nvim-tree/nvim-tree.lua',         -- 文件树
        requires = {
            'nvim-tree/nvim-web-devicons', -- 文件树图标
        },
    }
    use "christoomey/vim-tmux-navigator"  -- 使用ctrl-hjkl来定位窗口
    use "nvim-treesitter/nvim-treesitter" -- 语法高亮
    use "HiPhish/nvim-ts-rainbow2"        -- 配合treesitter不同括号颜色区分

    use "akinsho/bufferline.nvim"         -- buffer分割线
    use "lewis6991/gitsigns.nvim"         -- 左侧git提示
    -- lsp
    -- use {
    --     "williamboman/mason.nvim",
    --     "williamboman/mason-lspconfig.nvim",
    --     "neovim/nvim-lspconfig"
    -- }

    use 'numToStr/Comment.nvim' -- 注释
    use 'windwp/nvim-autopairs' -- 自动补全括号
    use {
        'nvim-telescope/telescope.nvim', tag = '0.1.1',
        requires = { 'nvim-lua/plenary.nvim' }

    }
    -- 终端
    use 'numToStr/FTerm.nvim'

    -- 启动页
    use {
        'startup-nvim/startup.nvim',
        requires = { 'nvim-telescope/telescope.nvim', 'nvim-lua/plenary.nvim' },
    }

    -- 字符搜索跳转
    use 'ggandor/leap.nvim'
    -- AI 代码
    use 'github/copilot.vim'
    -- 多光标
    use 'mg979/vim-visual-multi'
    -- 代码折叠
    use 'pseewald/vim-anyfold'
    -- 单词高亮
    use 'lfv89/vim-interestingwords'
    -- 函数导航
    use 'stevearc/aerial.nvim'
    -- 代码补全
    use {'neoclide/coc.nvim', branch = 'release'}
    use 'fatih/vim-go'
    -- TODO高亮
    use {
      "folke/todo-comments.nvim",
      requires = "nvim-lua/plenary.nvim",
    }
    -- png显示
    use {'edluffy/hologram.nvim'}
    -- 环绕添加引号括号等
    use {'tpope/vim-repeat'}
    use {'tpope/vim-surround'}


    if packer_bootstrap then
        require('packer').sync()
    end
end)
