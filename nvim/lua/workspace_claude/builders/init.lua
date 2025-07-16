local M = {}

local state = require 'workspace.state'

-- Registry for different builder types
local builders = {
  tabs = {},
  layouts = {},
  windows = {},
  buffers = {},
}

-- Register a builder function
function M.register_tab_builder(name, builder_fn)
  builders.tabs[name] = builder_fn
end

function M.register_layout_builder(name, builder_fn)
  builders.layouts[name] = builder_fn
end

function M.register_window_builder(name, builder_fn)
  builders.windows[name] = builder_fn
end

function M.register_buffer_builder(name, builder_fn)
  builders.buffers[name] = builder_fn
end

-- Build a tab (creates tab and any associated layouts)
function M.build_tab(tab_name)
  local builder = builders.tabs[tab_name]
  if not builder then
    error('No builder registered for tab: ' .. tab_name)
  end

  return builder()
end

-- Build a layout (uses Snacks.layout for complex arrangements)
function M.build_layout(layout_name)
  local builder = builders.layouts[layout_name]
  if not builder then
    error('No builder registered for layout: ' .. layout_name)
  end

  return builder()
end

-- Build a window (uses Snacks.win)
function M.build_window(window_name, config)
  local builder = builders.windows[window_name]
  if not builder then
    error('No builder registered for window: ' .. window_name)
  end

  return builder(config or {})
end

-- Build a buffer
function M.build_buffer(buffer_name, config)
  local builder = builders.buffers[buffer_name]
  if not builder then
    error('No builder registered for buffer: ' .. buffer_name)
  end

  return builder(config or {})
end

-- Get list of available builders
function M.get_available_tabs()
  return vim.tbl_keys(builders.tabs)
end

function M.get_available_layouts()
  return vim.tbl_keys(builders.layouts)
end

function M.get_available_windows()
  return vim.tbl_keys(builders.windows)
end

function M.get_available_buffers()
  return vim.tbl_keys(builders.buffers)
end

-- Utility functions for builders
function M.create_terminal_buffer(name, config)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, name)

  -- Apply terminal-specific options
  vim.api.nvim_buf_call(buf, function()
    vim.cmd 'terminal'
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false

    -- Set up terminal navigation keymaps
    local opts = { buffer = buf }
    vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], opts)
    vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], opts)
    vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], opts)
    vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], opts)
    vim.keymap.set('t', '<C-e>', '<C-\\><C-n>', opts)

    -- Run initial command if specified
    if config.initial_command then
      vim.defer_fn(function()
        local job_id = vim.api.nvim_buf_get_var(buf, 'terminal_job_id')
        vim.fn.chansend(job_id, config.initial_command .. '\n')
      end, 100)
    end
  end)

  return buf
end

function M.create_scratch_buffer(name, config)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, name)

  -- Apply scratch buffer options
  vim.api.nvim_buf_call(buf, function()
    vim.opt_local.buftype = 'nofile'
    vim.opt_local.swapfile = false
    vim.opt_local.bufhidden = 'wipe'

    if config.filetype then
      vim.opt_local.filetype = config.filetype
    end

    if config.content then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, config.content)
    end
  end)

  return buf
end

return M
