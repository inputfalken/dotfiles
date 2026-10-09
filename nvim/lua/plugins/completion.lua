return {
  'saghen/blink.cmp',
  version = '1.*',
  event = { 'InsertEnter', 'CmdlineEnter' },
  -- LSP capabilities are registered automatically through `vim.lsp.config('*')`.
  -- Behaves like JetBrains IDEs: the first item is preselected but not inserted until accepted,
  -- Enter accepts, Tab accepts and replaces the rest of the word, Ctrl+Space/Ctrl+Shift+Space/Ctrl+J/Alt+/
  -- trigger basic/smart/live template/word completion and Ctrl+Q/Ctrl+P show docs/parameter info.
  opts = {
    keymap = {
      preset = 'enter',
      ['<Tab>'] = {
        function(cmp)
          if cmp.is_menu_visible() == false or cmp.get_selected_item() == nil then return end

          local bufnr = vim.api.nvim_get_current_buf()
          local row, col = unpack(vim.api.nvim_win_get_cursor(0))
          local suffix = vim.fn.matchstr(vim.api.nvim_get_current_line(), [[^\k\+]], col)
          if suffix == '' then return cmp.accept() end

          -- Extmarks follow the suffix while the accepted item is inserted in front of it.
          local ns = vim.api.nvim_create_namespace('blink_cmp_replace_suffix')
          vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
          local start_id = vim.api.nvim_buf_set_extmark(bufnr, ns, row - 1, col, {})
          local end_id = vim.api.nvim_buf_set_extmark(bufnr, ns, row - 1, col + #suffix, {})

          return cmp.accept({
            callback = function()
              local start = vim.api.nvim_buf_get_extmark_by_id(bufnr, ns, start_id, {})
              local finish = vim.api.nvim_buf_get_extmark_by_id(bufnr, ns, end_id, {})
              vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
              if #start == 0 or #finish == 0 then return end

              -- The language server's edit may already have replaced the suffix.
              local text = vim.api.nvim_buf_get_text(bufnr, start[1], start[2], finish[1], finish[2], {})
              if table.concat(text, '\n') ~= suffix then return end

              vim.api.nvim_buf_set_text(bufnr, start[1], start[2], finish[1], finish[2], {})
            end
          })
        end,
        'snippet_forward',
        'fallback'
      },
      ['<C-S-Space>'] = { function(cmp) return cmp.show({ providers = { 'lsp' } }) end },
      ['<C-j>'] = { function(cmp) return cmp.show({ providers = { 'snippets' } }) end, 'fallback' },
      -- Cyclic word expansion, Vim's own keyword completion starts with the nearest word.
      ['<M-/>'] = {
        function(cmp)
          cmp.hide()
          vim.api.nvim_feedkeys(vim.keycode('<C-p>'), 'n', false)
          return true
        end
      },
      ['<M-?>'] = {
        function(cmp)
          cmp.hide()
          vim.api.nvim_feedkeys(vim.keycode('<C-n>'), 'n', false)
          return true
        end
      },
      ['<C-q>'] = { 'show_documentation', 'hide_documentation', 'fallback' },
      ['<C-p>'] = { 'select_prev', 'show_signature', 'hide_signature', 'fallback_to_mappings' },
    },
    completion = {
      list = { selection = { preselect = true, auto_insert = false } },
      documentation = { auto_show = true },
    },
    signature = { enabled = true },
    sources = {
      default = { 'lazydev', 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        lazydev = { name = 'LazyDev', module = 'lazydev.integrations.blink', score_offset = 100 },
      }
    },
    fuzzy = { implementation = 'prefer_rust_with_warning' }
  }
}
