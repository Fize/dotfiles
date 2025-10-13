return {
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    branch = "main",
    cmd = "CopilotChat",
    opts = function()
      local user = vim.env.USER or "User"
      user = user:sub(1, 1):upper() .. user:sub(2)
      return {
        auto_insert_mode = true,
        question_header = "  " .. user .. " ",
        answer_header = "  Copilot ",
        window = {
          width = 0.4,
        },
      }
    end,
    keys = {
      { "<c-s>", "<CR>", ft = "copilot-chat", desc = "Submit Prompt", remap = true },
      { "<leader>a", "", desc = "+ai", mode = { "n", "v" } },
      {
        "<leader>ab",
        function()
          return require("CopilotChat").toggle()
        end,
        desc = "Toggle (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>ax",
        function()
          return require("CopilotChat").reset()
        end,
        desc = "Clear (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>aq",
        function()
          vim.ui.input({
            prompt = "Quick Chat: ",
          }, function(input)
            if input ~= "" then
              require("CopilotChat").ask(input)
            end
          end)
        end,
        desc = "Quick Chat (CopilotChat)",
        mode = { "n", "v" },
      },
      {
        "<leader>ap",
        function()
          require("CopilotChat").select_prompt()
        end,
        desc = "Prompt Actions (CopilotChat)",
        mode = { "n", "v" },
      },
    },
    config = function(_, opts)
      local chat = require("CopilotChat")

      vim.api.nvim_create_autocmd("BufEnter", {
        pattern = "copilot-chat",
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
        end,
      })

      chat.setup(opts)
    end,
  },
  {
    "folke/edgy.nvim",
    optional = true,
    opts = function(_, opts)
      opts.right = opts.right or {}
      table.insert(opts.right, {
        ft = "copilot-chat",
        title = "Copilot Chat",
        size = { width = 50 },
      })
    end,
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      provider = "copilot",
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
        deepseek = {
          __inherited_from = "openai",
          api_key_name = "DEEPSEEK_API_KEY",
          endpoint = "https://api.deepseek.com",
          model = "deepseek-chat",
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
      completion = {
        auto_insert_tab = true,
        cursor_flow = true,
      },
      rag_service = { -- RAG Service configuration
        enabled = true, -- Enables the RAG service
        host_mount = os.getenv("HOME"), -- Host mount path for the rag service (Docker will mount this path)
        runner = "docker", -- Runner for the RAG service (can use docker or nix)
        llm = { -- Language Model (LLM) configuration for RAG service
          provider = "openai", -- LLM provider
          endpoint = "https://open.bigmodel.cn/api/paas/v4",
          -- endpoint = "https://api.githubcopilot.com",
          api_key = "OPENAI_API_KEY", -- Environment variable name for the LLM API key
          model = "glm-4.5-flash", -- LLM model name
          extra = nil, -- Additional configuration options for LLM
        },
        embed = { -- Embedding model configuration for RAG service
          provider = "ollama", -- Embedding provider
          -- endpoint = "https://api.openai.com/v1", -- Embedding API endpoint
          endpoint = "http://localhost:11434", -- Embedding API endpoint
          api_key = "", -- Environment variable name for the embedding API key
          model = "mxbai-embed-large:latest", -- Embedding model name
          extra = {
            embed_batch_size = 10,
          }, -- Additional configuration options for the embedding model
        },
        docker_extra_args = "", -- Extra arguments to pass to the docker command
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "nvim-mini/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp", -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
      "stevearc/dressing.nvim", -- for input provider dressing
      "folke/snacks.nvim", -- for input provider snacks
      "nvim-tree/nvim-web-devicons", -- or echasnovski/mini.icons
      "zbirenbaum/copilot.lua", -- for providers='copilot'
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        "MeanderingProgrammer/render-markdown.nvim",
        -- requires = { "nvim-mini/mini.nvim", "nvim-tree/nvim-web-devicons" },
        opts = {
          file_types = { "markdown", "norg", "rmd", "org", "codecompanion", "Avante" },
        },
        ft = { "markdown", "norg", "rmd", "org", "codecompanion", "Avante" },
        -- config = function()
        --   require("render-markdown").setup({})
        -- end,
      },
    },
  },
}
