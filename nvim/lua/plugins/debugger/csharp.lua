local dotnet = require('modules.dotnet')
local ui = require('dap.ui')

-- Runs `fn` in a coroutine and hands its result to nvim-dap, see `:h dap-configuration`.
local function async(fn)
  return coroutine.create(function(dap_run_co)
    coroutine.resume(dap_run_co, fn())
  end)
end

-- Picks a project, builds it like Rider and returns the assembly to debug. Must be called from within a coroutine.
local function launch_program(projects)
  if #projects == 0 then
    vim.notify('No project found', vim.log.levels.WARN)
    return
  end
  local project = ui.pick_if_many(projects, 'Select project:', vim.fs.basename)
  if project == nil then
    return
  end

  local co = coroutine.running()
  dotnet.build(project, function(succeeded) coroutine.resume(co, succeeded) end)
  if coroutine.yield() == false then
    return
  end

  -- Sets the working directory for the window/buffer only.
  vim.cmd.lchdir(vim.fs.dirname(project))
  return dotnet.target_path(project)
end

return {
  setup = function(dap)
    local adapter = dotnet.dap_adapter
    dap.adapters[adapter] = {
      type = 'executable',
      -- Mason's `bin` only has a `.cmd` shim, which libuv can't spawn on Windows.
      command = vim.fn.expand('$MASON/packages/netcoredbg/netcoredbg/netcoredbg.exe'),
      args = { '--interpreter=vscode' }
    }
    -- Like Rider's "Break on user-unhandled exceptions".
    dap.defaults[adapter].exception_breakpoints = { 'user-unhandled' }
    local config = {
      {
        type    = adapter,
        name    = 'Launch (CWD)',
        request = 'launch',
        program = function()
          local cwd = vim.fn.getcwd()
          return async(function()
            return launch_program(dotnet.find_projects(cwd)) or dap.ABORT
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
            return launch_program({ dotnet.nearest_project(file_directory) }) or dap.ABORT
          end)
        end,
      },
      {
        name      = 'Attach to process',
        type      = adapter,
        request   = 'attach',
        processId = function()
          return async(function()
            -- Processes started from the user's profile, newest first.
            local processes = vim.json.decode(vim.fn.system([[
              Get-Process `
              | Where-Object { $_.Path -and $_.Path.StartsWith($env:USERPROFILE) } `
              | Sort-Object -Descending StartTime `
              | Select-Object Id, @{Name = 'Name'; Expression='ProcessName'} `
              | ConvertTo-Json -Compress -AsArray
            ]]))
            local process = ui.pick_one(processes, 'Select process:', function(p)
              return string.format('%s(%s)', p.Name, p.Id)
            end)
            return process and process.Id or dap.ABORT
          end)
        end,
        args      = {},
      },
    }

    dap.configurations.cs = config
    dap.configurations.fsharp = config
  end
}
