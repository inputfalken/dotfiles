return {
  'nvim-tree/nvim-tree.lua',
  dependencies = { 'nvim-tree/nvim-web-devicons' },
  lazy = false, -- Replaces netrw, so it must be loaded to open directories.
  keys = {
    { '<Leader>fe', '<Cmd>NvimTreeToggle<CR>', desc = 'File explorer' },
  },
  opts = {
    sort = {
      sorter = 'case_sensitive',
    },
    view = {
      width = 30,
    },
    renderer = {
      group_empty = true,
    },
    filters = {
      dotfiles = true,
    },
    update_focused_file = {
      enable = true,
      update_root = false,
    }
  }
}
