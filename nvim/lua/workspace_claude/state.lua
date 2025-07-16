local M = {}

-- Initialize global state with vim.g for persistence across reloads
vim.g.workspace_state = vim.g.workspace_state or {
  tabs = {},
  layouts = {},
  active_tab = nil,
  initialized = false,
}

local state = vim.g.workspace_state

-- Validate that a tab still exists
local function validate_tab(tab_id)
  if not tab_id then
    return false
  end
  return vim.api.nvim_tabpage_is_valid(tab_id)
end

-- Validate that a window still exists
local function validate_window(win_id)
  if not win_id then
    return false
  end
  return vim.api.nvim_win_is_valid(win_id)
end

-- Validate that a buffer still exists
local function validate_buffer(buf_id)
  if not buf_id then
    return false
  end
  return vim.api.nvim_buf_is_valid(buf_id)
end

-- Clean up invalid references in state
function M.cleanup_invalid_references()
  for tab_name, tab_data in pairs(state.tabs) do
    if not validate_tab(tab_data.tab_id) then
      state.tabs[tab_name] = nil
    end
  end

  for layout_name, layout_data in pairs(state.layouts) do
    if layout_data.layout and not layout_data.layout:valid() then
      state.layouts[layout_name] = nil
    end
  end

  -- Update vim.g to persist changes
  vim.g.workspace_state = state
end

-- Get current state
function M.get_state()
  return state
end

-- Set tab data
function M.set_tab(tab_name, tab_data)
  state.tabs[tab_name] = tab_data
  vim.g.workspace_state = state
end

-- Get tab data
function M.get_tab(tab_name)
  return state.tabs[tab_name]
end

-- Set layout data
function M.set_layout(layout_name, layout_data)
  state.layouts[layout_name] = layout_data
  vim.g.workspace_state = state
end

-- Get layout data
function M.get_layout(layout_name)
  return state.layouts[layout_name]
end

-- Set active tab
function M.set_active_tab(tab_name)
  state.active_tab = tab_name
  vim.g.workspace_state = state
end

-- Get active tab
function M.get_active_tab()
  return state.active_tab
end

-- Initialize state if not already done
function M.initialize()
  if not state.initialized then
    state.initialized = true
    vim.g.workspace_state = state

    -- Set up cleanup autocmd
    vim.api.nvim_create_autocmd('TabClosed', {
      callback = function()
        M.cleanup_invalid_references()
      end,
    })

    vim.api.nvim_create_autocmd('WinClosed', {
      callback = function()
        M.cleanup_invalid_references()
      end,
    })
  end
end

return M
