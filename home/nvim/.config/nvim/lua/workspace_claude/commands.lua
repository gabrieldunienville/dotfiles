-- Require navigation directly to avoid circular dependency
local navigation = require 'workspace.navigation'

-- Main workspace goto command
vim.api.nvim_create_user_command('WorkspaceGoto', function(opts)
  local args = vim.split(opts.args, ' ')
  local tab_name = args[1]
  local window_name = args[2]
  local buffer_name = args[3]

  if not tab_name then
    vim.notify('Usage: :WorkspaceGoto <tab> [window] [buffer]', vim.log.levels.ERROR)
    return
  end

  navigation.go_to(tab_name, window_name, buffer_name)
end, {
  nargs = '+',
  complete = function(arg_lead, cmd_line, cursor_pos)
    local args = vim.split(cmd_line, ' ')
    local arg_count = #args - 1 -- Subtract 1 for the command name

    if arg_count == 1 then
      -- Tab completion
      local available = navigation.list 'available'
      local tabs = vim.tbl_extend('force', available.tabs or {}, available.layouts or {})
      return vim.tbl_filter(function(name)
        return vim.startswith(name, arg_lead)
      end, tabs)
    elseif arg_count == 2 then
      -- Window completion (basic for now)
      return vim.tbl_filter(function(name)
        return vim.startswith(name, arg_lead)
      end, { 'terminal', 'code', 'explorer', 'tools' })
    elseif arg_count == 3 then
      -- Buffer completion (basic for now)
      return vim.tbl_filter(function(name)
        return vim.startswith(name, arg_lead)
      end, { 'ai_chat', 'repl', 'main' })
    end

    return {}
  end,
  desc = 'Navigate to workspace tab/window/buffer',
})

-- Workspace open command
vim.api.nvim_create_user_command('WorkspaceOpen', function(opts)
  local args = vim.split(opts.args, ' ')
  local name = args[1]
  local type_hint = args[2]

  if not name then
    vim.notify('Usage: :WorkspaceOpen <name> [type]', vim.log.levels.ERROR)
    return
  end

  navigation.open(name, type_hint)
end, {
  nargs = '+',
  complete = function(arg_lead, cmd_line, cursor_pos)
    local args = vim.split(cmd_line, ' ')
    local arg_count = #args - 1

    if arg_count == 1 then
      -- Name completion
      local available = navigation.list 'available'
      local all_names = vim.tbl_extend('force', available.tabs or {}, available.layouts or {}, available.windows or {}, available.buffers or {})
      return vim.tbl_filter(function(name)
        return vim.startswith(name, arg_lead)
      end, all_names)
    elseif arg_count == 2 then
      -- Type completion
      return vim.tbl_filter(function(name)
        return vim.startswith(name, arg_lead)
      end, { 'tab', 'layout', 'window', 'buffer' })
    end

    return {}
  end,
  desc = 'Open workspace item',
})

-- Workspace close command
vim.api.nvim_create_user_command('WorkspaceClose', function(opts)
  local args = vim.split(opts.args, ' ')
  local name = args[1]
  local type_hint = args[2]

  if not name then
    vim.notify('Usage: :WorkspaceClose <name> [type]', vim.log.levels.ERROR)
    return
  end

  navigation.close(name, type_hint)
end, {
  nargs = '+',
  complete = function(arg_lead, cmd_line, cursor_pos)
    local args = vim.split(cmd_line, ' ')
    local arg_count = #args - 1

    if arg_count == 1 then
      -- Show currently open items
      local current = navigation.list()
      local all_names = vim.tbl_extend('force', current.tabs or {}, current.layouts or {})
      return vim.tbl_filter(function(name)
        return vim.startswith(name, arg_lead)
      end, all_names)
    elseif arg_count == 2 then
      -- Type completion
      return vim.tbl_filter(function(name)
        return vim.startswith(name, arg_lead)
      end, { 'tab', 'layout', 'window', 'buffer' })
    end

    return {}
  end,
  desc = 'Close workspace item',
})

