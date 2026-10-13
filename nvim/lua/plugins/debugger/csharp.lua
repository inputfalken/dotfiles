local dotnet = require('modules.dotnet')
local ui = require('dap.ui')

-- Picks a project, builds it like Rider and returns the assembly to debug and the project directory to run it from,
-- Rider's default working directory, or a config nvim-dap aborts. Must be called from within a coroutine.
local function launch_program(projects)
  if #projects == 0 then
    vim.notify('No project found', vim.log.levels.WARN)
    return { program = require('dap').ABORT }
  end
  local project = ui.pick_if_many(projects, 'Select project:', vim.fs.basename)
  if project == nil then
    return { program = require('dap').ABORT }
  end

  local co = coroutine.running()
  dotnet.build(project, function(succeeded)
    coroutine.resume(co, succeeded)
  end)
  if coroutine.yield() == false then
    return { program = require('dap').ABORT }
  end

  dotnet.target_path(project, function(path)
    coroutine.resume(co, path)
  end)
  local program = coroutine.yield()
  if program == nil then
    return { program = require('dap').ABORT }
  end
  return { program = program, cwd = vim.fs.dirname(project) }
end

return {
  setup = function(dap)
    local adapter = 'netcoredbg'
    dap.adapters[adapter] = {
      type = 'executable',
      -- Mason's `bin` only has a `.cmd` shim, which libuv can't spawn on Windows.
      command = vim.fn.expand('$MASON/packages/netcoredbg/netcoredbg/netcoredbg.exe'),
      args = { '--interpreter=vscode' },
    }
    -- Like Rider's "Break on user-unhandled exceptions".
    dap.defaults[adapter].exception_breakpoints = { 'user-unhandled' }
    -- nvim-dap calls `__call` from within its coroutine when a run starts, to add `program` and `cwd`, or `processId`, at once.
    local config = {
      setmetatable({ type = adapter, name = 'Launch project', request = 'launch' }, {
        __call = function(launch)
          local co = coroutine.running()
          dotnet.executable_projects(dotnet.workspace_dir(), function(projects)
            coroutine.resume(co, projects)
          end)
          return vim.tbl_extend('force', launch, launch_program(coroutine.yield()))
        end,
      }),
      setmetatable({ type = adapter, name = 'Launch (CWF)', request = 'launch' }, {
        __call = function(launch)
          local projects = { dotnet.nearest_project(vim.fn.expand('%:p:h')) }
          return vim.tbl_extend('force', launch, launch_program(projects))
        end,
      }),
      setmetatable({ type = adapter, name = 'Attach to process', request = 'attach' }, {
        __call = function(attach)
          -- Every .NET process opens a `dotnet-diagnostic-<pid>` pipe, so these are the processes netcoredbg can attach to.
          local processes = vim
            .iter(vim.fn.readdir('//./pipe/'))
            :map(function(pipe)
              local pid = tonumber(pipe:match('^dotnet%-diagnostic%-(%d+)$'))
              return pid and vim.api.nvim_get_proc(pid)
            end)
            :totable()
          local process = ui.pick_one(processes, 'Select process:', function(p)
            return string.format('%s(%s)', p.name, p.pid)
          end)
          return vim.tbl_extend('force', attach, { processId = process and process.pid or dap.ABORT })
        end,
      }),
    }

    dap.configurations.cs = config
    dap.configurations.fsharp = config
  end,
}
