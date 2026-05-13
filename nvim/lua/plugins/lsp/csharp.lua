return {
  setup = function(opts)
    vim.lsp.config('omnisharp', opts.coq.lsp_ensure_capabilities({
      settings = {
        RoslynExtensionsOptions = {
          enableDecompilationSupport = true
        },
        FormattingOptions       = {
          enableEditorConfigSupport = true
        }
      }
    }))
    vim.lsp.enable('omnisharp')
  end
}
