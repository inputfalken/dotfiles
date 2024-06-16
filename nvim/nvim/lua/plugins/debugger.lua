return {
  setup = function(opts)
    vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
    vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
    vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
    vim.keymap.set('n', '<S-F11>', function() require('dap').step_out() end)
    vim.keymap.set('n', '<Leader>bp', function() opts.dap.toggle_breakpoint() end);
    vim.keymap.set('n', '<S-F5>', function() opts.dap.disconnect({ terminateDebuggee = true }) end);

    opts.dap_ui.setup()
    opts.dap.listeners.before.attach.dapui_config = function()
      opts.dap_ui.open()
    end
    opts.dap.listeners.before.launch.dapui_config = function()
      opts.dap_ui.open()
    end
    opts.dap.listeners.before.event_terminated.dapui_config = function()
      opts.dap_ui.close()
    end
    opts.dap.listeners.before.event_exited.dapui_config = function()
      opts.dap_ui.close()
    end

    require('plugins.debugger.csharp').setup(opts.dap, opts.mason_registry);
  end
}
