return {
  'nvim-telescope/telescope.nvim',
  version = '*',
  cmd = 'Telescope',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope-ui-select.nvim',
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = vim.fn.has('win32') == 1
          and 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release --target install'
        or 'make',
      cond = function()
        return vim.fn.executable(vim.fn.has('win32') == 1 and 'cmake' or 'make') == 1
      end,
    },
  },
  keys = {
    {
      '<Leader>fa',
      function()
        require('modules.search_everywhere').open()
      end,
      desc = 'Search everywhere',
    },
    { '<Leader>/', '<Cmd>Telescope live_grep<CR>', desc = 'Live grep' },
    { '<Leader>ff', '<Cmd>Telescope find_files<CR>', desc = 'Find files' },
    { '<Leader>fh', '<Cmd>Telescope help_tags<CR>', desc = 'Find help' },
    { '<Leader>fb', '<Cmd>Telescope buffers<CR>', desc = 'Find buffers' },
  },
  init = function()
    -- `vim.ui.select`, e.g. code actions, opens a filterable list at the cursor like Rider's context actions.
    -- Loading telescope runs its config, whose ui-select extension replaces this stub with its own picker.
    vim.ui.select = function(...)
      require('telescope')
      return vim.ui.select(...)
    end
  end,
  config = function()
    -- Folders a project's `.nvim.lua` hides from all pickers. Matched with either path separator,
    -- since rg and fd return '\' on Windows while buffer names keep the separator they were opened with.
    local file_ignore_patterns = vim.tbl_map(function(path)
      return '^' .. vim.pesc(vim.fs.normalize(path)):gsub('/', '[/\\]') .. '[/\\]'
    end, vim.g.telescope_ignore_paths or {})

    local actions = require('telescope.actions')
    local telescope = require('telescope')
    telescope.setup({
      defaults = {
        file_ignore_patterns = file_ignore_patterns,
        prompt_prefix = '  ',
        selection_caret = ' ',
        multi_icon = '󰄲',
        mappings = {
          i = {
            ['<C-j>'] = actions.move_selection_next,
            ['<C-k>'] = actions.move_selection_previous,
          },
          n = {
            q = actions.close,
            Q = actions.send_selected_to_qflist + actions.open_qflist,
          },
        },
      },
      pickers = {
        buffers = { mappings = { n = { dd = actions.delete_buffer } } },
        git_branches = { mappings = { n = { dd = actions.git_delete_branch } } },
        marks = { mappings = { n = { dd = actions.delete_mark } } },
      },
      extensions = { ['ui-select'] = { require('telescope.themes').get_cursor() } },
    })
    pcall(telescope.load_extension, 'fzf')
    telescope.load_extension('ui-select')
  end,
}
