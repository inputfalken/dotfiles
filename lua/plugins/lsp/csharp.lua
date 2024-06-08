return {
  setup = function(lsp, coq)
    local omnisharp_extended = require('omnisharp_extended');
    lsp.omnisharp.setup(coq.lsp_ensure_capabilities({
      settings = {
        RoslynExtensionsOptions = {
          enableDecompilationSupport = true
        },
        FormattingOptions       = {
          enableEditorConfigSupport = true
        }
      },
      handlers = {
        ['textDocument/definition'] = omnisharp_extended.definition_handler,
        ['textDocument/typeDefinition'] = omnisharp_extended.type_definition_handler,
        ['textDocument/references'] = omnisharp_extended.references_handler,
        ['textDocument/implementation'] = omnisharp_extended.implementation_handler,
      }
    }))
  end
}
