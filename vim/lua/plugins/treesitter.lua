require 'nvim-treesitter.install'.prefer_git = false
require 'nvim-treesitter.configs'.setup {
  -- Current solution to solve this is to install 'Visual Studio Build Tools' and compile these parsers with the correct arcitecture for the system.
  -- See https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support
  ensure_installed = {  "lua",  "vimdoc", 'c_sharp', 'javascript', 'tsx', 'typescript' },
  highlight = {
    enable = true
  }
}
