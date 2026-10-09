return {
  {
    'max397574/better-escape.nvim',
    opts = {
      default_mappings = false,
      mappings = { i = { j = { k = '<Esc>' } } }
    }
  },
  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')
        local map = function(lhs, rhs, desc)
          vim.keymap.set('n', lhs, rhs, { buffer = bufnr, desc = desc })
        end
        map(']h', function() gitsigns.nav_hunk('next') end, 'Next git hunk')
        map('[h', function() gitsigns.nav_hunk('prev') end, 'Previous git hunk')
        map('<Leader>hp', gitsigns.preview_hunk, 'Preview hunk')
        map('<Leader>hs', gitsigns.stage_hunk, 'Stage hunk')
        map('<Leader>hr', gitsigns.reset_hunk, 'Reset hunk')
        map('<Leader>hb', gitsigns.blame_line, 'Blame line')
      end
    }
  },
}
