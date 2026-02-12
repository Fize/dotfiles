return {
  {
    "yetone/avante.nvim",
    opts = {
      provider = "deepseek",
      providers = {
        deepseek = {
          __inherited_from = "openai",
          api_key_name = "DEEPSEEK_API_KEY",
          endpoint = "https://api.deepseek.com",
          model = "deepseek-reasoner",
        },
        deepseek_ns = {
          __inherited_from = "openai",
          api_key_name = "DEEPSEEK_API_KEY",
          endpoint = "https://api.deepseek.com/beta",
          model = "deepseek-chat",
          max_tokens = 4096,
        },
        -- moonshot = {
        --   endpoint = "https://api.moonshot.ai/v1",
        --   model = "kimi-k2-turbo-preview",
        --   api_key_name = "MOONSHOT_API_KEY",
        --   timeout = 30000, -- 超时时间（毫秒）
        --   extra_request_body = {
        --     temperature = 0.3,
        --     max_tokens = 32768,
        --   },
        -- },
      },
    },
  },
}
