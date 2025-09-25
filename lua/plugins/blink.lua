return {
  "saghen/blink.cmp",
  dependencies = {
    "Kaiser-Yang/blink-cmp-avante",
  },
  opts = {
    fuzzy = { implementation = "lua" },
    sources = {
      -- Add 'avante' to the list
      default = { "avante" },
      providers = {
        avante = {
          module = "blink-cmp-avante",
          name = "Avante",
          opts = {},
        },
      },
    },
  },
}
