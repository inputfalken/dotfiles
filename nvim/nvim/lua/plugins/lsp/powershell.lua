return {
  setup = function(opts)
    opts.lsp.powershell_es.setup(opts.coq.lsp_ensure_capabilities(
      {
        settings = { powershell = { codeFormatting = { Preset = 'OTBS' } } }
      }
    ))
  end
}
