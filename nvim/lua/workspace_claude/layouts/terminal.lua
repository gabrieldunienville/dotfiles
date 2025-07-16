local builders = require 'workspace.builders'

-- Claude terminal layout (migrated from workspace_legacy)
builders.register_layout_builder('claude_terminal', function()
  local terminal_buf = builders.create_terminal_buffer('Claude Code Terminal', {
    initial_command = 'claude',
  })

  local terminal_win = Snacks.win.new {
    buf = terminal_buf,
    title = 'Claude Code Terminal',
    position = 'right',
    width = 0.5,
    on_win = function(win)
      vim.cmd 'startinsert'
    end,
  }

  return {
    layout = nil, -- Single window doesn't need Snacks.layout
    windows = {
      terminal = terminal_win,
    },
    buffers = {
      terminal = {
        main = { buf_id = terminal_buf },
      },
    },
  }
end)

-- General terminal tab (simple terminal in new tab)
builders.register_tab_builder('general_terminal', function()
  vim.cmd 'tabnew'
  local tab_id = vim.api.nvim_get_current_tabpage()

  local terminal_buf = builders.create_terminal_buffer('General Terminal', {})
  vim.api.nvim_set_current_buf(terminal_buf)
  vim.cmd 'startinsert'

  return {
    tab_id = tab_id,
    buffers = {
      terminal = { buf_id = terminal_buf },
    },
  }
end)

-- Multi-terminal layout (multiple terminals side by side)
builders.register_layout_builder('multi_terminal', function()
  local left_buf = builders.create_terminal_buffer('Terminal 1', {})
  local right_buf = builders.create_terminal_buffer('Terminal 2', {})

  local left_win = Snacks.win.new {
    buf = left_buf,
    title = 'Terminal 1',
    border = 'rounded',
  }

  local right_win = Snacks.win.new {
    buf = right_buf,
    title = 'Terminal 2',
    border = 'rounded',
  }

  local layout = Snacks.layout.new {
    wins = {
      left = left_win,
      right = right_win,
    },
    layout = {
      box = 'horizontal',
      position = 'float',
      width = 0.8,
      height = 0.8,
      border = 'rounded',
      {
        win = 'left',
        width = 0.5,
      },
      {
        win = 'right',
        width = 0.5,
      },
    },
  }

  return {
    layout = layout,
    windows = {
      left = left_win,
      right = right_win,
    },
    buffers = {
      left = { main = { buf_id = left_buf } },
      right = { main = { buf_id = right_buf } },
    },
  }
end)

-- Development terminal layout (terminal + repl)
builders.register_layout_builder('dev_terminal', function()
  local terminal_buf = builders.create_terminal_buffer('Terminal', {})
  local repl_buf = builders.create_terminal_buffer('REPL', {
    initial_command = 'ipython',
  })

  local terminal_win = Snacks.win.new {
    buf = terminal_buf,
    title = 'Terminal',
    border = 'rounded',
  }

  local repl_win = Snacks.win.new {
    buf = repl_buf,
    title = 'REPL',
    border = 'rounded',
  }

  local layout = Snacks.layout.new {
    wins = {
      terminal = terminal_win,
      repl = repl_win,
    },
    layout = {
      box = 'vertical',
      position = 'bottom',
      width = 1.0,
      height = 0.5,
      border = 'rounded',
      {
        win = 'terminal',
        height = 0.6,
      },
      {
        win = 'repl',
        height = 0.4,
      },
    },
  }

  return {
    layout = layout,
    windows = {
      terminal = terminal_win,
      repl = repl_win,
    },
    buffers = {
      terminal = { main = { buf_id = terminal_buf } },
      repl = { main = { buf_id = repl_buf } },
    },
  }
end)

-- Simple terminal window (for use in other layouts)
builders.register_window_builder('terminal', function(config)
  local buf = builders.create_terminal_buffer(config.name or 'Terminal', config)

  return Snacks.win.new {
    buf = buf,
    title = config.title or 'Terminal',
    position = config.position or 'right',
    width = config.width or 0.5,
    height = config.height or 0.8,
    border = config.border or 'rounded',
    on_win = function(win)
      if config.start_insert ~= false then
        vim.cmd 'startinsert'
      end
    end,
  }
end)

-- Terminal buffer builder
builders.register_buffer_builder('terminal', function(config)
  return builders.create_terminal_buffer(config.name or 'Terminal', config)
end)

