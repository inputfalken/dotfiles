return {
  -- Queries run through the database's own CLI, e.g. `sqlcmd`, `psql` or `sqlite3`.
  'kristijanhusak/vim-dadbod-ui',
  dependencies = { { 'tpope/vim-dadbod', lazy = true } },
  cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
  keys = {
    { '<Leader>db', '<Cmd>DBUIToggle<CR>', desc = 'Toggle database UI' },
  },
  init = function()
    vim.g.db_ui_use_nerd_fonts = 1

    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'sql', 'mysql', 'plsql' },
      callback = function(args)
        -- Statements are separated by blank lines, so the one under the cursor is the paragraph.
        local function execute_paragraph()
          local view = vim.fn.winsaveview()
          vim.cmd.normal('vip' .. vim.keycode('<Plug>(DBUI_ExecuteQuery)'))
          vim.fn.winrestview(view)
        end

        vim.keymap.set({ 'n', 'i' }, '<C-CR>', execute_paragraph, { buffer = args.buf, desc = 'Execute statement under cursor' })
        vim.keymap.set('x', '<C-CR>', '<Plug>(DBUI_ExecuteQuery)', { buffer = args.buf, desc = 'Execute selection' })
      end
    })
  end
}
