local M = {}

local state = require 'workspace.state'
local builders = require 'workspace.builders'

-- Initialize the workspace system
function M.setup()
  state.initialize()

  -- Load all layout definitions to register builders
  require 'workspace.layouts.main'
  require 'workspace.layouts.terminal'
  require 'workspace.layouts.diff_view'

  -- Set up commands
  require 'workspace.commands'

  -- Setup is complete
end

-- Main API functions (moved from navigation to avoid circular dependency)
function M.go_to(tab_name, window_name, buffer_name)
  return require('workspace.navigation').go_to(tab_name, window_name, buffer_name)
end

function M.open(name, type_hint)
  return require('workspace.navigation').open(name, type_hint)
end

function M.close(name, type_hint)
  return require('workspace.navigation').close(name, type_hint)
end

function M.toggle(name, type_hint)
  return require('workspace.navigation').toggle(name, type_hint)
end

function M.list(type_filter)
  return require('workspace.navigation').list(type_filter)
end

-- Get current workspace info
function M.current()
  return {
    tab = state.get_active_tab(),
    state = state.get_state(),
  }
end

-- Auto-setup when module is loaded
M.setup()

return M
