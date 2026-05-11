local function append_to_compose(text)
  local state = require 'workspace.state'
  local target_buf = state.get_active_buffer 'tools' or 'claude_code'
  require('workspace.buffers').append_to_compose(target_buf, text)
end

vim.keymap.set('v', '<leader>av', function()
  local text = require('context').get_selection_context()
  append_to_compose(text)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
end, { desc = 'Append visual selection to claude compose' })

vim.keymap.set('n', '<leader>ab', function()
  local text = require('context').get_file_context()
  append_to_compose(text)
end, { desc = 'Append buffer file context to claude compose' })

vim.keymap.set('n', '<leader>ad', function()
  local text = require('diagnostics').get_diagnostic_under_cursor()
  append_to_compose(text)
end, { desc = 'Append diagnostics to claude compose' })
