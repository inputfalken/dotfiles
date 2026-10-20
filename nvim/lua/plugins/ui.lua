return {
  {
    'sainnhe/gruvbox-material',
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('gruvbox-material')
      -- ANSI black is the background like in gruvbox, so programs that paint a black background, e.g. .NET's
      -- `info:` log level, don't show a grey box. Bright black keeps gruvbox-material's grey for dimmed text.
      vim.g.terminal_color_0 = '#282828'
    end,
  },
  {
    'nvim-lualine/lualine.nvim',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      sections = {
        lualine_b = {
          'branch',
          {
            'diff',
            symbols = { added = ' ', modified = ' ', removed = ' ' },
            -- Line counts gitsigns already keeps, so lualine doesn't run git diff per buffer.
            source = function()
              local status = vim.b.gitsigns_status_dict
              return status and { added = status.added, modified = status.changed, removed = status.removed }
            end,
          },
          'diagnostics',
        },
        lualine_c = {
          {
            'filename',
            symbols = { modified = '●', readonly = '', newfile = '󰝒' },
            newfile_status = true,
            -- Terminals show their title (oh-my-posh: the shell's folder) instead of the term:// name.
            fmt = function(name)
              return vim.bo.buftype == 'terminal' and vim.b.term_title or name
            end,
          },
        },
      },
    },
  },
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      -- A group with one entry shows that entry instead, e.g. <Leader>bu in place of <Leader>b, and needs no label.
      expand = 1,
      spec = {
        { '<Leader>f', group = 'Find' },
        { '<Leader>g', group = 'Go to', icon = { icon = '󰜴', color = 'blue' } },
        { '<Leader>h', group = 'Git hunk' },
        -- The first key of the two-letter namespaces, e.g. <Leader>db for the database and <Leader>de for debugging.
        { '<Leader>d', group = 'Database & debug', icon = { icon = '', color = 'red' } },
        { '<Leader>r', group = 'Run & reformat', icon = { icon = '', color = 'green' } },
        { '<Leader>bu', group = 'Build', icon = { icon = '󱁤', color = 'orange' } },
        { '<Leader>te', group = 'Test', icon = { icon = '󰙨', color = 'green' } },
        { '<Leader>de', group = 'Debug', icon = { icon = '', color = 'red' } },
        { '<Leader>ls', group = 'Language server', icon = { icon = '󰒋', color = 'blue' } },
      },
      -- Icons for mappings that which-key's built-in rules leave blank, matched on the mapping's description so
      -- they only show where the mapping exists, e.g. LSP and git hunk mappings in buffers that have them.
      icons = {
        rules = {
          { pattern = '^paste last yank$', icon = '󰆒', color = 'yellow' }, -- <Leader>P
          { pattern = '^connect$', icon = '󱘖', color = 'green' }, -- <Leader>dbc
          { pattern = '^edit neovim config$', icon = '', color = 'grey' }, -- <Leader>ev
          { pattern = '^solution errors$', icon = '', color = 'red' }, -- <Leader>fd
          { pattern = '^find usages$', icon = '', color = 'cyan' }, -- <Leader>fu
          { pattern = '^go to definition$', icon = '󰊕', color = 'purple' }, -- <Leader>gd
          { pattern = '^go to implementation$', icon = '', color = 'cyan' }, -- <Leader>gi
          { pattern = '^go to type definition$', icon = '', color = 'orange' }, -- <Leader>gD
          { pattern = '^go to member$', icon = '󰆧', color = 'blue' }, -- <Leader>gm
          { pattern = '^blame line$', icon = '', color = 'yellow' }, -- <Leader>hb
          { pattern = '^preview hunk$', icon = '', color = 'blue' }, -- <Leader>hp
          { pattern = '^reset hunk$', icon = '', color = 'red' }, -- <Leader>hr
          { pattern = '^stage hunk$', icon = '', color = 'green' }, -- <Leader>hs
          { pattern = '^code lens actions$', icon = '󰈈', color = 'purple' }, -- <Leader>cl
          { pattern = '^build solution$', icon = '󱁤', color = 'orange' }, -- <Leader>bus
          { pattern = '^build project$', icon = '󱁤', color = 'yellow' }, -- <Leader>bup
          { pattern = '^run tests in file$', icon = '󰙨', color = 'green' }, -- <Leader>tef
          { pattern = '^test output$', icon = '󰍩', color = 'blue' }, -- <Leader>teo
          { pattern = '^test summary$', icon = '󰙅', color = 'blue' }, -- <Leader>tes
          { pattern = '^start or continue debugging$', icon = '', color = 'green' }, -- <Leader>dec
          { pattern = '^toggle breakpoint$', icon = '', color = 'red' }, -- <Leader>deb
          { pattern = '^clear breakpoints$', icon = '󰗩', color = 'red' }, -- <Leader>deB
          { pattern = '^debug nearest test$', icon = '', color = 'yellow' }, -- <Leader>det
        },
      },
    },
  },
  { 'j-hui/fidget.nvim', event = 'LspAttach', opts = {} }, -- LSP progress, e.g. Roslyn loading a solution.
}
