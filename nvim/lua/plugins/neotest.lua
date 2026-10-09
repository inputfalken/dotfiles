return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nsidorenco/neotest-vstest',
    'rcarriga/nvim-dap-ui', -- Registers the netcoredbg adapter the dap strategy runs on.
  },
  keys = {
    { '<Leader>dt', function() require('neotest').run.run({ strategy = 'dap' }) end, desc = 'Debug nearest test' },
    { '<Leader>rt', function() require('neotest').run.run() end,                     desc = 'Run nearest test' },
  },
  config = function()
    vim.g.neotest_vstest = {
      dap_settings = {
        type = require('modules.dotnet').dap_adapter
      }
    }
    require('neotest').setup({
      adapters = {
        require('neotest-vstest')
      }
    })
  end
}
