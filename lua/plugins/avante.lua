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
    "saghen/blink.cmp",
    version = "1.*", -- 使用稳定版本
    -- 不再使用dependencies字段，改为通过spec添加
    opts = function(_, opts)
      -- 使用vim.tbl_deep_extend确保增量配置
      local new_opts = {
        -- 现代UI外观配置
        appearance = {
          use_nvim_cmp_as_default = true,
          nerd_font_variant = "mono",
        },
        -- 补全菜单外观优化
        completion = {
          menu = {
            border = "rounded",
            winhighlight = "Normal:BlinkCmpMenu,FloatBorder:BlinkCmpMenuBorder,CursorLine:BlinkCmpMenuSelection",
            scrollbar = false,
          },
          documentation = {
            auto_show = true,
            auto_show_delay_ms = 200,
            window = {
              border = "rounded",
              winhighlight = "Normal:BlinkCmpDoc,FloatBorder:BlinkCmpDocBorder,CursorLine:BlinkCmpDocCursorLine",
            },
          },
          ghost_text = {
            enabled = true,
          },
        },
        -- 签名帮助外观
        signature = {
          window = {
            border = "rounded",
            winhighlight = "Normal:BlinkCmpSignatureHelp,FloatBorder:BlinkCmpSignatureHelpBorder",
          },
        },
        -- 修复模糊匹配配置
        fuzzy = {
          implementation = "lua", -- 使用 Lua 实现避免二进制问题
          prebuilt_binaries = {
            force_version = "1.*",
          },
        },
        -- 源配置 - 增量添加avante到默认源
        sources = {
          providers = {
            -- 禁用avante自动补全源
            -- avante = {
            --   name = "Avante",
            --   module = "blink-cmp-avante",
            --   score_offset = 2,
            -- },
          },
        },
      }
      -- 增量合并配置，避免覆盖默认设置
      local merged_opts = vim.tbl_deep_extend("force", opts, new_opts)
      -- 不再添加avante到默认源列表
      -- merged_opts.sources.default = merged_opts.sources.default or {}
      -- if not vim.tbl_contains(merged_opts.sources.default, "avante") then
      --   table.insert(merged_opts.sources.default, "avante")
      -- end
      return merged_opts
    end,
  },
  {
    "Kaiser-Yang/blink-cmp-avante", -- 单独声明blink-cmp-avante依赖
    lazy = true,
    -- 确保在blink.cmp加载后加载
    event = "VeryLazy",
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      -- add any opts here
      -- for example
      provider = "copilot",
      providers = {
        copilot = {
          endpoint = "https://api.githubcopilot.com",
          model = "claude-sonnet-4", -- your desired model (or use gpt-4o, etc.)
          extra_request_body = {
            timeout = 30000, -- Timeout in milliseconds, increase this for reasoning models
            temperature = 0,
            max_tokens = 100000000, -- Increase this to include reasoning tokens (for reasoning models)
            --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
          },
        },
        deepseek = {
          __inherited_from = "openai",
          api_key_name = "TENCENT_DEEPSEEK_API_KEY",
          endpoint = "https://api.lkeap.cloud.tencent.com/v1",
          model = "deepseek-r1-0528",
          -- model = "deepseek-v3-0324",
        },
        moonshot = {
          endpoint = "https://api.moonshot.ai/v1",
          model = "kimi-k2-turbo-preview",
          api_key_name = "MOONSHOT_API_KEY",
          timeout = 30000, -- 超时时间（毫秒）
          extra_request_body = {
            temperature = 0.75,
            max_tokens = 32768,
          },
        },
      },
      -- 禁用类 Copilot 的自动补全
      behaviour = {
        auto_suggestions = false, -- 禁用自动建议
        auto_set_highlight_group = true,
        auto_set_keymaps = true,
        auto_apply_diff_after_generation = false,
        support_paste_from_clipboard = false,
      },
      suggestions = {
        -- 设置为 false 以禁用类 Copilot 的自动补全
        enabled = false,
        -- 触发自动补全的事件
        trigger_events = {
          "TextChanged",
          "TextChangedI",
          "TextChangedP",
          "InsertEnter",
        },
        -- 延迟触发（毫秒）
        debounce_ms = 500,
        -- 最小触发字符数
        min_trigger_chars = 2,
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick", -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "ibhagwan/fzf-lua", -- for file_selector provider fzf
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
        -- opts = {
        --   file_types = { "markdown", "Avante" },
        -- },
        -- ft = { "markdown", "Avante" },
        opts = {
          -- code = {
          --   enabled = true,
          --   sign = true,
          --   width = "block",
          --   right_pad = 1,
          -- },
          -- heading = {
          --   enabled = true,
          --   sign = true,
          --   --   icons = {},
          -- },
          -- checkbox = {
          --   enabled = false,
          -- },
          file_types = { "markdown", "Avante", "norg", "rmd", "org", "codecompanion" },
        },
        ft = { "markdown", "Avante", "norg", "rmd", "org", "codecompanion" },
        config = function(_, opts)
          require("render-markdown").setup(opts)
          Snacks.toggle({
            name = "Render Markdown",
            completions = { blink = { enabled = true } },
            get = function()
              return require("render-markdown.state").enabled
            end,
            set = function(enabled)
              local m = require("render-markdown")
              if enabled then
                m.enable()
              else
                m.disable()
              end
            end,
          }):map("<leader>um")
        end,
      },
    },
  },
}
