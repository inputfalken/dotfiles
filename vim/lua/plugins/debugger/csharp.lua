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
        Get-ChildItem -Recurse -Depth 10 -Path '%s' -File -Filter '*.csproj' `
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

  local project_directory = vim.fn.fnamemodify(project_file, ':p:h')
  local bin_path = resolve_path(
    string.format(
      [[
        Get-ChildItem -Path %s -Recurse -Directory -Filter 'bin' `
        | Get-ChildItem -Filter 'Debug' `
        | Get-ChildItem `
        | Select-Object -ExpandProperty FullName
      ]],
      project_directory
    ),
    {
      empty_message = 'No dotnet directories found in the "bin" directory. Ensure project has been built.',
      multiple_title_message = 'Select NET Version:'
    }):match('^%s*(.-)%s*$')
  if bin_path == nil then
    return
  end

  -- Sets the working directory for the window/buffer only.
  vim.cmd(string.format('lcd %s', project_directory))

  return bin_path
      .. '/'
      .. vim.fn.fnamemodify(project_file, ':t:r') -- name of file
      .. '.dll'
end


return {
  setup = function(dap)
    dap.adapters.coreclr = {
      type = 'executable',
      command = require('mason-registry')
          .get_package('netcoredbg')
          :get_install_path() .. '\\netcoredbg\\netcoredbg.exe',
      args = { '--interpreter=vscode' }
    }

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
  end
}
