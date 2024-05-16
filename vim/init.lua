require('settings')
require('bindings')
require('plugins.package_manager')
vim.cmd([[
" fzf {
  " Disable Preview window
  autocmd VimEnter * command! -bang -nargs=? Files call fzf#vim#files(<q-args>, {'options': '--no-preview'}, <bang>0)
  nnoremap <Leader>ff :Files<CR>
  " Disable Preview window
  autocmd VimEnter * command! -bang -nargs=? GFiles call fzf#vim#gitfiles(<q-args>, {'options': '--no-preview'}, <bang>0)
  nnoremap <Leader>gf :GFiles<CR>
  nnoremap <Leader>/ :Rg<CR>
" }
  colorscheme gruvbox-material
]])

require('plugins.file_tree')
require('plugins.treesitter')
require('plugins.lsp')
require('plugins.debugger')
