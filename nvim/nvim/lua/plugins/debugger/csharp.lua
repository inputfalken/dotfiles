local utils = require('modules.util');
local prompt_selection = function(items, opts)
  local mapped_options = opts.element_stringifier == nil
      and utils.map(items, function(i, x) return string.format('%s : %s', i, x) end)
      or utils.map(items, function(i, x) return string.format('%s : %s', i, opts.element_stringifier(x)) end)

  table.insert(mapped_options, 1, string.format('Select %s:', opts.subject))
  local index = vim.fn.inputlist(mapped_options)

  return index > 0
      and items[index]
      or nil
end

local select_element_from_table = function(items, opts)
  if (items == nil) then
    utils.print_warning(string.format(string.format('The list of %s is nil', opts.subject)))
    return
  end

  if #items == 0 then
    utils.print_warning(string.format('The list of %s is empty', opts.subject))
    return
  end

  return (opts.smartSelect and #items == 1)
      and items[1]
      or prompt_selection(items, opts)
end


local dll_selection = function(project_list_command)
  local project_list_json = vim.fn.system(project_list_command);
  if (project_list_json == nil or project_list_json == '') then
    utils.print_warning(string.format('The payload from was empty from command:\n%s', project_list_command))
    return
  end

  local project_file_path = select_element_from_table(
    vim.json.decode(vim.fn.system(project_list_command)),
    { subject = 'project', smartSelect = true }
  )

  if project_file_path == nil then
    return
  end

  local project_directory_path = utils.get_directory(project_file_path);
  -- We currently assume the bin folder is next to the project directory.
  -- TODO combine the commands of finding the *.csproj and binaries to a single shell invocation. which bin folder override from csproj into account.
  local binary_paths_json = vim.fn.system(
    string.format(
      [[
        Join-Path -Path '%s' -ChildPath 'bin'
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
    { subject = 'binary', smartSelect = true }
  )
  if binary_path == nil then
    return
  end

  -- Sets the working directory for the window/buffer only.
  vim.cmd(string.format('lchdir %s', project_directory_path))

  return binary_path
      .. '/'
      .. utils.get_file(project_file_path)
      .. '.dll'
end


return {
  setup = function(dap, mason_registry)
    local adapter = utils.dap_adapaters.csharp
    dap.adapters[adapter] = {
      type = 'executable',
      command = mason_registry
          .get_package('netcoredbg')
          :get_install_path() .. '\\netcoredbg\\netcoredbg.exe',
      args = { '--interpreter=vscode' }
    }
    -- `vim.lsp.buf.list_workspace_folders()` could be used to find projects files.
    local config = {
      {
        type    = adapter,
        name    = 'Launch (CWD)',
        request = 'launch',
        program = function()
          return dll_selection(
            string.format(
              [=[
                Get-ChildItem -Recurse -Depth 10 -Path '%s' -File -Filter '*.csproj' `
                | Sort-Object { [System.Linq.Enumerable]::Count($_.FullName, [Func[char ,bool]]{ param($x) $x -eq [System.IO.Path]::DirectorySeparatorChar }) } `
                | Select-Object -ExpandProperty FullName `
                | ConvertTo-Json -Compress -AsArray
              ]=],
              vim.fn.getcwd()
            )
          ) or dap.ABORT
        end,
      },
      {
        type    = adapter,
        name    = 'Launch (CWF)',
        request = 'launch',
        program = function()
          return dll_selection(
            string.format(
              [=[
                $items
                $cwd = Get-Item -Path '%s'
                $rootDirectory = Get-Item -Path '/'
                do {
                  $items = Get-ChildItem -Path $cwd.FullName -Filter '*.csproj'
                  $cwd = $cwd.Parent
                } until ($items -or ($cwd.FullName -eq $rootDirectory.FullName))
                $items `
                | Sort-Object { [System.Linq.Enumerable]::Count($_.FullName, [Func[char ,bool]]{ param($x) $x -eq [System.IO.Path]::DirectorySeparatorChar }) } `
                | Select-Object -ExpandProperty FullName `
                | ConvertTo-Json -Compress -AsArray
              ]=],
              vim.fn.expand('%:p:h')
            )
          ) or dap.ABORT
        end,
      },
      {
        name      = 'Attach to process',
        type      = adapter,
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

          local process = select_element_from_table(
            table,
            {
              subject = 'process',
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
