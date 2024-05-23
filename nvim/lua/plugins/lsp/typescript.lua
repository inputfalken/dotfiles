return {
  setup = function(lsp, coq)
    lsp.tsserver.setup(coq.lsp_ensure_capabilities());
  end
}
