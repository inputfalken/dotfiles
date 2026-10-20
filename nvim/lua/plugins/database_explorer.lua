-- Only the drawer is used: queries it opens are SQL buffers, so mssql.nvim executes them and shows the results.
return {
  'kristijanhusak/vim-dadbod-ui',
  dependencies = { 'tpope/vim-dadbod', 'Kurren123/mssql.nvim' },
  cmd = { 'DBUI', 'DBUIToggle' },
  keys = {
    { '<Leader>dbu', '<Cmd>DBUIToggle<CR>', desc = 'Explorer' },
  },
  init = function()
    vim.g.db_ui_execute_on_save = 0
    vim.g.db_ui_disable_mappings_sql = 1
  end,
  config = function()
    local connections_file = vim.fs.joinpath(vim.fn.stdpath('data'), 'mssql.nvim', 'connections.json')
    local connections = vim.json.decode(table.concat(vim.fn.readfile(connections_file), '\n'))

    -- Without a user the dadbod adapter falls back to Windows authentication.
    vim.g.dbs = vim.tbl_map(function(connection)
      local credentials = connection.user
          and string.format(
            '%s:%s@',
            vim.uri_encode(connection.user, 'rfc2396'),
            vim.uri_encode(connection.password or '', 'rfc2396')
          )
        or ''
      local params = connection.trustServerCertificate and '?trustServerCertificate=true' or ''
      return string.format(
        'sqlserver://%s%s/%s%s',
        credentials,
        vim.uri_encode(connection.server, 'rfc2396'),
        vim.uri_encode(connection.database or '', 'rfc2396'),
        params
      )
    end, connections)

    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        if vim.lsp.get_client_by_id(args.data.client_id).name ~= 'mssql_ls' then
          return
        end

        -- dadbod-ui keys its connections as `<name>_<source>`.
        local name = (vim.b[args.buf].dbui_db_key_name or ''):match('^(.*)_g:dbs$')
        local connection = name and connections[name]
        if not connection then
          return
        end

        -- The plugin creates the buffer's query manager in its on_attach, which runs after LspAttach.
        vim.schedule(function()
          local query_manager = vim.b[args.buf].query_manager
          local ok, err = coroutine.resume(coroutine.create(function()
            query_manager.connect_async({ connection = { options = vim.deepcopy(connection) } })
            query_manager.initialise_cache_async()
          end))
          if not ok then
            vim.notify(err, vim.log.levels.ERROR)
          end
        end)
      end,
    })
  end,
}
