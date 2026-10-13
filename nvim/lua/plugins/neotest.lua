return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'nsidorenco/neotest-vstest',
    'rcarriga/nvim-dap-ui', -- Registers the netcoredbg adapter the dap strategy runs on.
  },
  keys = {
    {
      '<Leader>ten',
      function()
        require('neotest').run.run()
      end,
      desc = 'Run nearest test',
    },
    {
      '<Leader>tef',
      function()
        require('neotest').run.run(vim.fn.expand('%'))
      end,
      desc = 'Run tests in file',
    },
    {
      '<Leader>tea',
      function()
        require('neotest').run.run({ suite = true })
      end,
      desc = 'Run all tests',
    },
    {
      '<Leader>teo',
      function()
        require('neotest').output.open({ enter = true, last_run = true })
      end,
      desc = 'Test output',
    },
    {
      '<Leader>tes',
      function()
        require('neotest').summary.toggle()
      end,
      desc = 'Test summary',
    },
    {
      '<Leader>det',
      function()
        require('neotest').run.run({ strategy = 'dap' })
      end,
      desc = 'Debug nearest test',
    },
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
