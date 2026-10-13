-- Rider's Search Everywhere (double Shift): types, files, symbols and text matches in one list,
-- grouped in that order like Rider's "All" tab. An empty prompt lists recent files.
local channel = require('plenary.async.control').channel
local pickers = require('telescope.pickers')
local finders = require('telescope.finders')
local sorters = require('telescope.sorters')
local entry_display = require('telescope.pickers.entry_display')
local conf = require('telescope.config').values
local devicons = require('nvim-web-devicons')
local kind_icons = require('blink.cmp.config').appearance.kind_icons

local M = {}

local limits = { files = 20, symbols = 30, text = 50 }

-- Text matches need a few characters, otherwise rg floods the list with noise.
local min_text_query_length = 3

local type_kinds = { Class = true, Interface = true, Struct = true, Enum = true }

local displayer = entry_display.create({
  separator = ' ',
  items = { { width = 1 }, { width = 10 }, { remaining = true } },
})

local function kind_icon(item)
  if item.kind == 'File' or item.kind == 'Recent' then
    return devicons.get_icon(vim.fs.basename(item.filename), nil, { default = true })
  end
  return kind_icons[item.kind] or ' ', 'BlinkCmpKind' .. item.kind
end

local function make_entry(item)
  local location = item.lnum ~= nil and string.format('%s:%d', item.filename, item.lnum) or item.filename
  local detail = item.text ~= nil and string.format('%s  %s', item.text, location) or location
  return {
    value = item,
    ordinal = detail,
    filename = item.filename,
    lnum = item.lnum,
    col = item.col,
    display = function()
      local icon, icon_hl = kind_icon(item)
      return displayer({ { icon, icon_hl }, { item.kind, 'TelescopeResultsIdentifier' }, detail })
    end,
  }
end

local function recent_files(cwd)
  return vim
    .iter(vim.v.oldfiles)
    :map(vim.fs.normalize)
    :filter(function(path)
      return vim.startswith(path, cwd .. '/') and vim.uv.fs_stat(path) ~= nil
    end)
    :map(function(path)
      return { kind = 'Recent', filename = vim.fn.fnamemodify(path, ':.') }
    end)
    :take(limits.files)
    :totable()
end

-- Cancels the previous request, since only the latest prompt's results are shown.
local function symbol_searcher(bufnr)
  local cancel = function() end
  return function(prompt, on_done)
    cancel()
    if #vim.lsp.get_clients({ bufnr = bufnr, method = 'workspace/symbol' }) == 0 then
      on_done({})
      return
    end
    cancel = vim.lsp.buf_request_all(bufnr, 'workspace/symbol', { query = prompt }, function(results)
      local items = {}
      for client_id, response in pairs(results) do
        local client = vim.lsp.get_client_by_id(client_id)
        if response.result ~= nil and client ~= nil then
          vim.list_extend(items, vim.lsp.util.symbols_to_items(response.result, bufnr, client.offset_encoding))
        end
      end
      on_done(vim
        .iter(items)
        :map(function(item)
          return {
            kind = item.kind,
            text = item.text:gsub('^%[.-%]%s*', ''),
            filename = vim.fn.fnamemodify(item.filename, ':.'),
            lnum = item.lnum,
            col = item.col - 1,
          }
        end)
        :take(limits.symbols)
        :totable())
    end)
  end
end

-- Streams rg output and stops it at the limit, so short queries in large repositories stay fast.
local function text_searcher()
  local process
  return function(prompt, on_done)
    if process ~= nil then
      process:kill('sigterm')
    end
    if #prompt < min_text_query_length then
      on_done({})
      return
    end
    local items = {}
    local pending = ''
    local command = { 'rg', '--vimgrep', '--smart-case', '--fixed-strings', '--max-columns=200', '--', prompt }
    local current
    current = vim.system(
      command,
      {
        text = true,
        stdout = function(_, data)
          if data == nil or #items >= limits.text then
            return
          end
          local lines = vim.split(pending .. data, '\n')
          pending = table.remove(lines)
          for _, line in ipairs(lines) do
            local filename, lnum, col, text = line:match('^(.-):(%d+):(%d+):(.*)$')
            if filename ~= nil then
              table.insert(items, {
                kind = 'Text',
                text = vim.trim(text),
                filename = filename,
                lnum = tonumber(lnum),
                col = tonumber(col) - 1,
              })
            end
            if #items >= limits.text then
              current:kill('sigterm')
              return
            end
          end
        end,
      },
      vim.schedule_wrap(function()
        on_done(items)
      end)
    )
    process = current
  end
end

function M.open(opts)
  opts = opts or {}
  local bufnr = vim.api.nvim_get_current_buf()
  local cwd = vim.fs.normalize(vim.uv.cwd())
  -- Listed in the background, so the picker opens without waiting for rg.
  local files_job = vim.system({ 'rg', '--files' }, { text = true })
  local files
  local search_symbols = symbol_searcher(bufnr)
  local search_text = text_searcher()

  local function search(prompt)
    if prompt == '' then
      return recent_files(cwd)
    end

    files = files or vim.split(files_job:wait().stdout or '', '\n', { trimempty = true })
    local symbols_tx, symbols_rx = channel.oneshot()
    local text_tx, text_rx = channel.oneshot()
    search_symbols(prompt, symbols_tx)
    search_text(prompt, text_tx)

    local file_items = vim.tbl_map(function(path)
      return { kind = 'File', filename = path }
    end, vim.fn.matchfuzzy(files, prompt, { limit = limits.files }))
    local symbols = symbols_rx()
    local text = text_rx()

    local types = vim.tbl_filter(function(item)
      return type_kinds[item.kind]
    end, symbols)
    local members = vim.tbl_filter(function(item)
      return type_kinds[item.kind] == nil
    end, symbols)
    return vim.iter({ types, file_items, members, text }):flatten():totable()
  end

  pickers
    .new(opts, {
      prompt_title = 'Search Everywhere',
      debounce = 100,
      finder = finders.new_dynamic({ fn = search, entry_maker = make_entry }),
      sorter = sorters.highlighter_only(opts),
      previewer = conf.grep_previewer(opts),
    })
    :find()
end

return M
