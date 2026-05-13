return {
  setup = function(opts)
    vim.lsp.config('powershell_es', opts.coq.lsp_ensure_capabilities(
      {
        settings = { powershell = { codeFormatting = { Preset = 'OTBS' } } }
      }
    ))
    vim.lsp.enable('powershell_es')
  end
}
