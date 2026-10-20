return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'nsidorenco/neotest-vstest',
    'rcarriga/nvim-dap-ui', -- Registers the netcoredbg adapter the dap strategy runs on.
  },
  keys = {
    { '<Leader>ten', '<Cmd>Neotest run<CR>', desc = 'Run nearest test' },
    {
      '<Leader>tef',
      function()
        require('neotest').run.run(vim.fn.expand('%'))
      end,
      desc = 'Run tests in file',
    },
    { '<Leader>tea', '<Cmd>Neotest run suite=true<CR>', desc = 'Run all tests' },
    { '<Leader>teo', '<Cmd>Neotest output enter=true last_run=true<CR>', desc = 'Test output' },
    { '<Leader>tes', '<Cmd>Neotest summary<CR>', desc = 'Test summary' },
    { '<Leader>det', '<Cmd>Neotest run strategy="dap"<CR>', desc = 'Debug nearest test' },
  },
  config = function()
    require('neotest').setup({
      adapters = {
        require('neotest-vstest'),
      },
      icons = {
        running_animated = { '⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏' },
      },
    })
  end,
}
