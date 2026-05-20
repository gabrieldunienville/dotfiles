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

  -- Main code
  vim.keymap.set({ 'n', 't', 'v', 'i' }, '<C-M-j>', function()
    vim.cmd 'stopinsert'
    windows.open_window 'code'
  end, { desc = 'Open code window' })
  -- Claude code
  vim.keymap.set({ 'n', 't', 'v', 'i' }, '<C-M-k>', function()
    buffers.open_buffer 'claude_code'
  end, { desc = 'Open claude code' })
  vim.keymap.set({ 'n', 't', 'v', 'i' }, '<C-M-d>k', function()
    buffers.hide_buffer 'claude_code'
  end, { desc = 'Hide claude code' })
  -- Claude code - secondary
  vim.keymap.set({ 'n', 't', 'v', 'i' }, '<C-M-,>', function()
    buffers.open_buffer 'claude_code_secondary'
  end, { desc = 'Open claude code' })
  vim.keymap.set({ 'n', 't', 'v', 'i' }, '<C-M-d>,', function()
    buffers.hide_buffer 'claude_code_secondary'
  end, { desc = 'Hide claude code' })
  -- Testing
  vim.keymap.set({ 'n', 't', 'v', 'i' }, '<C-M-o>', function()
    buffers.open_buffer 'testing'
  end, { desc = 'Open testing' })
  vim.keymap.set({ 'n', 't', 'v', 'i' }, '<C-M-d>o', function()
    buffers.hide_buffer 'testing'
  end, { desc = 'Hide testing' })
  -- IPython
  vim.keymap.set({ 'n', 't', 'v', 'i' }, '<C-M-u>', function()
    buffers.open_buffer 'ipython'
  end, { desc = 'Open ipython' })
  -- Free terminal
  vim.keymap.set({ 'n', 't', 'v', 'i' }, '<C-M-m>', function()
    buffers.open_buffer 'free_terminal'
  end, { desc = 'Open free terminal' })
  vim.keymap.set({ 'n', 't', 'v', 'i' }, '<C-M-d>m', function()
    buffers.hide_buffer 'free_terminal'
  end, { desc = 'Hide free terminal' })
  -- Terminal
  vim.keymap.set({ 'n', 't', 'v', 'i' }, '<C-M-l>', function()
    windows.open_window 'primary_terminal'
  end, { desc = 'Open terminal window' })
  -- LazyGit
  vim.keymap.set({ 'n', 't', 'v', 'i' }, '<C-M-;>', function()
    windows.open_window 'lazygit'
  end, { desc = 'Open lazygit window' })

  vim.keymap.set({ 'n', 't', 'v', 'i' }, '<C-M-.>', '<cmd>DiffviewOpen<CR>', { desc = 'Open Diffview' })

  -- Claude TUI control via Meh (Ctrl+Alt+Shift) prefix.
  -- Excludes terminal mode so keys pass through to Claude when typing in TUI.

  -- Arrow nav inside the TUI (Meh+j/k)
  vim.keymap.set({ 'n', 'v', 'i' }, '<C-M-S-j>', function()
    buffers.send_to_active_tui '\27[B'
  end, { desc = 'Claude TUI arrow down (Meh+j)' })
  vim.keymap.set({ 'n', 'v', 'i' }, '<C-M-S-k>', function()
    buffers.send_to_active_tui '\27[A'
  end, { desc = 'Claude TUI arrow up (Meh+k)' })

  -- Window scroll (Meh+i/,)
  vim.keymap.set({ 'n', 'v', 'i' }, '<C-M-S-i>', function()
    buffers.scroll_active_tui 'up'
  end, { desc = 'Scroll active Claude TUI up (Meh+i)' })
  vim.keymap.set({ 'n', 'v', 'i' }, '<C-M-S-,>', function()
    buffers.scroll_active_tui 'down'
  end, { desc = 'Scroll active Claude TUI down (Meh+,)' })

  -- Numeric option select (Meh+1..9)
  for i = 1, 9 do
    vim.keymap.set({ 'n', 'v', 'i' }, '<C-M-S-' .. i .. '>', function()
      buffers.send_to_active_tui(tostring(i) .. '\r')
    end, { desc = 'Claude TUI select option ' .. i })
  end

  -- Submit and mode cycle
  vim.keymap.set({ 'n', 'v', 'i' }, '<C-M-S-CR>', function()
    buffers.send_to_active_tui '\r'
  end, { desc = 'Claude TUI submit (Meh+Enter)' })
  vim.keymap.set({ 'n', 'v', 'i' }, '<C-M-S-Tab>', function()
    buffers.send_to_active_tui '\27[Z'
  end, { desc = 'Claude TUI cycle mode (Meh+Tab)' })

  -- Esc: interrupt Claude's current action
  vim.keymap.set({ 'n', 'v', 'i' }, '<C-M-S-e>', function()
    buffers.send_to_active_tui '\x1b'
  end, { desc = 'Claude TUI send Esc / interrupt (Meh+e)' })

  -- Paste image: forward Ctrl-V to Claude so it reads the system clipboard,
  -- then (deferred) backslash+Enter to drop to a new line after the image lands
  vim.keymap.set({ 'n', 'v', 'i' }, '<C-M-S-v>', function()
    buffers.paste_image_to_active_tui()
  end, { desc = 'Claude TUI paste clipboard image (Meh+v)' })

  -- Focus active TUI window in normal mode (for yanking from Claude output)
  vim.keymap.set({ 'n', 't', 'v', 'i' }, '<C-M-i>', function()
    buffers.focus_active_tui()
  end, { desc = 'Focus active Claude TUI in normal mode (C-M-i)' })

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
M.state = state

return M
