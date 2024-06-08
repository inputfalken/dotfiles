return {
  setup = function(opts)
    opts.lsp.tsserver.setup(opts.coq.lsp_ensure_capabilities());
  end
}
