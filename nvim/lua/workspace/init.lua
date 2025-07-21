local M = {}

_G.W = M

local state = require 'workspace.state'
local tabs = require 'workspace.tabs'
local windows = require 'workspace.windows'
local buffers = require 'workspace.buffers'
local utils = require 'workspace.utils'
require 'workspace.highlight_groups'

function M.setup()
  state.initialize()
  tabs.initialize()
  windows.initialize()

  vim.keymap.set({ 'n', 't', 'v' }, '<C-M-j>', function()
    windows.open_window 'code'
  end, { desc = 'Open code window' })
  vim.keymap.set({ 'n', 't', 'v' }, '<C-M-k>', function()
    buffers.open_buffer 'claude_code'
  end, { desc = 'Open tools window' })
  vim.keymap.set({ 'n', 't', 'v' }, '<C-M-i>', function()
    buffers.open_buffer 'ipython'
  end, { desc = 'Open tools window' })
  vim.keymap.set({ 'n', 't', 'v' }, '<C-M-l>', function()
    windows.open_window 'primary_terminal'
  end, { desc = 'Open terminal window' })
  vim.keymap.set({ 'n', 't', 'v' }, '<C-M-;>', function()
    windows.open_window 'runner'
  end, { desc = 'Open server window' })

  vim.api.nvim_create_user_command('WorkspaceReloadCodeBuffer', function(input)
    utils.reload_code_buffer_if_updated(input.args)
  end, {
    desc = 'Reload code buffer if it has been updated',
    nargs = 1,
  })
end

function M.default_workspace()
  Snacks.explorer.open()
  -- Delay this to allow the explorer to open first
  vim.defer_fn(function()
    windows.open_window 'code'
  end, 50)
end

function M.debug()
  print(vim.inspect(state.get()))
end

M.setup()

-- vim.api.nvim_create_autocmd({ 'WinNew', 'WinClosed' }, {
--   callback = function(ev)
--     print(string.format('Event fired: %s', vim.inspect(ev)))
--     local info = debug.getinfo(2, 'S')
--     print(string.format('Info: %s', vim.inspect(info)))
--   end,
-- })

M.tabs = tabs
M.windows = windows
M.buffers = buffers

return M
