require('mason').setup()
require('mason-lspconfig').setup(
  {
    ensure_installed = {
      'tsserver',
      'omnisharp',
      'lua_ls',
      'powershell_es'
-- Not available:
--      'json-lsp',
--      'yaml-language-server',
    }
  }
)

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client.server_capabilities.completionProvider then
      vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    end
    if client.server_capabilities.definitionProvider then
      vim.bo[bufnr].tagfunc = 'v:lua.vim.lsp.tagfunc'
    end

    -- Mappings.
    local opts = { buffer = bufnr, noremap = true, silent = true }
    vim.keymap.set('n', '<Leader>gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', '<Leader>gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<Leader>fu', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<Leader>gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<Leader>?', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<F2>', function() vim.lsp.buf.rename() end, opts)
    vim.keymap.set('n', '<Leader>gn', function() vim.diagnostic.goto_next() end, opts)
    vim.keymap.set('n', '<Leader>gp', function() vim.diagnostic.goto_prev() end, opts)
    vim.keymap.set('n', '<A-CR>', function() vim.lsp.buf.code_action() end, opts)
    vim.keymap.set('n', '<Leader>rc', function() vim.lsp.buf.format({ async = false }) end, opts)
  end,
})

vim.g.coq_settings = { auto_start = 'shut-up', keymap = { manual_complete = '<C-E>' } }
local lsp = require 'lspconfig'
local coq = require 'coq'
lsp.omnisharp.setup(coq.lsp_ensure_capabilities({
  settings = {
    FormattingOptions = {
      EnableEditorConfigSupport = true
    }
  },
  handlers = {
    ['textDocument/definition'] = require('omnisharp_extended').definition_handler,
    ['textDocument/typeDefinition'] = require('omnisharp_extended').type_definition_handler,
    ['textDocument/references'] = require('omnisharp_extended').references_handler,
    ['textDocument/implementation'] = require('omnisharp_extended').implementation_handler,
  }
}))

lsp.tsserver.setup(coq.lsp_ensure_capabilities());
lsp.lua_ls.setup(coq.lsp_ensure_capabilities(
  {
    cmd = { 'lua-language-server' },
    on_init = function(client)
      client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
        runtime = {
          -- Tell the language server which version of Lua you're using
          -- (most likely LuaJIT in the case of Neovim)
          version = 'LuaJIT'
        },
        -- Make the server aware of Neovim runtime files
        workspace = {
          checkThirdParty = false,
          library = {
            vim.env.VIMRUNTIME
            -- Depending on the usage, you might want to add additional paths here.
            -- "${3rd}/luv/library"
            -- "${3rd}/busted/library",
          },
          -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
          --library = vim.api.nvim_get_runtime_file("", true)
        }
      })
    end,
    settings = {
      Lua = {}
    }
  }
))

lsp.powershell_es.setup(coq.lsp_ensure_capabilities(
  {
    settings = { powershell = { codeFormatting = { Preset = 'OTBS' } } }
  }
))
