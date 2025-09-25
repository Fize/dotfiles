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
