return {
  -- Code lens commands roslyn.nvim leaves to the editor, run with `<Leader>cl` on the lens' line.
  commands = {
    -- "Run Test" and "Debug Test" (or "All Tests" on a class) through neotest, like `<Leader>ten` and `<Leader>det`.
    ['dotnet.test.run'] = function(command)
      require('neotest').run.run({ strategy = command.arguments[1].attachDebugger and 'dap' or nil })
    end,
    -- "N references" lists the usages of the member it sits on, like `<Leader>fu`.
    ['roslyn.client.peekReferences'] = function(command)
      local position = command.arguments[2]
      vim.api.nvim_win_set_cursor(0, { position.line + 1, position.character })
      require('telescope.builtin').lsp_references({ include_declaration = false })
    end,
  },
  settings = {
    ['csharp|background_analysis'] = {
      -- Analyzers only run on open files; compiler errors cover the whole solution for `<Leader>fd`.
      dotnet_analyzer_diagnostics_scope = 'openFiles',
      dotnet_compiler_diagnostics_scope = 'fullSolution',
    },
    -- Inlay hints are shown outside insert mode, see lsp.lua. The switches turn on the server's defaults, like Rider:
    -- parameter names for literal arguments, and the types of var and lambda parameters.
    ['csharp|inlay_hints'] = {
      dotnet_enable_inlay_hints_for_parameters = true,
      csharp_enable_inlay_hints_for_types = true,
    },
    ['csharp|code_lens'] = {
      dotnet_enable_references_code_lens = true,
      dotnet_enable_tests_code_lens = true,
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
      dotnet_navigate_to_decompiled_sources = true,
    },
  },
}
