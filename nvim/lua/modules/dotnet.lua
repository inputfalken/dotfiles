local function is_project(name)
  return name:match('%.[cf]sproj$') ~= nil
end

-- Projects below `dir`, shallowest first.
local function find_projects(dir)
  return vim.fs.find(is_project, { path = dir, type = 'file', limit = math.huge })
end

local M = {}

-- The project `dir` belongs to.
function M.nearest_project(dir)
  return vim.fs.find(is_project, { path = dir, type = 'file', upward = true })[1]
end

-- The folder of the solution Roslyn loaded for the buffer, otherwise the working directory.
function M.workspace_dir()
  local client = vim.lsp.get_clients({ bufnr = 0, name = 'roslyn' })[1]
  return client and client.config.root_dir or vim.fn.getcwd()
end

-- Whether a project starts a program, for this session, as MSBuild takes about a second per project.
local executable_cache = {}

-- Projects below `dir` with Exe or WinExe output, test projects left out. MSBuild evaluates them, so
-- OutputType from Directory.Build.props or the SDK counts.
function M.executable_projects(dir, on_done)
  -- Always later, also when every project is cached, so a coroutine can yield for the result.
  on_done = vim.schedule_wrap(on_done)
  local projects = find_projects(dir)
  if #projects == 0 then
    on_done({})
    return
  end
  local next_index = 1
  local running = 0
  local done = false
  local function evaluate()
    if next_index > #projects then
      if running == 0 and done == false then
        done = true
        on_done(vim.tbl_filter(function(project)
          return executable_cache[project]
        end, projects))
      end
      return
    end
    local project = projects[next_index]
    next_index = next_index + 1
    if executable_cache[project] ~= nil then
      return evaluate()
    end
    running = running + 1
    local command = { 'dotnet', 'msbuild', project, '-nologo', '-getProperty:OutputType', '-getProperty:IsTestProject' }
    vim.system(
      command,
      { text = true },
      vim.schedule_wrap(function(result)
        running = running - 1
        local ok, output = pcall(vim.json.decode, result.stdout)
        local properties = ok and output.Properties or {}
        local starts_program = properties.OutputType == 'Exe' or properties.OutputType == 'WinExe'
        executable_cache[project] = starts_program and properties.IsTestProject ~= 'true'
        evaluate()
      end)
    )
  end
  for _ = 1, math.min(4, #projects) do
    evaluate()
  end
end

-- The assembly a project builds, e.g. `bin/Debug/net9.0/App.dll`.
function M.target_path(project, on_done)
  local command = { 'dotnet', 'msbuild', project, '-nologo', '-getProperty:TargetPath' }
  vim.system(
    command,
    { text = true },
    vim.schedule_wrap(function(result)
      local path = vim.trim(result.stdout or '')
      if result.code ~= 0 or path == '' then
        vim.notify(
          string.format('Could not resolve TargetPath of %s:\n%s', vim.fs.basename(project), result.stderr),
          vim.log.levels.ERROR
        )
        on_done(nil)
        return
      end
      on_done(path)
    end)
  )
end

-- Builds like Rider: progress through notifications, the errors of a failed build in the quickfix list.
-- Command and error format come from Neovim's `compiler/dotnet.vim`, which also makes `:make` work in the buffer.
vim.g.dotnet_errors_only = true
function M.build(target, on_done)
  vim.cmd.compiler('dotnet')
  local command = vim.list_extend(vim.split(vim.bo.makeprg, ' '), { target })
  local efm = vim.bo.errorformat
  local name = vim.fs.basename(target)
  vim.notify(string.format('Building %s...', name))
  vim.system(
    command,
    { text = true },
    vim.schedule_wrap(function(result)
      if result.code == 0 then
        vim.notify(string.format('Build succeeded: %s', name))
      else
        vim.fn.setqflist({}, ' ', {
          title = 'Build',
          lines = vim.split(result.stdout, '\n', { trimempty = true }),
          efm = efm,
        })
        vim.cmd.copen()
        vim.notify(string.format('Build failed: %s', name), vim.log.levels.ERROR)
      end
      if on_done ~= nil then
        on_done(result.code == 0)
      end
    end)
  )
end

-- Builds the solution Roslyn loaded for the buffer, or the buffer's project when there is none. Not the last
-- selected solution, which belongs to whichever buffer started a Roslyn client last.
function M.build_current()
  local client = vim.lsp.get_clients({ bufnr = 0, name = 'roslyn' })[1]
  local solution = client and require('roslyn.store').get(client.id)
  local target = solution or M.nearest_project(vim.fn.expand('%:p:h'))
  if target == nil then
    vim.notify('No solution or project found for this buffer', vim.log.levels.WARN)
    return
  end
  M.build(target)
end

function M.build_project()
  local project = M.nearest_project(vim.fn.expand('%:p:h'))
  if project == nil then
    vim.notify('No project found for this buffer', vim.log.levels.WARN)
    return
  end
  M.build(project)
end

-- Picks one of the workspace's executable projects and runs it with `dotnet run` in a terminal split.
function M.run_project()
  vim.notify('Finding executable projects...')
  M.executable_projects(M.workspace_dir(), function(projects)
    if #projects == 0 then
      vim.notify('No executable project found', vim.log.levels.WARN)
      return
    end
    vim.ui.select(projects, { prompt = 'Run project:', format_item = vim.fs.basename }, function(project)
      if project == nil then
        return
      end
      vim.cmd('botright new')
      vim.fn.jobstart({ 'dotnet', 'run', '--project', project }, { term = true, cwd = vim.fs.dirname(project) })
    end)
  end)
end

return M
