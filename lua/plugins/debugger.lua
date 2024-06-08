return {
  setup = function(dap_ui, dap, mason_registry)
    vim.keymap.set('n', '<F5>', function() require('dap').continue() end)
    vim.keymap.set('n', '<F10>', function() require('dap').step_over() end)
    vim.keymap.set('n', '<F11>', function() require('dap').step_into() end)
    vim.keymap.set('n', '<S-F11>', function() require('dap').step_out() end)
    vim.keymap.set('n', '<Leader>bp', function() dap.toggle_breakpoint() end);
    vim.keymap.set('n', '<S-F5>', function() dap.disconnect({ terminateDebuggee = true }) end);

    dap_ui.setup()
    dap.listeners.before.attach.dapui_config = function()
      dap_ui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dap_ui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dap_ui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dap_ui.close()
    end

    local a = mason_registry
          .get_package('netcoredbg')
          :get_install_path() .. '\\netcoredbg\\netcoredbg.exe'
    require('plugins.debugger.csharp').setup(dap, mason_registry);
  end
}
