local prompt_selection = function(items, opts)
  local utils = require('modules.util');
  local mapped_options = opts.element_stringifier == nil
      and utils.map(items, function(i, x) return string.format('%s : %s', i, x) end)
      or utils.map(items, function(i, x) return string.format('%s : %s', i, opts.element_stringifier(x)) end)

  table.insert(mapped_options, 1, opts.multiple_title_message)
  local index = vim.fn.inputlist(mapped_options)

  return index > 0
      and items[index]
      or nil
end

local select_element_from_table = function(items, opts)
  if #items == 0 then
    print(string.format('Command "%s" gave no result', items))
    return
  end

  return (opts.smartSelect and #items == 1)
      and items[1]
      or prompt_selection(items, opts)
end


local dll_selection = function(project_list_command)
  local project_json = vim.fn.system(project_list_command)

  local project_file_path = select_element_from_table(
    vim.json.decode(project_json),
    { multiple_title_message = 'Select project:', smartSelect = true }
  )

  if project_file_path == nil then
    return
  end

  local project_directory_path = vim.fn.fnamemodify(project_file_path, ':p:h')
  local binary_paths_json = vim.fn.system(
    string.format(
      [[
        Get-ChildItem -Path %s -Recurse -Directory -Filter 'bin' `
        | Get-ChildItem -Filter 'Debug' `
        | Get-ChildItem `
        | Select-Object -ExpandProperty FullName `
        | ConvertTo-Json -Compress -AsArray
      ]],
      project_directory_path
    )
  )
  local binary_path = select_element_from_table(
    vim.json.decode(binary_paths_json),
    { multiple_title_message = 'Select binary:', smartSelect = true }
  )
  if binary_path == nil then
    return
  end

  -- Sets the working directory for the window/buffer only.
  vim.cmd(string.format('lcd %s', project_directory_path))

  return binary_path
      .. '/'
      .. vim.fn.fnamemodify(project_file_path, ':t:r') -- name of file
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
          return dll_selection(
            string.format(
              [[
                Get-ChildItem -Recurse -Depth 10 -Path '%s' -File -Filter '*.csproj' `
                | Select-Object -ExpandProperty FullName `
                | ConvertTo-Json -Compress -AsArray
              ]],
              vim.fn.getcwd()
            )
          ) or dap.ABORT
        end,
      },
      {
        type    = 'coreclr',
        name    = 'Launch (CWF)',
        request = 'launch',
        program = function()
          return dll_selection(
            string.format(
              [[
                $items
                $cwd = Get-Item -Path '%s'
                $rootDirectory = Get-Item -Path '/'
                do {
                  $items = Get-ChildItem -Path $cwd.FullName -Filter '*.csproj'
                  $cwd = $cwd.Parent
                } until ($items -or ($cwd.FullName -eq $rootDirectory.FullName))
                $items `
                | Select-Object -ExpandProperty FullName `
                | ConvertTo-Json -Compress -AsArray
              ]],
              vim.fn.expand('%:p:h')
            )
          ) or dap.ABORT
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
              | ConvertTo-Json -Compress -AsArray
            ]]
          )
          local table = vim.json.decode(name_id_json);
          if (table == nil) then
            print('Could not convert system call into json.')
            return dap.ABORT
          end

          local process = select_element_from_table(
            table,
            {
              multiple_title_message = 'Select process:',
              smartSelect = false,
              element_stringifier = function(x)
                if (x.Name == nil or x.Id == nil) then
                  error(string.format('Unexpected fields in JSON \'%s\''), name_id_json)
                end
                return string.format('%s(%s)', x.Name, x.Id)
              end
            }
          )

          return process == nil
              and dap.ABORT
              or process.Id
        end,
        args      = {},
      },
    }

    dap.configurations.cs = config
    dap.configurations.fsharp = config
  end
}