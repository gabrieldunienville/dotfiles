local builders = require 'workspace.builders'

-- Main workspace layout with code, explorer, and tools windows
builders.register_layout_builder('main', function()
  -- Create buffers for different purposes
  local code_buf = vim.api.nvim_create_buf(false, false)
  local explorer_buf = builders.create_scratch_buffer('Explorer', {
    filetype = 'neotree',
    content = { '-- File explorer will be integrated here' },
  })
  local tools_buf = builders.create_scratch_buffer('Tools', {
    content = { '-- Tools panel - can switch between ai_chat and repl' },
  })

  -- Create windows
  local code_win = Snacks.win.new {
    buf = code_buf,
    title = 'Code',
    border = 'rounded',
  }

  local explorer_win = Snacks.win.new {
    buf = explorer_buf,
    title = 'Explorer',
    border = 'rounded',
  }

  local tools_win = Snacks.win.new {
    buf = tools_buf,
    title = 'Tools',
    border = 'rounded',
  }

  -- Create complex layout
  local layout = Snacks.layout.new {
    wins = {
      code = code_win,
      explorer = explorer_win,
      tools = tools_win,
    },
    layout = {
      box = 'horizontal',
      position = 'float',
      width = 0.95,
      height = 0.9,
      border = 'rounded',
      {
        win = 'explorer',
        width = 0.2,
      },
      {
        win = 'code',
        width = 0.6,
      },
      {
        win = 'tools',
        width = 0.2,
      },
    },
  }

  return {
    layout = layout,
    windows = {
      code = code_win,
      explorer = explorer_win,
      tools = tools_win,
    },
    buffers = {
      code = { main = { buf_id = code_buf } },
      explorer = { main = { buf_id = explorer_buf } },
      tools = {
        main = { buf_id = tools_buf },
        ai_chat = { buf_id = nil }, -- Will be created lazily
        repl = { buf_id = nil }, -- Will be created lazily
      },
    },
  }
end)

-- Main tab (creates a new tab with main layout)
builders.register_tab_builder('main', function()
  vim.cmd 'tabnew'
  local tab_id = vim.api.nvim_get_current_tabpage()

  -- The main layout will be created separately
  return {
    tab_id = tab_id,
  }
end)

