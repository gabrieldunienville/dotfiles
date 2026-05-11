local M = {}

-- Initialize global state with vim.g for persistence across reloads
-- vim.g.workspace_state = vim.g.workspace_state or {
--   initialized = false,
--   tabs = {},
--   windows = {},
-- }
-- local state = vim.g.workspace_state

-- vim.g.workspace_initialized = vim.g.workspace_state.initialized or false

local state = {
  tabs = {},
  windows = {},
  buffers = {},
  active_buffers = {},
  compose = {},
}

-- function M.reload()
--   if not vim.g.workspace_initialized
-- end

function M.get()
  return state
end

function M.set_tab(name, value)
  state.tabs[name] = value
  -- vim.g.workspace_state = state
end

---@param name string
---@param win snacks.win
function M.set_window(name, win)
  state.windows[name] = win
  -- vim.g.workspace_state = state
end

---@param name string
---@return snacks.win|nil
function M.get_window(name)
  return state.windows[name]
end

function M.set_buffer(buf_name, win_name, buf_id)
  state.buffers[buf_name] = state.buffers[buf_name] or {}
  state.buffers[buf_name][win_name] = buf_id
end

---@param buf_name string
---@param win_name string
---@return number|nil
function M.get_buffer(buf_name, win_name)
  if state.buffers[buf_name] then
    return state.buffers[buf_name][win_name]
  end
  return nil
end

---@param win_name string
---@param buf_name string
function M.set_active_buffer(win_name, buf_name)
  state.active_buffers[win_name] = buf_name
end

---@param win_name string
---@return string|nil
function M.get_active_buffer(win_name)
  return state.active_buffers[win_name]
end

function M.get_compose(buf_name)
  return state.compose[buf_name]
end

function M.set_compose_buf(buf_name, buf_id)
  state.compose[buf_name] = state.compose[buf_name] or {}
  state.compose[buf_name].buf_id = buf_id
end

function M.set_compose_win(buf_name, win_id)
  state.compose[buf_name] = state.compose[buf_name] or {}
  state.compose[buf_name].win_id = win_id
end

function M.get_all_compose()
  return state.compose
end

function M.initialize()
  -- if not state.initialized then
  --   state.initialized = true
  --   -- vim.g.workspace_state = state
  -- end
end

return M
