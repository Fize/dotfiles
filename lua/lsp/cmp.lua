local lspkind = require('lspkind')
local cmp = require('cmp')
local ultisnips = require('lsp.ultisnips')
ultisnips.setup()

cmp.setup {
    -- 指定 snippet 引擎
    snippet = {
        expand = function(args)
            vim.fn["UltiSnips#Anon"](args.body)
        end,
    },
    -- 来源
    sources = cmp.config.sources(
        {
            { name = 'nvim_lsp' },
            { name = 'ultisnips' },
        },
        {
            { name = 'buffer' },
            { name = 'path' }
        }),

    -- 快捷键
    -- mapping = require'keybindings'.cmp(cmp),
    mapping = cmp.mapping.preset.insert({
        ['<C-b>'] = cmp.mapping.scroll_docs(-4),
        ['<C-f>'] = cmp.mapping.scroll_docs(4),
        ['<C-Space>'] = cmp.mapping.complete(),
        ['<C-e>'] = cmp.mapping.abort(),
        ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
    }),
    -- 使用lspkind-nvim显示类型图标
    formatting = {
        format = lspkind.cmp_format({
            mode = 'symbol',
            with_text = true, -- do not show text alongside icons
            maxwidth = 50,    -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            before = function(entry, vim_item)
                -- Source 显示提示来源
                vim_item.menu = "[" .. string.upper(entry.source.name) .. "]"
                return vim_item
            end
        })
    },
}
-- Use buffer source for `/`.
cmp.setup.cmdline('/', {
    completion = { autocomplete = false },
    sources = {
        -- { name = 'buffer' }
        { name = 'buffer', opts = { keyword_pattern = [=[[^[:blank:]].*]=] } }
    }
})

-- Use cmdline & path source for ':'.
cmp.setup.cmdline(':', {
    completion = { autocomplete = false },
    sources = cmp.config.sources({
        { name = 'path' }
    }, {
        { name = 'cmdline' }
    })
})
