lua require("plugins.plugins-setup")

lua require("core.options")
lua require("core.keymaps")

" 插件
lua require("plugins.lualine")
lua require("plugins.nvim-tree")
lua require("plugins.treesitter")
lua require("plugins.bufferline")
lua require("plugins.gitsigns")
lua require("plugins.comment")
lua require("plugins.autopairs")
lua require("plugins.telescope")
lua require("plugins.fterm")
lua require("plugins.startup")
lua require("plugins.leap")
lua require("plugins.aerial")
lua require("plugins.theme")
lua require("plugins.coc")
lua require("plugins.todo")
lua require("plugins.hologram-png")

" 代码折叠
autocmd Filetype * AnyFoldActivate
set foldlevel=99

" 单词高亮
let g:interestingWordsDefaultMappings = 0
nnoremap <silent> <leader><leader>k :call InterestingWords('n')<cr>
vnoremap <silent> <leader><leader>k :call InterestingWords('v')<cr>
nnoremap <silent> <leader><leader>K :call UncolorAllWords()<cr>
nnoremap <silent> n :call WordNavigation(1)<cr>
nnoremap <silent> N :call WordNavigation(0)<cr>

" 具体编辑文件类型的一般设置，比如不要 tab 等
autocmd FileType python set tabstop=4 shiftwidth=4 expandtab ai
autocmd FileType javascript,html,css,xml set tabstop=2 shiftwidth=2 softtabstop=2 expandtab ai
autocmd BufRead,BufNewFile *.md,*.mkd,*.markdown set filetype=markdown.mkd
autocmd BufRead,BufNewFile *.part set filetype=html
autocmd BufRead,BufNewFile *.vue setlocal filetype=vue.html.javascript tabstop=2 shiftwidth=2 softtabstop=2 expandtab ai

" 保存python文件时删除多余空格
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd FileType go,javascript,python,rust,xml,yml,perl,json autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()

" 设置可以高亮的关键字
if has("autocmd")
  " Highlight TODO, FIXME, NOTE, etc.
  if v:version > 701
    autocmd Syntax * call matchadd('Todo',  '\W\zs\(TODO\|FIXME\|CHANGED\|DONE\|XXX\|BUG\|HACK\)')
    autocmd Syntax * call matchadd('Debug', '\W\zs\(NOTE\|INFO\|IDEA\|NOTICE\)')
  endif
endif

" coc 扩展
let g:coc_global_extensions = [
    \ 'coc-sh',
	\ 'coc-css',
	\ 'coc-docker',
    \ 'coc-go',
	\ 'coc-html',
	\ 'coc-tsserver',
	\ 'coc-json',
    \ 'coc-lua',
    \ 'coc-markdownlint',
	\ 'coc-pyright',
	\ 'coc-vetur',
    \ 'coc-lists',
    \ 'coc-prettier',
    \ 'coc-sql',
    \ 'coc-toml',
	\ 'coc-emmet',
	\ 'coc-eslint',
	\ 'coc-yaml']

" fatih/vim-go
let g:go_version_warning = 0
let g:go_fmt_autosave = 1
let g:go_autodetect_gopath = 1
let g:go_fmt_command = "goimports"
" let g:go_bin_path = '$GOBIN'
let g:go_highlight_types = 1
let g:go_highlight_fields = 1
let g:go_highlight_functions = 1
let g:go_highlight_function_calls = 1
let g:go_highlight_extra_types = 1
let g:go_highlight_generate_tags = 1
