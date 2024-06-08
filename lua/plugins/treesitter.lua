return {
  setup = function(nvim_treesitter_install, nvim_treesitter_configs)
    nvim_treesitter_install.prefer_git = false;
    nvim_treesitter_configs.setup({
      -- Current solution to solve this is to install 'Visual Studio Build Tools' and compile these parsers with the correct arcitecture for the system.
      -- See https://github.com/nvim-treesitter/nvim-treesitter/wiki/Windows-support
      ensure_installed = { 'lua', 'vimdoc', 'c_sharp', 'javascript', 'tsx', 'typescript', 'json', 'yaml', 'xml' },
      highlight = {
        enable = true
      }
    })
  end
}
