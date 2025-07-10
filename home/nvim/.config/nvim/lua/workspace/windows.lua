local M = {}

local state = require 'workspace.state'
local config = require 'workspace.config'
local tabs = require 'workspace.tabs'

function M.initialize()
  if not state.get().windows['code'] then
    -- local code_win = vim.api.nvim_get_current_win()
    -- state.set_window('code', code_win)
    vim.api.nvim_set_current_win(1000)
    local win = Snacks.win.new {
      position = 'current',
      buf = vim.api.nvim_get_current_buf(),
      fixbuf = false,
    }
    -- local win = Snacks.win.new {
    --   height = 0,
    --   width = 0,
    --   show = true,
    --   enter = true,
    -- }
    state.set_window('code', win)
  end
end

function M.open_window(window_name)
  -- Directly open window if it exists
  local win = state.get().windows[window_name]
  if win then
    win:show()
    win:focus()
    return
  end

  local win_config = config.win_tab_map[window_name]

  -- Identify the tab configured for this window
  local tab_name = win_config.tab_name
  if not tab_name then
    error('No tab mapping found for window: ' .. window_name)
  end
  tabs.open_tab(tab_name)

  if win_config.win_args == nil then
    -- This is the initial window for the tabpage
    -- We wrap it in a Snacks window without creating a new window
    win = Snacks.win.new {
      position = 'current',
      buf = vim.api.nvim_get_current_buf(),
    }
  else
    win = Snacks.win.new(vim.tbl_deep_extend('force', win_config.win_args, {
      show = true,
    }))
  end
  state.set_window(window_name, win)
end

return M
