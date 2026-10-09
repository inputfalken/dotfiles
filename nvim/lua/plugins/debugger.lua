return {
  setup = function(dap, dap_ui)
    vim.keymap.set('n', '<F5>', dap.continue)
    vim.keymap.set('n', '<F10>', dap.step_over)
    vim.keymap.set('n', '<F11>', dap.step_into)
    vim.keymap.set('n', '<S-F11>', dap.step_out)
    vim.keymap.set('n', '<Leader>bp', dap.toggle_breakpoint)
    vim.keymap.set('n', '<S-F5>', function() dap.disconnect({ terminateDebuggee = true }) end)

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

    require('plugins.debugger.csharp').setup(dap)
  end
}
