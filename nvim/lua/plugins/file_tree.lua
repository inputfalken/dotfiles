return {
  setup = function(nvim_tree)
    nvim_tree.setup({
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
    })

    vim.keymap.set('n', '<Leader>fe', '<Cmd>NvimTreeToggle<CR>') -- Open file explorer
  end
}
