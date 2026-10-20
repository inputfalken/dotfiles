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
    opts = {
      on_attach = function(bufnr)
        local gitsigns = require('gitsigns')
        local map = function(lhs, rhs, desc)
          vim.keymap.set('n', lhs, rhs, { buf = bufnr, desc = desc })
        end
        map(']h', function()
          gitsigns.nav_hunk('next')
        end, 'Next git hunk')
        map('[h', function()
          gitsigns.nav_hunk('prev')
        end, 'Previous git hunk')
        map('<Leader>hp', gitsigns.preview_hunk, 'Preview hunk')
        map('<Leader>hs', gitsigns.stage_hunk, 'Stage hunk')
        map('<Leader>hr', gitsigns.reset_hunk, 'Reset hunk')
        map('<Leader>hb', gitsigns.blame_line, 'Blame line')
      end,
    },
  },
  {
    'sindrets/diffview.nvim',
    cmd = { 'DiffviewOpen', 'DiffviewFileHistory' },
    keys = function()
      -- Every diffview key closes the diffview open in the current tab instead, like the file system toggle.
      local toggle = function(open)
        return function()
          if require('diffview.lib').get_current_view() ~= nil then
            vim.cmd.DiffviewClose()
            return
          end
          open()
        end
      end
      return {
        {
          '<Leader>hd',
          toggle(function()
            vim.cmd.DiffviewOpen('origin/HEAD...HEAD')
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
              vim.cmd.DiffviewOpen(branch .. '...HEAD')
            end)
          end),
          desc = 'Review branch against...',
        },
        {
          '<Leader>hf',
          toggle(function()
            vim.cmd.DiffviewFileHistory('%')
          end),
          desc = 'File history',
        },
      }
    end,
  },
}
