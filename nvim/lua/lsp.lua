-- Server specific configuration lives in `after/lsp/<server>.lua`, see `:h lsp-config`.
-- Servers installed through mason are enabled automatically by mason-lspconfig, except Roslyn which roslyn.nvim runs.

-- Diagnostics {
local severity_icons = {
  [vim.diagnostic.severity.ERROR] = '󰅚',
  [vim.diagnostic.severity.WARN] = '󰀪',
  [vim.diagnostic.severity.INFO] = '󰋽',
  [vim.diagnostic.severity.HINT] = '󰌶',
}

local float_opts = {
  focusable = false,
  close_events = { 'BufLeave', 'CursorMoved', 'InsertEnter', 'FocusLost' },
  border = 'rounded',
  source = true,
  header = { '󰒡 Diagnostics', 'Title' },
  prefix = function(diagnostic)
    local name = vim.diagnostic.severity[diagnostic.severity]
    return severity_icons[diagnostic.severity] .. ' ', 'Diagnostic' .. name:sub(1, 1) .. name:sub(2):lower()
  end,
  scope = 'cursor',
}

vim.diagnostic.config({
  signs = {
    text = severity_icons,
    numhl = {
      [vim.diagnostic.severity.ERROR] = 'DiagnosticSignError',
      [vim.diagnostic.severity.WARN] = 'DiagnosticSignWarn',
    },
  },
  virtual_text = {
    prefix = function(diagnostic)
      return severity_icons[diagnostic.severity]
    end,
  },
  severity_sort = true,
  float = float_opts,
})
-- }

-- Code lens {
-- Reference counts above types and members, like Rider's code vision.
vim.lsp.codelens.enable(true)
-- }

-- Inlay hints {
-- Shown while reading, hidden while typing so they don't shift the text.
vim.lsp.inlay_hint.enable(true)
vim.api.nvim_create_autocmd({ 'InsertEnter', 'InsertLeave' }, {
  group = vim.api.nvim_create_augroup('LspInlayHint', { clear = true }),
  callback = function(event)
    vim.lsp.inlay_hint.enable(event.event == 'InsertLeave', { bufnr = event.buf })
  end,
})
-- }

-- Solution errors {
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
  end,
})
vim.keymap.set('n', '<Leader>fd', function()
  vim.lsp.buf.workspace_diagnostics()
  vim.diagnostic.setqflist({ title = solution_errors, severity = vim.diagnostic.severity.ERROR })
end, { desc = 'Solution errors' })
-- }

