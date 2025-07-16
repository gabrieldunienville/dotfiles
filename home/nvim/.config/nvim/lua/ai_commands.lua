local function paste_to_claude(text)
  require('workspace.buffers').paste_to_buffer('tools', 'claude_code', text)
end

vim.keymap.set('v', '<leader>av', function()
  local text = require('context').get_selection_context()
  paste_to_claude(text)
end, { desc = 'Paste visual selection to claude' })

vim.keymap.set('n', '<leader>ad', function()
  local text = require('diagnostics').get_diagnostic_under_cursor()
  paste_to_claude(text)
end, { desc = 'Paste diagnostics to claude' })
