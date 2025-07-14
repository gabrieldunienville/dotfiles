local M = {}

local state = require 'workspace.state'
local config = require 'workspace.config'
local tabs = require 'workspace.tabs'

function M.initialize()
  if not state.get().windows['code'] then
    vim.api.nvim_set_current_win(1000)
    local win = Snacks.win.new {
      position = 'current',
      buf = vim.api.nvim_get_current_buf(),
      fixbuf = false,
      minimal = false,
    }
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

  local win_config = config.get_win_config(window_name)

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
      on_win = function()
        if win_config.launch() then
          win_config.launch()
        end
      end,
    }
  else
    win = Snacks.win.new(vim.tbl_deep_extend('force', win_config.win_args, {
      show = true,
      fixbuf = false,
      on_win = function()
        if win_config.launch then
          win_config.launch()
        end
      end,
    }))
  end

  state.set_window(window_name, win)
end

return M