-- Attach {
-- One group per feature, each cleared per buffer only by a server that has the feature, so a second server
-- attaching to the same buffer doesn't remove the first one's autocmds.
local hover_group = vim.api.nvim_create_augroup('LspDiagnosticHover', { clear = true })
local highlight_group = vim.api.nvim_create_augroup('LspDocumentHighlight', { clear = true })
local eslint_group = vim.api.nvim_create_augroup('LspEslintFixOnSave', { clear = true })
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)

    -- Open diagnostic pop-up when hovering, the delay is controlled by 'updatetime'.
    -- Cleared first so multiple clients attaching to a buffer don't stack autocmds.
    vim.api.nvim_clear_autocmds({ group = hover_group, buf = bufnr })
    vim.api.nvim_create_autocmd('CursorHold', {
      group = hover_group,
      buf = bufnr,
      callback = function()
        vim.diagnostic.open_float()
      end,
    })

    -- Highlight the other uses of the symbol under the cursor, like Rider.
    if client and client:supports_method('textDocument/documentHighlight') then
      vim.api.nvim_clear_autocmds({ group = highlight_group, buf = bufnr })
      vim.api.nvim_create_autocmd('CursorHold', {
        group = highlight_group,
        buf = bufnr,
        callback = vim.lsp.buf.document_highlight,
      })
      vim.api.nvim_create_autocmd({ 'CursorMoved', 'InsertEnter', 'BufLeave' }, {
        group = highlight_group,
        buf = bufnr,
        callback = vim.lsp.buf.clear_references,
      })
    end

    -- ESLint fixes the file before it is saved, the command comes from nvim-lspconfig's eslint config.
    if client and client.name == 'eslint' then
      vim.api.nvim_clear_autocmds({ group = eslint_group, buf = bufnr })
      vim.api.nvim_create_autocmd('BufWritePre', {
        group = eslint_group,
        buf = bufnr,
        command = 'LspEslintFixAll',
      })
    end

    -- The server's fold ranges (e.g. C# #region) replace treesitter's for this buffer.
    if client and client:supports_method('textDocument/foldingRange') then
      for _, win in ipairs(vim.fn.win_findbuf(bufnr)) do
        vim.wo[win][0].foldexpr = 'v:lua.vim.lsp.foldexpr()'
      end
    end

    -- Mappings. Next/previous diagnostic are Neovim's default `]d`/`[d`.
    local map = function(mode, lhs, rhs, desc)
      vim.keymap.set(mode, lhs, rhs, { buf = bufnr, desc = desc })
    end
    -- Telescope is required on use, so attaching a server doesn't load it.
    map('n', '<Leader>gd', function()
      require('telescope.builtin').lsp_definitions()
    end, 'Go to definition')
    map('n', '<Leader>fu', function()
      require('telescope.builtin').lsp_references({ include_declaration = false })
    end, 'Find usages')
    map('n', '<Leader>gi', function()
      require('telescope.builtin').lsp_implementations()
    end, 'Go to implementation')
    map('n', '<Leader>gD', function()
      require('telescope.builtin').lsp_type_definitions()
    end, 'Go to type definition')
    -- The file's types and members like Rider's "Go to File Member", locals and namespaces are left out.
    map('n', '<Leader>gm', function()
      require('telescope.builtin').lsp_document_symbols({
        symbols = {
          'Class', 'Struct', 'Interface', 'Enum', 'EnumMember', 'Constructor', 'Method', 'Function', 'Property',
          'Field', 'Event', 'Constant', 'Operator',
        },
      })
    end, 'Go to member')
    map('n', '<Leader>?', function()
      if vim.diagnostic.open_float() == nil then
        vim.lsp.buf.hover({ border = 'rounded' })
      end
    end, 'Diagnostics or hover')
    map({ 'n', 'i' }, '<F2>', vim.lsp.buf.rename, 'Rename')
    if client and client:supports_method('textDocument/codeLens') then
      map('n', '<Leader>cl', vim.lsp.codelens.run, 'Code lens actions')
    end
    -- Only for servers with code actions, so the mssql.nvim server keeps `<C-CR>` for executing SQL.
    if client and client:supports_method('textDocument/codeAction') then
      -- Alt+Enter like Rider, Windows Terminal's settings.json unbinds it from full screen. Ctrl+Enter opens the
      -- actions as well.
      map({ 'n', 'i', 'x' }, '<A-CR>', vim.lsp.buf.code_action, 'Code actions')
      map({ 'n', 'i', 'x' }, '<C-CR>', vim.lsp.buf.code_action, 'Code actions')
    end
  end,
})
-- }

-- Servers {
-- Stop and restart act on the servers attached to the buffer. Start re-enables only the servers already enabled for
-- its filetype, as `:lsp enable` without names would also enable unused configs such as nvim-lspconfig's roslyn_ls.
vim.keymap.set('n', '<Leader>lss', function()
  local names = vim
    .iter(vim.lsp.get_configs({ enabled = true, filetype = vim.bo.filetype }))
    :map(function(config)
      return config.name
    end)
    :totable()
  vim.lsp.enable(names)
end, { desc = 'Start language servers' })
vim.keymap.set('n', '<Leader>lsq', '<Cmd>lsp stop<CR>', { desc = 'Stop language servers' })
vim.keymap.set('n', '<Leader>lsr', '<Cmd>lsp restart<CR>', { desc = 'Restart language servers' })
-- }
