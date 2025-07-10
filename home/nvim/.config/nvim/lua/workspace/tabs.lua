local M = {}

local state = require 'workspace.state'
local config = require 'workspace.config'

function M.initialize()
  local tabs = state.get().tabs
  -- Capture initial tab as 'main'
  if not tabs['main'] then
    local main_tab = vim.api.nvim_get_current_tabpage()
    state.set_tab('main', main_tab)
  end
end

function M.open_tab(tab_name)
  local tabs = state.get().tabs
  local tab_id = tabs[tab_name]
  if tab_id and vim.api.nvim_tabpage_is_valid(tab_id) then
    vim.api.nvim_set_current_tabpage(tab_id)
    return true
  end

  -- Create a new tab
  vim.cmd 'tabnew'
  tab_id = vim.api.nvim_get_current_tabpage()
  tabs[tab_name] = tab_id
  vim.api.nvim_set_current_tabpage(tab_id)
  vim.api.nvim_tabpage_set_var(tab_id, 'tab_name', tab_name)

  local buf_id = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf_id)
  -- vim.api.nvim_buf_set_name(buf_id, name)

  -- vim.g.my_tabs = tabs
  state.set_tab(tab_name, tab_id)

  -- Note: could be autocommand for better decoupling
  local primary_win = config.primary_win_by_tab[tab_name]
  if primary_win then
    local win_id = vim.api.nvim_get_current_win()
    state.set_window(primary_win, win_id)
  end
end

function M.close_tab(name)
  local tabs = state.get().tabs
  local tab_id = tabs[name]
  if not tab_id or not vim.api.nvim_tabpage_is_valid(tab_id) then
    return false
  end

  local current_tab = vim.api.nvim_get_current_tabpage()
  if current_tab ~= tab_id then
    vim.api.nvim_set_current_tabpage(tab_id)
  end
  vim.cmd 'tabclose'
  state.set_tab(name, nil)
end

-- _G.W = M

-- M.initialize()
-- M.open_tab 'test'
-- print(vim.api.nvim_tabpage_get_win(

return M
