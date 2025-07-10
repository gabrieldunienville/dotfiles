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

function M.set_window(name, value)
  state.windows[name] = value
  -- vim.g.workspace_state = state
end

function M.initialize()
  -- if not state.initialized then
  --   state.initialized = true
  --   -- vim.g.workspace_state = state
  -- end
end

return M
