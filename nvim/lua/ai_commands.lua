local function paste_to_claude(text)
  local state = require 'workspace.state'
  local target_buf = state.get_active_buffer 'tools' or 'claude_code'
  require('workspace.buffers').paste_to_buffer('tools', target_buf, text)
end

local function feed_newline()
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
end

vim.keymap.set('v', '<leader>av', function()
  local text = require('context').get_selection_context()
  paste_to_claude(text)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
  -- W.buffers.open_buffer 'claude_code'
end, { desc = 'Paste visual selection to claude' })

vim.keymap.set('n', '<leader>ab', function()
  local text = require('context').get_file_context()
  paste_to_claude(text)
  feed_newline()
  -- W.buffers.open_buffer 'claude_code'
end, { desc = 'Paste buffer file context to claude' })

vim.keymap.set('n', '<leader>ad', function()
  local text = require('diagnostics').get_diagnostic_under_cursor()
  paste_to_claude(text)
  feed_newline()
  -- W.buffers.open_buffer 'claude_code'
end, { desc = 'Paste diagnostics to claude' })

-- vim.keymap.set('n', '<leader>ac', function()
--   paste_to_claude('/clear')
-- end, { desc = 'Clear claude code' })
