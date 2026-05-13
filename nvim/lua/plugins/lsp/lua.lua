return {
  setup = function(opts)
    vim.lsp.config('lua_ls', opts.coq.lsp_ensure_capabilities(
      {
        cmd = { 'lua-language-server' },
        on_init = function(client)
          client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
            runtime = {
              version = 'LuaJIT'
            },
            workspace = {
              checkThirdParty = false,
              library = {
                vim.env.VIMRUNTIME
              },
            }
          })
        end,
        settings = {
          Lua = {}
        }
      }
    ))
    vim.lsp.enable('lua_ls')
  end
}
