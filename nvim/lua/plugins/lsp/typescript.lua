return {
  setup = function(opts)
    opts.lsp.ts_ls.setup(opts.coq.lsp_ensure_capabilities());
  end
}
