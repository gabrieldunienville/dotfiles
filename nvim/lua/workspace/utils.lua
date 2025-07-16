local M = {}

local windows = require 'workspace.windows'
local state = require 'workspace.state'

function M.reload_code_buffer_if_updated(file_path)
  -- Get file path of buffer open in code window
  local win = state.get_window 'code'
  if not win then
    print 'No code window found'
    return
  end

  print('Input file path:', file_path)

  local buf_file_path = vim.api.nvim_buf_get_name(win.buf)
  print('Buffer file path:', buf_file_path)

  if buf_file_path ~= file_path then
    print('Buffer not open, not reloading')
    return
  end

  print('Reloading code buffer:', buf_file_path)
  require('utils').safe_reload_buffer(win.buf)
end

M.reload_code_buffer_if_updated 'init.lua'

return M
