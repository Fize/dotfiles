local lsp_server = {
        "awk_ls",
        "ansiblels",
        "bashls",
        "cssls",
        "dockerls",
        "docker_compose_language_service",
        "emmet_ls",
        "gopls",
        "html",
        "helm_ls",
        "jsonls",
        "lua_ls",
        "marksman",
        "pyright",
        "sqlls",
        "taplo",
        "vtsls",
        "volar",
        "terraformls"
    }

require("mason").setup()
require("mason-lspconfig").setup{
    ensure_installed = lsp_server
}

local lspconfig = require('lspconfig')

for _, server in pairs(lsp_server) do
    lspconfig[server].setup{}
end
