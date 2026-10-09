return {
  'rcarriga/nvim-dap-ui',
  dependencies = {
    { 'mfussenegger/nvim-dap' },
    { 'nvim-neotest/nvim-nio' },
    { 'mason-org/mason.nvim' }, -- The C# adapter path uses $MASON.
    { 'theHamsta/nvim-dap-virtual-text', opts = { virt_text_pos = 'eol' } }, -- Values at the end of the line, like Rider.
  },
  -- The mappings below and nvim-dap's commands load the debugger on first use.
  keys = { '<F5>', '<Leader>bp' },
  cmd = {
    'DapContinue', 'DapToggleBreakpoint', 'DapClearBreakpoints', 'DapStepOver', 'DapStepInto', 'DapStepOut',
    'DapPause', 'DapTerminate', 'DapDisconnect', 'DapRestartFrame', 'DapNew', 'DapEval', 'DapToggleRepl',
    'DapSetLogLevel', 'DapShowLog',
  },
  config = function()
    local dap, dap_ui = require('dap'), require('dapui')

    vim.keymap.set('n', '<F5>', dap.continue)
    vim.keymap.set('n', '<Leader>bp', dap.toggle_breakpoint)

    -- Rider's debugger keys only exist while a session runs, so they keep their normal meaning otherwise.
    local session_keys = {
      { 'n', '<F10>', dap.step_over },
      { 'n', '<F11>', dap.step_into },
      { 'n', '<S-F11>', dap.step_out },
      { 'n', '<C-F10>', dap.run_to_cursor },
      { 'n', '<C-S-F5>', dap.restart },
      -- Like Rider, stop terminates a launched program but only detaches from an attached process.
      { 'n', '<S-F5>', function()
        local session = dap.session()
        if session == nil then
          return
        end
        dap.disconnect({ terminateDebuggee = session.config.request == 'launch' })
      end },
      { { 'n', 'x' }, '<C-q>', function() dap_ui.eval() end },
    }
    dap.listeners.on_session.session_keys = function(_, new_session)
      for _, key in ipairs(session_keys) do
        if new_session then
          vim.keymap.set(key[1], key[2], key[3])
        else
          pcall(vim.keymap.del, key[1], key[2])
        end
      end
    end

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
