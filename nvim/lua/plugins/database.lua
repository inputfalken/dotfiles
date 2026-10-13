return {
  -- SQL Server only. Queries, completion and the object finder run through the bundled SQL Tools Service language server.
  'Kurren123/mssql.nvim',
  -- Loaded with which-key, so `<Leader>db` becomes a group whose entries follow the buffer's connection state.
  event = 'VeryLazy',
  dependencies = { 'folke/which-key.nvim' },
  keys = {
    {
      '<Leader>dbc',
      function()
        local mssql = require('mssql')
        if vim.b.query_manager then
          mssql.connect()
          return
        end

        -- mssql.nvim only connects SQL buffers, so open a query and connect once its language server attaches.
        vim.api.nvim_create_autocmd('LspAttach', {
          once = true,
          callback = function(args)
            -- The plugin creates the buffer's query manager in its on_attach, which runs after LspAttach.
            vim.schedule(function()
              vim.api.nvim_buf_call(args.buf, mssql.connect)
            end)
          end,
        })
        mssql.new_query()
      end,
      desc = 'Connect',
    },
  },
  opts = {
    keymap_prefix = '<Leader>db',
    -- Keep the global 2-space indent instead of the plugin's 4, the server formats SQL with the buffer's indent.
    sql_buffer_options = false,
  },
  init = function()
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'sql',
      callback = function(args)
        -- Statements are separated by blank lines, so the one under the cursor is the paragraph.
        local function execute_paragraph()
          local view = vim.fn.winsaveview()
          vim.api.nvim_feedkeys('vip', 'nx', false)
          require('mssql').execute_query()
          vim.fn.winrestview(view)
        end

        vim.keymap.set('n', '<C-CR>', execute_paragraph, { buf = args.buf, desc = 'Execute statement under cursor' })
        vim.keymap.set(
          'i',
          '<C-CR>',
          '<Esc><C-CR>',
          { buf = args.buf, remap = true, desc = 'Execute statement under cursor' }
        )
        vim.keymap.set('x', '<C-CR>', function()
          require('mssql').execute_query()
        end, { buf = args.buf, desc = 'Execute selection' })
      end,
    })
  end,
}
