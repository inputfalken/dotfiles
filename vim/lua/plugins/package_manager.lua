local Plug = vim.fn['plug#']

vim.call('plug#begin')
-- Misc
Plug('sainnhe/gruvbox-material')
Plug('nvim-tree/nvim-tree.lua')
Plug('nvim-tree/nvim-web-devicons')
Plug('jdhao/better-escape.vim')
Plug('nvim-treesitter/nvim-treesitter', { ['do'] = ':TSUpdate' })

-- Search files
Plug('junegunn/fzf', {
  ['do'] = function()
    vim.fn['fzf#install']()
  end
})
Plug('junegunn/fzf.vim')

-- Auto complete/intellisense
Plug('ms-jpq/coq_nvim', { ['branch'] = 'coq' })
Plug('ms-jpq/coq.artifacts', { ['branch'] = 'artifacts' })

-- LSP
Plug('Hoffs/omnisharp-extended-lsp.nvim')
Plug('williamboman/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')
Plug('neovim/nvim-lspconfig')

-- Debugger
Plug('mfussenegger/nvim-dap')
Plug('nvim-neotest/nvim-nio')
Plug('rcarriga/nvim-dap-ui', { ['commit'] = '5934302d63d1ede12c0b22b6f23518bb183fc972' }) -- Commit can be removed once they fix latest version.

Plug('mxsdev/nvim-dap-vscode-js',
  {
    ['dir'] = '~/',
    ['do'] = 'npm install --legacy-peer-deps && npx gulp vsDebugServerBundle && mv dist out'
  }
)
vim.call('plug#end')
