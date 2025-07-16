local M = {}

local state = require 'workspace.state'
local builders = require 'workspace.builders'

-- Navigate to a specific tab/window/buffer combination
function M.go_to(tab_name, window_name, buffer_name)
  if not tab_name then
    Snacks.notifier.warn 'Tab name required for navigation'
    return false
  end

  -- Clean up any invalid references first
  state.cleanup_invalid_references()

  -- First, ensure the tab exists
  local tab_data = state.get_tab(tab_name)
  if not tab_data then
    -- Try to create the tab
    local success = M.open(tab_name, 'tab')
    if not success then
      Snacks.notifier.error('Failed to create tab: ' .. tab_name)
      return false
    end
    tab_data = state.get_tab(tab_name)
  end

  -- Navigate to the tab
  if tab_data.tab_id and vim.api.nvim_tabpage_is_valid(tab_data.tab_id) then
    vim.api.nvim_set_current_tabpage(tab_data.tab_id)
  end

  -- If we have a layout, handle window/buffer navigation
  local layout_data = state.get_layout(tab_name)
  if layout_data and layout_data.layout then
    if window_name then
      -- Focus specific window in layout
      if layout_data.windows and layout_data.windows[window_name] then
        local win = layout_data.windows[window_name]
        if win and win:valid() then
          win:focus()

          -- If buffer specified, switch to it
          if buffer_name and layout_data.buffers and layout_data.buffers[window_name] then
            local buf_data = layout_data.buffers[window_name][buffer_name]
            if buf_data and buf_data.buf_id and vim.api.nvim_buf_is_valid(buf_data.buf_id) then
              vim.api.nvim_set_current_buf(buf_data.buf_id)
            end
          end
        end
      end
    else
      -- Just focus the layout
      layout_data.layout:focus()
    end
  end

  state.set_active_tab(tab_name)
  return true
end

-- Open a tab, layout, window, or buffer
function M.open(name, type_hint)
  state.cleanup_invalid_references()

  -- Determine type if not specified
  if not type_hint then
    if vim.tbl_contains(builders.get_available_tabs(), name) then
      type_hint = 'tab'
    elseif vim.tbl_contains(builders.get_available_layouts(), name) then
      type_hint = 'layout'
    elseif vim.tbl_contains(builders.get_available_windows(), name) then
      type_hint = 'window'
    elseif vim.tbl_contains(builders.get_available_buffers(), name) then
      type_hint = 'buffer'
    else
      Snacks.notifier.error('Unknown workspace item: ' .. name)
      return false
    end
  end

  if type_hint == 'tab' then
    return M.open_tab(name)
  elseif type_hint == 'layout' then
    return M.open_layout(name)
  elseif type_hint == 'window' then
    return M.open_window(name)
  elseif type_hint == 'buffer' then
    return M.open_buffer(name)
  else
    Snacks.notifier.error('Invalid type hint: ' .. type_hint)
    return false
  end
end

-- Open a tab
function M.open_tab(tab_name)
  local tab_data = state.get_tab(tab_name)
  if tab_data and tab_data.tab_id and vim.api.nvim_tabpage_is_valid(tab_data.tab_id) then
    vim.api.nvim_set_current_tabpage(tab_data.tab_id)
    return true
  end

  -- Create new tab
  local success, result = pcall(builders.build_tab, tab_name)
  if not success then
    Snacks.notifier.error('Failed to build tab ' .. tab_name .. ': ' .. result)
    return false
  end

  local tab_id = result.tab_id
  if tab_id then
    state.set_tab(tab_name, result)
    vim.api.nvim_set_current_tabpage(tab_id)
    state.set_active_tab(tab_name)
    return true
  end

  return false
end

-- Open a layout (this is what handles complex window arrangements)
function M.open_layout(layout_name)
  local layout_data = state.get_layout(layout_name)
  if layout_data and layout_data.layout and layout_data.layout:valid() then
    layout_data.layout:show()
    layout_data.layout:focus()
    return true
  end

  -- Create new layout
  local success, result = pcall(builders.build_layout, layout_name)
  if not success then
    Snacks.notifier.error('Failed to build layout ' .. layout_name .. ': ' .. result)
    return false
  end

  if result.layout then
    state.set_layout(layout_name, result)
    result.layout:show()
    result.layout:focus()
    return true
  end

  return false
