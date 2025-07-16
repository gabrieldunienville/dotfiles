local M = {}

local state = require 'workspace.state'
local config = require 'workspace.config'
local windows = require 'workspace.windows'

function M.initialize() end

function M.open_buffer(buf_name)
  local buf_config = config.get_buf_config(buf_name)
  local window_name = buf_config.win_name
  windows.open_window(window_name)

  local buf_id = state.get_buffer(buf_name, window_name)

  if not buf_id then
    -- Create a new buffer and run launch function if it exists
    if buf_config.launch then
      buf_config.launch()
    end
    buf_id = vim.api.nvim_get_current_buf()
    state.set_buffer(buf_name, window_name, buf_id)
  elseif buf_id ~= vim.api.nvim_get_current_buf() then
    -- If the buffer is already open in this window, switch to it
    vim.api.nvim_set_current_buf(buf_id)
  end
end

function M.paste_to_buffer(win_name, buf_name, text)
  local buf_id = state.get_buffer(buf_name, win_name)
  local job_id = vim.api.nvim_buf_get_var(buf_id, 'terminal_job_id')
  if not job_id or job_id == 0 then
    print(string.format('No terminal job found for buffer %s', buf_name))
    return
  end
  vim.fn.chansend(job_id, text .. '\n')
end


return M
