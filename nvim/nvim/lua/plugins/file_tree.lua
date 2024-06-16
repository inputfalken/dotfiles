return {
  setup = function(nvim_tree)
    -- disable netrw at the very start of your init.lua
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    -- Remove the default keybind without the plugin.
    vim.keymap.del('n', '<Leader>fe')

    -- optionally enable 24-bit colour
    vim.opt.termguicolors = true

    -- OR setup with some options
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
    })

    vim.keymap.set('n', '<Leader>fe', ':NvimTreeToggle<CR>') -- Open file explorer
  end
}