-- Workspace toggle command
vim.api.nvim_create_user_command('WorkspaceToggle', function(opts)
  local args = vim.split(opts.args, ' ')
  local name = args[1]
  local type_hint = args[2]

  if not name then
    vim.notify('Usage: :WorkspaceToggle <name> [type]', vim.log.levels.ERROR)
    return
  end

  navigation.toggle(name, type_hint)
end, {
  nargs = '+',
  complete = function(arg_lead, cmd_line, cursor_pos)
    local args = vim.split(cmd_line, ' ')
    local arg_count = #args - 1

    if arg_count == 1 then
      -- Name completion
      local available = navigation.list 'available'
      local all_names = vim.tbl_extend('force', available.tabs or {}, available.layouts or {}, available.windows or {}, available.buffers or {})
      return vim.tbl_filter(function(name)
        return vim.startswith(name, arg_lead)
      end, all_names)
    elseif arg_count == 2 then
      -- Type completion
      return vim.tbl_filter(function(name)
        return vim.startswith(name, arg_lead)
      end, { 'tab', 'layout', 'window', 'buffer' })
    end

    return {}
  end,
  desc = 'Toggle workspace item',
})

-- Workspace list command
vim.api.nvim_create_user_command('WorkspaceList', function(opts)
  local type_filter = opts.args ~= '' and opts.args or nil
  local result = navigation.list(type_filter)

  print '=== Workspace Status ==='

  if result.tabs then
    print 'Active tabs:'
    for _, tab in ipairs(result.tabs) do
      print('  ' .. tab)
    end
  end

  if result.layouts then
    print 'Active layouts:'
    for _, layout in ipairs(result.layouts) do
      print('  ' .. layout)
    end
  end

  if result.available then
    print('Available tabs: ' .. table.concat(result.available.tabs, ', '))
    print('Available layouts: ' .. table.concat(result.available.layouts, ', '))
    print('Available windows: ' .. table.concat(result.available.windows, ', '))
    print('Available buffers: ' .. table.concat(result.available.buffers, ', '))
  end
end, {
  nargs = '?',
  complete = function(arg_lead, cmd_line, cursor_pos)
    return vim.tbl_filter(function(name)
      return vim.startswith(name, arg_lead)
    end, { 'tabs', 'layouts', 'available' })
  end,
  desc = 'List workspace items',
})

-- Convenient keymaps
vim.keymap.set('n', '<leader>wg', ':WorkspaceGoto ', {
  noremap = true,
  silent = false,
  desc = 'Workspace goto',
})

vim.keymap.set('n', '<leader>wo', ':WorkspaceOpen ', {
  noremap = true,
  silent = false,
  desc = 'Workspace open',
})

vim.keymap.set('n', '<leader>wt', ':WorkspaceToggle ', {
  noremap = true,
  silent = false,
  desc = 'Workspace toggle',
})

vim.keymap.set('n', '<leader>wl', '<cmd>WorkspaceList<CR>', {
  noremap = true,
  silent = true,
  desc = 'Workspace list',
})

-- Quick access keymaps for common workspaces
vim.keymap.set('n', '<leader>wct', function()
  navigation.open 'claude_terminal'
end, {
  noremap = true,
  silent = true,
  desc = 'Open Claude terminal',
})

vim.keymap.set('n', '<leader>wgt', function()
  navigation.open 'general_terminal'
end, {
  noremap = true,
  silent = true,
  desc = 'Open general terminal',
})

vim.keymap.set('n', '<leader>wmt', function()
  navigation.open 'multi_terminal'
end, {
  noremap = true,
  silent = true,
  desc = 'Open multi terminal',
})

vim.keymap.set('n', '<leader>wdt', function()
  navigation.open 'dev_terminal'
end, {
  noremap = true,
  silent = true,
  desc = 'Open dev terminal',
})

