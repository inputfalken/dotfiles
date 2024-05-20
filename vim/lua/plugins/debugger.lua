require('mason-nvim-dap').setup({
  ensure_installed = { 'coreclr' },
  handlers = {
    function(config)
      -- all sources with no handler get passed here

      -- Keep original functionality
      require('mason-nvim-dap').default_setup(config)
    end,
    coreclr = function(config)
      config.adapters = {
        type = 'executable',
        command = require('mason-registry')
            .get_package('netcoredbg')
            :get_install_path() .. '\\netcoredbg\\netcoredbg.exe',
        args = { '--interpreter=vscode' }
      }
      require('mason-nvim-dap').default_setup(config)
    end
  }
})

local dap = require('dap')
dap.set_log_level('TRACE')
vim.keymap.set('n', '<F5>', function() dap.continue() end);
vim.keymap.set('n', '<Leader>bp', function() dap.toggle_breakpoint() end);
vim.keymap.set('n', '<F10>', function() dap.step_into() end);
vim.keymap.set('n', '<F11>', function() dap.step_over() end);
vim.keymap.set('n', '<F12>', function() dap.step_into() end);


local resolve_path = function(cmd, opts)
  local prompt_selection = function(prompt_title, options)
    local index_options = function(array)
      local result = {}
      for i, value in ipairs(array) do
        result[i] = i .. ': ' .. value
      end
      return result
    end

    local indexed_options = index_options(options)
    table.insert(indexed_options, 1, prompt_title)
    local index = vim.fn.inputlist(indexed_options)

    return index > 0
        and options[index]
        or nil
  end

  local results = vim.fn.systemlist(cmd)

  if #results == 0 then
    print(string.format('Command "%s" gave no result', cmd))
    return
  end

  if opts.allow_multiple then
    return results
  end

  return #results > 1
      and prompt_selection(opts.multiple_title_message, results)
      or results[1]
end


local dll_selection = function(path, searchInward)
  local project_file = resolve_path(
    string.format(
      searchInward
      and
      [[
        Get-ChildItem -Recurse -Depth 10 -Path %s -File -Filter "*.csproj"`
        | Select-Object -ExpandProperty FullName
      ]]
      or
      [[
        $items
        $cwd = Get-Item -Path '%s'
        $rootDirectory = Get-Item -Path '/'
        do {
          $items = Get-ChildItem -Path $cwd.FullName -Filter '*.csproj'
          $cwd = $cwd.Parent
        } until ($items -or ($cwd.FullName -eq $rootDirectory.FullName))
        $items | Select-Object -ExpandProperty FullName
      ]],
      path
    ),
    {
      empty_message = 'No csproj files found in ' .. path,
      multiple_title_message = 'Select project:'
    }):match('^%s*(.-)%s*$')
  if project_file == nil then
    return
  end

  local bin_path = resolve_path(
    string.format(
      [[
        Get-ChildItem -Path %s -Recurse -Directory -Filter 'bin' `
        | Get-ChildItem -Filter 'Debug' `
        | Get-ChildItem `
        | Select-Object -ExpandProperty FullName
      ]],
      vim.fn.fnamemodify(project_file, ':p:h') -- Gets the directory of the csproj
    ),
    {
      empty_message = 'No dotnet directories found in the "bin" directory. Ensure project has been built.',
      multiple_title_message = 'Select NET Version:'
    }):match('^%s*(.-)%s*$')
  if bin_path == nil then
    return
  end

  return bin_path
      .. '/'
      .. vim.fn.fnamemodify(project_file, ':t:r') -- name of file
      .. '.dll'
end


local config = {
  {
    type = 'coreclr',
    name = 'Launch (CWD)',
    request = 'launch',
    program = function()
      return dll_selection(vim.fn.getcwd(), true) or dap.ABORT
    end,
  },
  {
    type = 'coreclr',
    name = 'Launch (CWF)',
    request = 'launch',
    program = function()
      return dll_selection(vim.fn.expand('%:p:h'), false) or dap.ABORT
    end,
  },
  {
    name = 'Attach to process',
    type = 'corecls',
    request = 'attach',
    pid = require('dap.utils').pick_process,
    args = {},
  },
}
dap.configurations.cs = config
dap.configurations.fsharp = config

local dapui = require('dapui')
dapui.setup()
dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end
