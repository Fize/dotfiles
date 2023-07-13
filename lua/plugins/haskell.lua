local opts = {
    on_attach = function(client, bufnr)
        -- 禁用格式化功能，交给专门插件插件处理
        local function buf_set_keymap(...)
            vim.api.nvim_buf_set_keymap(bufnr, ...)
        end
        -- 绑定快捷键
        -- 保存时自动格式化
        vim.cmd("autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()")
    end,
    -- cmd = { "~/.local/share/nvim/lsp_servers/haskell/haskell-language-server-wrapper", "--lsp" },
}

return {
    on_setup = function(server)
        server:setup(opts)
    end,
}
