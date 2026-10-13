return {
  -- Loads the solution that contains the file's project. When several do, a repo's `.nvim.lua`
  -- can prefer one through `vim.g.roslyn_solution`, e.g. 'App.sln'.
  -- Known limitation: a file with no solution above it (a project outside every solution, or a .NET 10 file-based
  -- app) joins the last solution any buffer loaded instead of its own project or single-file mode, as roslyn.nvim
  -- prefers `vim.g.roslyn_nvim_selected_solution` over the file's `.csproj`. A fresh Neovim avoids it. Worth
  -- revisiting if roslyn.nvim only falls back to that solution when it contains the file's project.
  'seblyng/roslyn.nvim',
  ft = 'cs',
  keys = {
    {
      '<Leader>bus',
      function()
        require('modules.dotnet').build_current()
      end,
      desc = 'Build solution',
    },
    {
      '<Leader>bup',
      function()
        require('modules.dotnet').build_project()
      end,
      desc = 'Build project',
    },
    {
      '<Leader>run',
      function()
        require('modules.dotnet').run_project()
      end,
      desc = 'Run project',
    },
  },
  opts = {
    choose_target = function(targets)
      return vim.iter(targets):find(function(target)
        return vim.fs.basename(target) == vim.g.roslyn_solution
      end)
    end,
  },
}
