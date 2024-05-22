local prompt_selection = function(prompt_title, options, optionFormatter)
  local utils = require('modules.util');
  local mapped_options = optionFormatter == nil
      and utils.map(options, function(i, x) return string.format('%s : %s', i, x) end)
      or utils.map(options, function(i, x) return string.format('%s : %s', i, optionFormatter(x)) end)

  table.insert(mapped_options, 1, prompt_title)
  local index = vim.fn.inputlist(mapped_options)

  return index > 0
      and options[index]
      or nil
end

local resolve_path = function(cmd, opts)
  local results = vim.fn.systemlist(cmd)

  if #results == 0 then
    print(string.format('Command "%s" gave no result', cmd))
    return
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
    })
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
        type    = 'coreclr',
        name    = 'Launch (CWD)',
        request = 'launch',
        program = function()
          return dll_selection(vim.fn.getcwd(), true) or dap.ABORT
        end,
      },
      {
        type    = 'coreclr',
        name    = 'Launch (CWF)',
        request = 'launch',
        program = function()
          return dll_selection(vim.fn.expand('%:p:h'), false) or dap.ABORT
        end,
      },
      {
        name      = 'Attach to process',
        type      = 'coreclr',
        request   = 'attach',
        processId = function()
          local name_id_json = vim.fn.system(
            [[
               Get-Process
               | Where-Object { $_.Path -ne $null } `
               | Where-Object { $_.Path.StartsWith($env:USERPROFILE) } `
               | Sort-Object -Descending StartTime `
               | Select-Object Id, @{Name = 'Name'; Expression='ProcessName'} `
               | ConvertTo-Json -Compress
            ]]
          )
          local table = vim.json.decode(name_id_json);
          if (table == nil) then
            print('Could not convert system call into json.')
            return dap.ABORT
          end
          if (#table == 0) then
            print('No processes found')
            return dap.ABORT
          end
          local decision = prompt_selection('Select process', table,
            function(x)
              if (x.Name == nil or x.Id == nil) then
                error(string.format('Unexpected fields in JSON \'%s\''), name_id_json)
              end
              return string.format('%s(%s)', x.Name, x.Id)
            end
          )
          if (decision == nil) then
            return dap.ABORT
          end

          return decision.Id
        end,
        args      = {},
      },
    }

    dap.configurations.cs = config
    dap.configurations.fsharp = config
  end
}
