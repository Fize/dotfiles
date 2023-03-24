require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

require("mason-lspconfig").setup {
  ensure_installed = {
    "awk_ls",
    "cssls",
    "dockerls",
    "docker_compose_language_service",
    "gopls",
    "html",
    "jsonls",
    "tsserver", -- js and ts
    "lua_ls",
    "marksman", -- markdown
    "pyright",
    "sqls",
    "taplo", -- toml
    "vimls",
    "vuels",
    "yamlls",
    "terraformls", -- terraform
    "ansiblels",
    "bashls",
  },
}

local lspconfig = require('lspconfig')
lspconfig.awk_ls.setup {}
lspconfig.cssls.setup {}
lspconfig.dockerls.setup {}
lspconfig.docker_compose_language_service.setup {}
lspconfig.gopls.setup {}
lspconfig.html.setup {}
lspconfig.jsonls.setup {}
lspconfig.tsserver.setup {}
lspconfig.lua_ls.setup {}
lspconfig.marksman.setup {}
lspconfig.pyright.setup {}
lspconfig.sqls.setup {}
lspconfig.taplo.setup {}
lspconfig.vimls.setup {}
lspconfig.vuels.setup {}
lspconfig.yamlls.setup {}
lspconfig.terraformls.setup {}
lspconfig.ansiblels.setup {}
lspconfig.bashls.setup {}
