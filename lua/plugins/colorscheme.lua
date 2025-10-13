return {
  {
    "LazyVim/LazyVim",
    opts = {
      -- colorscheme = "tokyonight",
      colorscheme = "neosolarized",
    },
  },
  {
    "akinsho/bufferline.nvim",
    optional = true,
    opts = function(_, opts)
      if (vim.g.colors_name or ""):find("catppuccin") then
        opts.highlights = require("catppuccin.groups.integrations.bufferline").get()
      end
    end,
  },
  {
    "svrana/neosolarized.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("neosolarized").setup({
        comment_italics = true,
        background_set = false,
      })
      vim.cmd.colorscheme("neosolarized")
    end,
    dependencies = {
      "tjdevries/colorbuddy.nvim",
    },
  },
}
