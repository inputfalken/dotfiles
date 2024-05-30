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

vim.diagnostic.config({ virtual_text = false, severity_sort = true })

vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr, client = args.buf, vim.lsp.get_client_by_id(args.data.client_id)

    if client.server_capabilities.completionProvider then
      vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    end
    if client.server_capabilities.definitionProvider then
      vim.bo[bufnr].tagfunc = 'v:lua.vim.lsp.tagfunc'
    end

    local floatOpts = {
      focusable = false,
      close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
      border = 'rounded',
      source = 'always',
      prefix = ' ',
      scope = 'cursor',
    }

    -- Open diagnostic pop-up when hovering.
    -- `vim.o.updatetime = 100` will affect how fast the window is shown, default is 4000.
    vim.api.nvim_create_autocmd('CursorHold', {
      buffer = bufnr,
      callback = function()
        vim.diagnostic.open_float(nil, floatOpts)
      end
    })

    -- Mappings.
    local opts = { buffer = bufnr, noremap = true, silent = true }
    vim.keymap.set('n', '<Leader>gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', '<Leader>gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', '<Leader>fu', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<Leader>gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<Leader>?', function()
      if (vim.diagnostic.open_float(nil, floatOpts) ~= nil) then
        return
      end
--      if (vim.lsp.buf.signature_help() ~= nil) then
--        return
--      end
      if (vim.lsp.buf.hover() ~= nil) then
        return
      end
    end, opts)
    vim.keymap.set({ 'n', 'i' }, '<F2>', vim.lsp.buf.rename, opts)
    vim.keymap.set('n', '<Leader>gne', vim.diagnostic.goto_next, opts)
    vim.keymap.set('n', '<Leader>gpe', vim.diagnostic.goto_prev, opts)
    vim.keymap.set('n', '<A-CR>', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<Leader>rc', vim.lsp.buf.format, opts)
  end,
})

vim.g.coq_settings = { auto_start = 'shut-up', keymap = { manual_complete = '<C-E>' } }
local lsp, coq = require('lspconfig'), require('coq')
require('plugins.lsp.csharp').setup(lsp, coq);
require('plugins.lsp.typescript').setup(lsp, coq)
require('plugins.lsp.lua').setup(lsp, coq);
require('plugins.lsp.powershell').setup(lsp, coq);
