return {
  setup = function(lsp, coq)
    lsp.powershell_es.setup(coq.lsp_ensure_capabilities(
      {
        settings = { powershell = { codeFormatting = { Preset = 'OTBS' } } }
      }
    ))
  end
}
