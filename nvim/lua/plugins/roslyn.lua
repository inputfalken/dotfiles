return {
  -- Loads the solution that contains the file's project. When several do, a repo's `.nvim.lua`
  -- can prefer one through `vim.g.roslyn_solution`, e.g. 'App.sln'.
  'seblyng/roslyn.nvim',
  ft = 'cs',
  dependencies = { 'mason-org/mason.nvim' },
  keys = {
    { '<Leader>bu', function() require('modules.dotnet').build_current() end, desc = 'Build solution' },
  },
  opts = {
    choose_target = function(targets)
      return vim.iter(targets):find(function(target)
        return vim.fs.basename(target) == vim.g.roslyn_solution
      end)
    end
  }
}
