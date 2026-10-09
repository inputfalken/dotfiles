local utils = require('modules.util');

-- Must be called from within a coroutine, yields until the user has made a selection.
local prompt_selection = function(items, opts)
  local co = coroutine.running()
  vim.ui.select(items, {
    prompt = string.format('Select %s:', opts.subject),
    format_item = opts.element_stringifier or tostring,
  }, function(choice)
    -- Scheduled since the callback can be invoked before we yield.
    vim.schedule(function() coroutine.resume(co, choice) end)
  end)
  return coroutine.yield()
end

local select_element_from_table = function(items, opts)
  if (items == nil) then
    utils.print_warning(string.format('The list of %s is nil', opts.subject))
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

-- Runs `fn` in a coroutine and hands its result to nvim-dap, see `:h dap-configuration`.
local async = function(fn)
  return coroutine.create(function(dap_run_co)
    coroutine.resume(dap_run_co, fn())
  end)
end

local dll_selection = function(project_list_command)
  local project_list_json = vim.fn.system(project_list_command);
  if (project_list_json == nil or project_list_json == '') then
    utils.print_warning(string.format('The payload was empty from command:\n%s', project_list_command))
    return
  end

  local project_file_path = select_element_from_table(
    vim.json.decode(project_list_json),
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
        Join-Path -Path '%s' -ChildPath 'bin' `
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
  vim.cmd.lchdir(project_directory_path)

  return binary_path
      .. '/'
      .. utils.get_file(project_file_path)
      .. '.dll'
end


return {
  setup = function(dap)
    local adapter = utils.dap_adapaters.csharp
    dap.adapters[adapter] = {
      type = 'executable',
      command = vim.fn.expand('$MASON/packages/netcoredbg/netcoredbg/netcoredbg.exe'),
      args = { '--interpreter=vscode' }
    }
    -- `vim.lsp.buf.list_workspace_folders()` could be used to find projects files.
    local config = {
      {
        type    = adapter,
        name    = 'Launch (CWD)',
        request = 'launch',
        program = function()
          local cwd = vim.fn.getcwd()
          return async(function()
            return dll_selection(
              string.format(
                [=[
                  Get-ChildItem -Recurse -Depth 10 -Path '%s' -File -Filter '*.csproj' `
                  | Sort-Object { [System.Linq.Enumerable]::Count($_.FullName, [Func[char ,bool]]{ param($x) $x -eq [System.IO.Path]::DirectorySeparatorChar }) } `
                  | Select-Object -ExpandProperty FullName `
                  | ConvertTo-Json -Compress -AsArray
                ]=],
                cwd
              )
            ) or dap.ABORT
          end)
        end,
      },
      {
        type    = adapter,
        name    = 'Launch (CWF)',
        request = 'launch',
        program = function()
          local file_directory = vim.fn.expand('%:p:h')
          return async(function()
            return dll_selection(
              string.format(
                [=[
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
                file_directory
              )
            ) or dap.ABORT
          end)
        end,
      },
      {
        name      = 'Attach to process',
        type      = adapter,
        request   = 'attach',
        processId = function()
          return async(function()
            local name_id_json = vim.fn.system(
              [[
                Get-Process `
                | Where-Object { $_.Path -ne $null } `
                | Where-Object { $_.Path.StartsWith($env:USERPROFILE) } `
                | Sort-Object -Descending StartTime `
                | Select-Object Id, @{Name = 'Name'; Expression='ProcessName'} `
                | ConvertTo-Json -Compress -AsArray
              ]]
            )

            local process = select_element_from_table(
              vim.json.decode(name_id_json),
              {
                subject = 'process',
                smartSelect = false,
                element_stringifier = function(x)
                  if (x.Name == nil or x.Id == nil) then
                    error(string.format('Unexpected fields in JSON \'%s\'', name_id_json))
                  end
                  return string.format('%s(%s)', x.Name, x.Id)
                end
              }
            )

            return process == nil
                and dap.ABORT
                or process.Id
          end)
        end,
        args      = {},
      },
    }

    dap.configurations.cs = config
    dap.configurations.fsharp = config
  end
}
