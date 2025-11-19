return {
  {
    "yetone/avante.nvim",
    opts = {
      -- provider = "deepseek",
      providers = {
        copilot = {
          endpoint = "https://api.githubcopilot.com",
          model = "gpt-5-mini", -- your desired model (or use gpt-4o, etc.)
          extra_request_body = {
            timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
            temperature = 0,
            max_tokens = 100000000, -- Increase this to include reasoning tokens (for reasoning models)
            reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
          },
        },
        -- deepseek = {
        --   __inherited_from = "openai",
        --   api_key_name = "DEEPSEEK_API_KEY",
        --   endpoint = "https://api.deepseek.com",
        --   model = "deepseek-chat",
        -- },
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
