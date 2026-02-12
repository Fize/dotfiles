return {
  {
    "coder/claudecode.nvim",
    opts = {
      terminal_cmd = "/opt/homebrew/bin/codebuddy",
    },
    config = true,
    keys = {
      { "<leader>cc", "", desc = "+ai", mode = { "n", "v" } },
      { "<leader>ccc", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
      { "<leader>ccf", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
      { "<leader>ccr", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
      { "<leader>ccC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
      { "<leader>ccb", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
      { "<leader>ccs", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
      {
        "<leader>ccs",
        "<cmd>ClaudeCodeTreeAdd<cr>",
        desc = "Add file",
        ft = { "NvimTree", "neo-tree", "oil" },
      },
      -- Diff management
      { "<leader>cca", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
      { "<leader>ccd", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
    },
  },
}
