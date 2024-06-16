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
      }
    }))
  end
}
