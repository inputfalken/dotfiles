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
      cond = function() return vim.fn.executable(vim.fn.has('win32') == 1 and 'cmake' or 'make') == 1 end,
    },
  },
  keys = {
    { '<Leader>fa', function() require('modules.search_everywhere').open() end, desc = 'Search everywhere' },
    { '<Leader>/',  function() require('telescope.builtin').live_grep() end,  desc = 'Live grep' },
    { '<Leader>ff', function() require('telescope.builtin').find_files() end, desc = 'Find files' },
    { '<Leader>fh', function() require('telescope.builtin').help_tags() end,  desc = 'Find help' },
    { '<Leader>fb', function() require('telescope.builtin').buffers() end,    desc = 'Find buffers' },
    { '<Leader>gf', function() require('telescope.builtin').git_files() end,  desc = 'Git files' },
  },
  init = function()
    -- `vim.ui.select`, e.g. code actions, opens a filterable list at the cursor like Rider's context actions.
    -- Loading the extension replaces this stub with its own picker.
    vim.ui.select = function(...)
      require('telescope').load_extension('ui-select')
      return vim.ui.select(...)
    end
  end,
  config = function()
    -- Folders a project's `.nvim.lua` hides from all pickers. Matched with either path separator,
    -- since git_files returns '/' while fd returns '\' on Windows.
    local file_ignore_patterns = vim.tbl_map(function(path)
      return '^' .. vim.pesc(vim.fs.normalize(path)):gsub('/', '[/\\]') .. '[/\\]'
    end, vim.g.telescope_ignore_paths or {})

    local telescope = require('telescope')
    telescope.setup({
      defaults = { file_ignore_patterns = file_ignore_patterns },
      extensions = { ['ui-select'] = { require('telescope.themes').get_cursor() } }
    })
    pcall(telescope.load_extension, 'fzf')
    telescope.load_extension('ui-select')
  end
}