end

-- Open a window
function M.open_window(window_name)
  local success, result = pcall(builders.build_window, window_name)
  if not success then
    Snacks.notifier.error('Failed to build window ' .. window_name .. ': ' .. result)
    return false
  end

  if result and result.show then
    result:show()
    result:focus()
    return true
  end

  return false
end

-- Open a buffer
function M.open_buffer(buffer_name)
  local success, result = pcall(builders.build_buffer, buffer_name)
  if not success then
    Snacks.notifier.error('Failed to build buffer ' .. buffer_name .. ': ' .. result)
    return false
  end

  if result and vim.api.nvim_buf_is_valid(result) then
    vim.api.nvim_set_current_buf(result)
    return true
  end

  return false
end

-- Close a tab, layout, window, or buffer
function M.close(name, type_hint)
  state.cleanup_invalid_references()

  if type_hint == 'tab' then
    return M.close_tab(name)
  elseif type_hint == 'layout' then
    return M.close_layout(name)
  elseif type_hint == 'window' then
    return M.close_window(name)
  elseif type_hint == 'buffer' then
    return M.close_buffer(name)
  else
    -- Try to auto-detect and close
    local tab_data = state.get_tab(name)
    if tab_data then
      return M.close_tab(name)
    end

    local layout_data = state.get_layout(name)
    if layout_data then
      return M.close_layout(name)
    end

    return false
  end
end

-- Close a tab
function M.close_tab(tab_name)
  local tab_data = state.get_tab(tab_name)
  if tab_data and tab_data.tab_id and vim.api.nvim_tabpage_is_valid(tab_data.tab_id) then
    vim.api.nvim_del_tabpage(tab_data.tab_id)
    state.set_tab(tab_name, nil)
    return true
  end
  return false
end

-- Close a layout
function M.close_layout(layout_name)
  local layout_data = state.get_layout(layout_name)
  if layout_data and layout_data.layout then
    layout_data.layout:close()
    state.set_layout(layout_name, nil)
    return true
  end
  return false
end

-- Close a window
function M.close_window(window_name)
  -- This would need to be implemented based on specific window tracking
  -- For now, we'll just return false
  return false
end

-- Close a buffer
function M.close_buffer(buffer_name)
  -- This would need to be implemented based on specific buffer tracking
  -- For now, we'll just return false
  return false
end

-- Toggle a tab, layout, window, or buffer
function M.toggle(name, type_hint)
  local exists = false

  if type_hint == 'tab' then
    local tab_data = state.get_tab(name)
    exists = tab_data and tab_data.tab_id and vim.api.nvim_tabpage_is_valid(tab_data.tab_id)
  elseif type_hint == 'layout' then
    local layout_data = state.get_layout(name)
    exists = layout_data and layout_data.layout and layout_data.layout:valid()
  end

  if exists then
    return M.close(name, type_hint)
  else
    return M.open(name, type_hint)
  end
end

-- List available or active items
function M.list(type_filter)
  local result = {}

  if not type_filter or type_filter == 'tabs' then
    result.tabs = {}
    for tab_name, tab_data in pairs(state.get_state().tabs) do
      if tab_data.tab_id and vim.api.nvim_tabpage_is_valid(tab_data.tab_id) then
        table.insert(result.tabs, tab_name)
      end
    end
  end

  if not type_filter or type_filter == 'layouts' then
    result.layouts = {}
    for layout_name, layout_data in pairs(state.get_state().layouts) do
      if layout_data.layout and layout_data.layout:valid() then
        table.insert(result.layouts, layout_name)
      end
    end
  end

  if not type_filter or type_filter == 'available' then
    result.available = {
      tabs = builders.get_available_tabs(),
      layouts = builders.get_available_layouts(),
      windows = builders.get_available_windows(),
      buffers = builders.get_available_buffers(),
    }
  end

  return result
end

return M
