-- Server specific configuration lives in `after/lsp/<server>.lua`, see `:h lsp-config`.
-- Servers installed through mason are enabled automatically by mason-lspconfig.
return {
  setup = function()
    local floatOpts = {
      focusable = false,
      close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
      border = 'rounded',
      source = true,
      prefix = ' ',
      scope = 'cursor',
    }

    vim.diagnostic.config({
      underline = true,
      virtual_text = true,
      severity_sort = true,
      float = floatOpts,
    })

    local hover_group = vim.api.nvim_create_augroup('LspDiagnosticHover', { clear = true })
    vim.api.nvim_create_autocmd('LspAttach', {
      callback = function(args)
        local bufnr, client = args.buf, vim.lsp.get_client_by_id(args.data.client_id)
        if client == nil then
          error([[Could not obtain client from event 'LspAttach']])
        end

        -- Open diagnostic pop-up when hovering, the delay is controlled by 'updatetime'.
        -- Cleared first so multiple clients attaching to a buffer don't stack autocmds.
        vim.api.nvim_clear_autocmds({ group = hover_group, buffer = bufnr })
        vim.api.nvim_create_autocmd('CursorHold', {
          group = hover_group,
          buffer = bufnr,
          callback = function()
            vim.diagnostic.open_float(floatOpts)
          end
        })

        -- Mappings.
        local opts = { buffer = bufnr, silent = true }
        local telescope = require('telescope.builtin')
        vim.keymap.set('n', '<Leader>gd', telescope.lsp_definitions, opts)
        vim.keymap.set('n', '<Leader>fu', telescope.lsp_references, opts)
        vim.keymap.set('n', '<Leader>gi', telescope.lsp_implementations, opts)
        vim.keymap.set('n', '<Leader>gD', telescope.lsp_type_definitions, opts)
        vim.keymap.set('n', '<Leader>?', function()
          if vim.diagnostic.open_float(floatOpts) == nil then
            vim.lsp.buf.hover({ border = 'rounded' })
          end
        end, opts)
        vim.keymap.set({ 'n', 'i' }, '<F2>', vim.lsp.buf.rename, opts)
        vim.keymap.set('n', '<Leader>gne', function() vim.diagnostic.jump({ count = 1, float = true }) end, opts)
        vim.keymap.set('n', '<Leader>gpe', function() vim.diagnostic.jump({ count = -1, float = true }) end, opts)
        vim.keymap.set('n', '<A-CR>', vim.lsp.buf.code_action, opts)
        vim.keymap.set('n', '<Leader>rc', vim.lsp.buf.format, opts)
      end,
    })
  end
}
