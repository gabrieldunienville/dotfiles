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
  -- print(string.format('Buffer ID for %s in %s: %s', buf_name, window_name, buf_id))
  -- print(string.format('Current buffer ID: %s', vim.api.nvim_get_current_buf()))

  -- vim.print({
  --   buf_name = buf_name,
  --   window_name = window_name,
  --   buf_id = buf_id,
  --   current_buf_id = vim.api.nvim_get_current_buf(),
  -- })

  if not buf_id then
    -- Create a new buffer and run launch function if it exists
    print(string.format('Creating new buffer for %s in %s', buf_name, window_name))
    if buf_config.launch then
      buf_config.launch()
    end
    buf_id = vim.api.nvim_get_current_buf()
    state.set_buffer(buf_name, window_name, buf_id)
  elseif buf_id ~= vim.api.nvim_get_current_buf() then
    -- If the buffer is already open in this window, switch to it
    print(string.format('Switching to existing buffer %s in %s', buf_name, window_name))
    print(string.format('Current buffer ID: %s', vim.api.nvim_get_current_buf()))
    print(string.format('Buffer ID: %s', buf_id))
    vim.api.nvim_set_current_buf(buf_id)
  end
end

return M
