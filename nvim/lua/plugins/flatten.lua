return {
  -- Neovim started inside a terminal (`nvim file`, git commit, rebase -i) opens its files here instead of nesting.
  -- Loaded first, so the nested instance hands over before other plugins load. git waits for commit and rebase buffers.
  'willothy/flatten.nvim',
  lazy = false,
  priority = 1001,
  opts = {
    window = {
      -- -p[N], -o[N] and -O[N] open each file (piped text first) in a new tab or split like a plain `nvim` does,
      -- otherwise the piped text or the last file replaces the terminal's buffer.
      open = function(ctx)
        local buffers = vim.tbl_map(function(file)
          return file.bufnr
        end, ctx.files)
        if ctx.stdin_buf then
          table.insert(buffers, 1, ctx.stdin_buf.bufnr)
        end
        if #buffers == 0 then
          return nil
        end
        local layouts = { p = 'tabnew', o = 'split', O = 'vsplit' }
        local layout = vim.iter(ctx.argv):map(function(arg)
          return layouts[arg:match('^%-([poO])%d*$')]
        end):next()
        if not layout then
          local focus = ctx.stdin_buf and buffers[1] or buffers[#buffers]
          vim.api.nvim_set_current_buf(focus)
          return focus, vim.api.nvim_get_current_win()
        end
        for _, bufnr in ipairs(buffers) do
          vim.cmd(layout)
          vim.api.nvim_set_current_buf(bufnr)
        end
        return buffers[#buffers], vim.api.nvim_get_current_win()
      end,
    },
  },
}
