return {
  { "junegunn/goyo.vim" },
  { "junegunn/limelight.vim" },
  { "vim-pandoc/vim-pandoc-syntax" },
  { "edluffy/hologram.nvim" },
  -- { "numToStr/FTerm.nvim" },
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = true,
  },
  { "mg979/vim-visual-multi" },
  { "lfv89/vim-interestingwords" },
  { "tpope/vim-repeat" },
  { "tpope/vim-surround" },
  -- 修复 leap.nvim 的 add_default_mappings bug：
  -- 该函数将 s/S/gs 映射到不存在的 <Plug>(leap-forward-to) 等，
  -- 实际 Plug 名为 <Plug>(leap-forward) 等，导致按键完全无效。
  -- 同时覆盖 config，避免 LazyVim leap extra 的 config 再次调用
  -- add_default_mappings(true) 覆盖回错误的映射。
  {
    url = "https://codeberg.org/andyg/leap.nvim.git",
    keys = {
      { "s", "<Plug>(leap-forward)", mode = { "n", "x", "o" }, desc = "Leap Forward" },
      { "S", "<Plug>(leap-backward)", mode = { "n", "x", "o" }, desc = "Leap Backward" },
      { "gs", "<Plug>(leap-from-window)", mode = { "n", "x", "o" }, desc = "Leap from Window" },
    },
    config = function(_, opts)
      local leap = require("leap")
      for k, v in pairs(opts) do
        leap.opts[k] = v
      end
      -- 不调用 add_default_mappings，改为手动设置正确的映射
      vim.keymap.set({ "n", "x", "o" }, "s", "<Plug>(leap-forward)", { desc = "Leap Forward" })
      vim.keymap.set({ "n", "x", "o" }, "S", "<Plug>(leap-backward)", { desc = "Leap Backward" })
      vim.keymap.set({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)", { desc = "Leap from Window" })
    end,
  },
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      close_if_last_window = true,
      window = {
        width = function()
          local screen_width = vim.o.columns
          -- 根据屏幕宽度智能调整比例
          if screen_width < 120 then
            return math.floor(screen_width * 0.22) -- 小屏幕用22%
          elseif screen_width < 160 then
            return math.floor(screen_width * 0.18) -- 中等屏幕用18%
          else
            return math.floor(screen_width * 0.14) -- 大屏幕用14%
          end
        end,
      },
      filesystem = {
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
        },
        commands = {
          avante_add_files = function(state)
            local node = state.tree:get_node()
            local filepath = node:get_id()
            local relative_path = require("avante.utils").relative_path(filepath)

            local sidebar = require("avante").get()

            local open = sidebar:is_open()
            -- ensure avante sidebar is open
            if not open then
              require("avante.api").ask()
              sidebar = require("avante").get()
            end

            sidebar.file_selector:add_selected_file(relative_path)

            -- remove neo tree buffer
            if not open then
              sidebar.file_selector:remove_selected_file("neo-tree filesystem [1]")
            end
          end,
        },
        window = {
          mappings = {
            ["oa"] = "avante_add_files",
          },
        },
      },
    },
  },
}
