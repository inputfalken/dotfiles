require('dapui').setup()

vim.keymap.set('n', '<F5>', function() require 'dap'.continue() end);
vim.keymap.set('n', '<Leader>bp', function() require 'dap'.toggle_breakpoint() end);
vim.keymap.set('n', '<F10>', function() require 'dap'.step_over() end);
vim.keymap.set('n', '<F11>', function() require 'dap'.step_into() end);

require('mason-nvim-dap').setup({
  ensure_installed = { 'coreclr' },
  handlers = {
    function(config)
      -- all sources with no handler get passed here
      -- Keep original functionality
      require('mason-nvim-dap').default_setup(config)
    end,
  }
})

-- TODO
--nnoremap <silent> <F5> <Cmd>lua require'dap'.continue()<CR>
--nnoremap <silent> <F10> <Cmd>lua require'dap'.step_over()<CR>
--nnoremap <silent> <F11> <Cmd>lua require'dap'.step_into()<CR>
--nnoremap <silent> <F12> <Cmd>lua require'dap'.step_out()<CR>
