local M = {}

local state = require 'workspace.state'

-- vim.g.my_tabs = vim.g.my_tabs or {}
-- local tabs = vim.g.my_tabs

function M.initialize()
  local tabs = state.get().tabs
  -- Capture initial tab as 'main'
  if not tabs['main'] then
    local main_tab = vim.api.nvim_get_current_tabpage()
    tabs['main'] = main_tab
  end
end

function M.open_tab(name)
  local tabs = state.get().tabs
  local tab_id = tabs[name]
  if tab_id and vim.api.nvim_tabpage_is_valid(tab_id) then
    vim.api.nvim_set_current_tabpage(tab_id)
    return true
  end

  -- Create a new tab
  vim.cmd 'tabnew'
  tab_id = vim.api.nvim_get_current_tabpage()
  tabs[name] = tab_id
  vim.api.nvim_set_current_tabpage(tab_id)
  vim.api.nvim_tabpage_set_var(tab_id, 'tab_name', name)

  local buf_id = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf_id)
  -- vim.api.nvim_buf_set_name(buf_id, name)

  -- vim.g.my_tabs = tabs
  state.set_tab(name, tab_id)
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

_G.W = M

-- M.initialize()
-- M.open_tab 'test'
-- print(vim.api.nvim_tabpage_get_win(

return M
