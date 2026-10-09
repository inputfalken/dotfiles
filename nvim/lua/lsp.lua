-- Server specific configuration lives in `after/lsp/<server>.lua`, see `:h lsp-config`.
-- Servers installed through mason are enabled automatically by mason-lspconfig, except Roslyn which roslyn.nvim runs.
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

-- Reference counts above types and members, like Rider's code vision.
vim.lsp.codelens.enable(true)

-- Compile errors across the current file's solution, like Rider's "Errors in Solution". Workspace diagnostics
-- arrive asynchronously, so the list is refreshed while it is the current quickfix list.
local solution_errors = 'Solution errors'
local refresh_scheduled = false
vim.api.nvim_create_autocmd('DiagnosticChanged', {
  callback = function()
    if refresh_scheduled or vim.fn.getqflist({ title = 0 }).title ~= solution_errors then
      return
    end
    refresh_scheduled = true
    vim.defer_fn(function()
      refresh_scheduled = false
      vim.diagnostic.setqflist({ title = solution_errors, severity = vim.diagnostic.severity.ERROR, open = false })
    end, 200)
  end
})
vim.keymap.set('n', '<Leader>fd', function()
  for _, client in ipairs(vim.lsp.get_clients({ bufnr = 0, method = 'workspace/diagnostic' })) do
    vim.lsp.buf.workspace_diagnostics({ client_id = client.id })
  end
  vim.diagnostic.setqflist({ title = solution_errors, severity = vim.diagnostic.severity.ERROR })
end, { desc = 'Solution errors' })

local hover_group = vim.api.nvim_create_augroup('LspDiagnosticHover', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf

    -- Open diagnostic pop-up when hovering, the delay is controlled by 'updatetime'.
    -- Cleared first so multiple clients attaching to a buffer don't stack autocmds.
    vim.api.nvim_clear_autocmds({ group = hover_group, buffer = bufnr })
    vim.api.nvim_create_autocmd('CursorHold', {
      group = hover_group,
      buffer = bufnr,
      callback = function()
        vim.diagnostic.open_float()
      end
    })

    -- Mappings. Next/previous diagnostic are Neovim's default `]d`/`[d`.
    local opts = { buffer = bufnr, silent = true }
    local telescope = require('telescope.builtin')
    vim.keymap.set('n', '<Leader>gd', telescope.lsp_definitions, opts)
    vim.keymap.set('n', '<Leader>fu', telescope.lsp_references, opts)
    vim.keymap.set('n', '<Leader>gi', telescope.lsp_implementations, opts)
    vim.keymap.set('n', '<Leader>gD', telescope.lsp_type_definitions, opts)
    vim.keymap.set('n', '<Leader>?', function()
      if vim.diagnostic.open_float() == nil then
        vim.lsp.buf.hover({ border = 'rounded' })
      end
    end, opts)
    vim.keymap.set({ 'n', 'i' }, '<F2>', vim.lsp.buf.rename, opts)
    -- Windows Terminal keeps Alt+Enter for full screen, so Ctrl+Enter opens the actions as well.
    vim.keymap.set({ 'n', 'i', 'x' }, '<A-CR>', vim.lsp.buf.code_action, opts)
    vim.keymap.set({ 'n', 'i', 'x' }, '<C-CR>', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', '<Leader>rc', vim.lsp.buf.format, opts)
  end,
})
