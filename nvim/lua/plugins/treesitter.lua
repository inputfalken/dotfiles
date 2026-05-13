local parsers = {
  'lua',
  'vimdoc',
  'c_sharp',
  'json',
  'xml',
  'javascript',
  'typescript',
  'css',
  'csv',
  'gitcommit',
  'markdown',
  'markdown_inline',
  'sql',
  'yaml'
}

return {
  setup = function()
    local nts = require('nvim-treesitter')

    nts.install(parsers)

    vim.api.nvim_create_autocmd('FileType', {
      pattern = parsers,
      callback = function(args)
        local ok = pcall(vim.treesitter.start, args.buf)
        if ok then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end
}
