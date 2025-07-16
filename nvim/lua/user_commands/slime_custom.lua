vim.api.nvim_create_user_command('GSlimeSend', function(opts)
  -- vim.cmd('SlimeSend1 print("' .. vim.api.nvim_get_current_line() .. '")')
  local python_command = 'relative_import("'..vim.fn.expand('%:p') .. '", "' .. vim.api.nvim_get_current_line() ..'")'
  vim.cmd('SlimeSend1 '..python_command)
end, {})
