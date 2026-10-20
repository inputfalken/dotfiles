return {
  {
    'max397574/better-escape.nvim',
    event = { 'InsertEnter', 'TermEnter' },
    opts = {
      default_mappings = false,
      -- Typed jk only, pasted text containing jk stays text.
      mappings = {
        i = { j = { k = '<Esc>' } },
        t = { j = { k = '<C-\\><C-n>' } },
      },
    },
  },
  {
    'lewis6991/gitsigns.nvim',
    event = 'VeryLazy',
    keys = function()
      -- Every review key closes the diff panel open in the current tab instead, like the file system toggle.
      local toggle = function(open)
        return function()
          local panel = vim.iter(vim.api.nvim_tabpage_list_wins(0)):find(function(win)
            return vim.bo[vim.api.nvim_win_get_buf(win)].filetype == 'gitsigns-diff'
          end)
          if panel ~= nil then
            vim.api.nvim_set_current_win(panel)
            vim.cmd.normal('q')
            return
          end
          open()
        end
      end
      return {
        {
          '<Leader>hd',
          toggle(function()
            require('gitsigns').diff('origin/HEAD...HEAD')
          end),
          desc = 'Review branch',
        },
        {
          '<Leader>hD',
          toggle(function()
            local branches = vim.fn.systemlist({
              'git',
              'for-each-ref',
              '--sort=-committerdate',
              '--format=%(refname:lstrip=2)',
              'refs/remotes',
            })
            vim.ui.select(branches, { prompt = 'Review against:' }, function(branch)
              if branch == nil then
                return
              end
              require('gitsigns').diff(branch .. '...HEAD')
            end)
          end),
          desc = 'Review branch against...',
        },
      }
    end,
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')
        local map = function(lhs, rhs, desc)
          vim.keymap.set('n', lhs, rhs, { buf = bufnr, desc = desc })
        end
        map(']h', '<Cmd>Gitsigns nav_hunk next<CR>', 'Next git hunk')
        map('[h', '<Cmd>Gitsigns nav_hunk prev<CR>', 'Previous git hunk')
        map('<Leader>hp', gitsigns.preview_hunk, 'Preview hunk')
        map('<Leader>hs', gitsigns.stage_hunk, 'Stage hunk')
        map('<Leader>hr', gitsigns.reset_hunk, 'Reset hunk')
        map('<Leader>hb', gitsigns.blame_line, 'Blame line')
      end,
    },
  },
}
