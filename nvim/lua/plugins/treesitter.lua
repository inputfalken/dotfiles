local parsers = {
  'lua',
  'vimdoc',
  'c_sharp',
  'powershell',
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
  'nvim-treesitter/nvim-treesitter',
  branch = 'main',
  lazy = false,
  build = ':TSUpdate',
  config = function()
    local nts = require('nvim-treesitter')

    -- Building several large grammars (e.g. c_sharp) in parallel exhausts the compiler's memory with MSVC.
    nts.install(parsers, { max_jobs = 2 })

    -- Parser names don't always match filetypes, e.g. 'c_sharp' is 'cs'.
    local filetypes = {}
    for _, parser in ipairs(parsers) do
      vim.list_extend(filetypes, vim.treesitter.language.get_filetypes(parser))
    end

    vim.api.nvim_create_autocmd('FileType', {
      pattern = filetypes,
      callback = function(args)
        local ok = pcall(vim.treesitter.start, args.buf)
        if ok then
          vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
        end
      end,
    })
  end
}
