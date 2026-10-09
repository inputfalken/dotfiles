return {
  settings = {
    ['csharp|background_analysis'] = {
      -- Analyzers only run on open files; compiler errors cover the whole solution for `<Leader>fd`.
      dotnet_analyzer_diagnostics_scope = 'openFiles',
      dotnet_compiler_diagnostics_scope = 'fullSolution',
    },
    ['csharp|code_lens'] = {
      dotnet_enable_references_code_lens = true,
    },
    -- Kept from nvim-lspconfig's roslyn_ls defaults, which this config used before roslyn.nvim.
    ['csharp|completion'] = {
      dotnet_show_name_completion_suggestions = true,
      dotnet_show_completion_items_from_unimported_namespaces = true,
      dotnet_provide_regex_completions = true,
    },
    ['csharp|symbol_search'] = {
      dotnet_search_reference_assemblies = true,
    },
    ['csharp|navigation'] = {
      -- Go to definition into referenced assemblies shows decompiled source.
      dotnet_navigate_to_decompiled_sources = true
    }
  }
}
