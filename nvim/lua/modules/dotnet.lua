local function is_project(name)
  return name:match('%.[cf]sproj$') ~= nil
end

local M = {
  dap_adapter = 'netcoredbg'
}

-- Projects below `dir`, shallowest first.
function M.find_projects(dir)
  return vim.fs.find(is_project, { path = dir, type = 'file', limit = math.huge })
end

-- The project `dir` belongs to.
function M.nearest_project(dir)
  return vim.fs.find(is_project, { path = dir, type = 'file', upward = true })[1]
end

-- The assembly a project builds, e.g. `bin/Debug/net9.0/App.dll`.
function M.target_path(project)
  local result = vim.system({ 'dotnet', 'msbuild', project, '-nologo', '-getProperty:TargetPath' }, { text = true }):wait()
  local path = vim.trim(result.stdout or '')
  if result.code ~= 0 or path == '' then
    vim.notify(
      string.format('Could not resolve TargetPath of %s:\n%s', vim.fs.basename(project), result.stderr),
      vim.log.levels.ERROR
    )
    return
  end
  return path
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
  vim.system(command, { text = true }, vim.schedule_wrap(function(result)
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
  end))
end

-- Builds the solution Roslyn loaded, or the buffer's project when there is none.
function M.build_current()
  local target = vim.g.roslyn_nvim_selected_solution or M.nearest_project(vim.fn.expand('%:p:h'))
  if target == nil then
    vim.notify('No solution or project found for this buffer', vim.log.levels.WARN)
    return
  end
  M.build(target)
end

return M
