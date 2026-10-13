-- Inlay hints are shown outside insert mode, see lsp.lua.
local inlay_hints = {
  parameterNames = { enabled = 'literals' },
  parameterTypes = { enabled = true },
  variableTypes = { enabled = true },
  propertyDeclarationTypes = { enabled = true },
  functionLikeReturnTypes = { enabled = true },
  enumMemberValues = { enabled = true },
}

return {
  settings = {
    typescript = { inlayHints = inlay_hints },
    javascript = { inlayHints = inlay_hints },
  },
}
