local function warning(message)
  return string.format('⚠️  %s', message)
end

local function validate_filepath(filePath)
  local type = type(filePath);
  if (type ~= 'string') then
    error(string.format(warning([[Expected 'string' but got '%s']]), type))
  end
  if (filePath == nil or filePath == '') then
    error(warning('Filepath was either nil or empty string.'))
  end
end

local home = vim.uv.os_homedir()
if (home == nil or home == '') then
  error(warning('Could not detect $HOME path.'))
end

return {
  dap_adapaters = {
    csharp = 'netcoredbg'
  },
  get_file = function(filePath)
    validate_filepath(filePath)
    return vim.fn.fnamemodify(filePath, ':t:r')
  end,
  get_directory = function(filePath)
    validate_filepath(filePath)
    return vim.fn.fnamemodify(filePath, ':p:h')
  end,
  HOME_PATH = home,
  print_warning = function(message)
    vim.print(warning(message))
  end,
  map = function(table, fn)
    local result = {}
    for i, value in ipairs(table) do
      result[i] = fn(i, value)
    end
    return result
  end,
  trim = function(str)
    local type = type(str);
    if (type ~= 'string') then
      error(string.format('Invalid type \'%s\', expected \'string\'', type))
    end
    return str:match('^%s*(.-)%s*$')
  end
}
