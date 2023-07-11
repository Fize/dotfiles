vim.opt.termguicolors = true

require("bufferline").setup {
  options = {
    buffer_close_icon = '',
    modified_icon = '●',
    close_icon = '',
    left_trunc_marker = '',
    right_trunc_marker = '',
    -- 使用 nvim 内置 lsp
    -- diagnostics = "nvim_lsp",
    -- 左侧让出 nvim-tree 的位置
    offsets = {{
      filetype = "NvimTree",
      text = "File Explorer",
      highlight = "Directory",
      text_align = "center",
      separator = true
    }},
    color_icons = true,
    separator_style = padded_slant
  }
}

