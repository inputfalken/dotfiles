-- Biome when the project has a biome.json, otherwise Prettier.
local web = { 'biome', 'prettier', stop_after_first = true }

return {
  'stevearc/conform.nvim',
  event = 'BufWritePre',
  cmd = 'ConformInfo',
  keys = {
    {
      '<Leader>rc',
      function()
        require('conform').format()
      end,
      desc = 'Reformat code',
    },
  },
  opts = {
    -- Language servers such as Roslyn can take longer than the default 1 second on large files.
    default_format_opts = { lsp_format = 'fallback', timeout_ms = 5000 },
    format_on_save = true,
    -- Filetypes without a formatter here, e.g. C#, PowerShell, SQL, JSON, YAML and XML, are formatted by their language server.
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = web,
      javascriptreact = web,
      typescript = web,
      typescriptreact = web,
      css = web,
    },
    formatters = {
      biome = { require_cwd = true, append_args = { '--use-editorconfig=true' } },
    },
  },
}
