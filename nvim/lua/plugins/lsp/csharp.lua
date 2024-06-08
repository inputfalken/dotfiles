return {
  setup = function(opts)
    opts.lsp.omnisharp.setup(opts.coq.lsp_ensure_capabilities({
      settings = {
        RoslynExtensionsOptions = {
          enableDecompilationSupport = true
        },
        FormattingOptions       = {
          enableEditorConfigSupport = true
        }
      },
      handlers = {
        ['textDocument/definition'] = opts.omnisharp_extended.definition_handler,
        ['textDocument/typeDefinition'] = opts.omnisharp_extended.type_definition_handler,
        ['textDocument/references'] = opts.omnisharp_extended.references_handler,
        ['textDocument/implementation'] = opts.omnisharp_extended.implementation_handler,
      }
    }))
  end
}
