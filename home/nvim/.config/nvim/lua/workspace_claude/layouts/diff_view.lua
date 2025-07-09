local builders = require 'workspace.builders'

-- Diff view layout for git comparisons
builders.register_layout_builder('diff_view', function()
  -- Create buffers for diff view
  local left_buf = builders.create_scratch_buffer('Original', {
    filetype = 'diff',
    content = { '-- Original file content will be loaded here' },
  })
  local right_buf = builders.create_scratch_buffer('Modified', {
    filetype = 'diff',
    content = { '-- Modified file content will be loaded here' },
  })

  -- Create windows
  local left_win = Snacks.win.new {
    buf = left_buf,
    title = 'Original',
    border = 'rounded',
  }

  local right_win = Snacks.win.new {
    buf = right_buf,
    title = 'Modified',
    border = 'rounded',
  }

  -- Create side-by-side layout
  local layout = Snacks.layout.new {
    wins = {
      left = left_win,
      right = right_win,
    },
    layout = {
      box = 'horizontal',
      position = 'float',
      width = 0.9,
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

-- Diff view tab (creates a new tab with diff layout)
builders.register_tab_builder('diff_view', function()
  vim.cmd 'tabnew'
  local tab_id = vim.api.nvim_get_current_tabpage()

  return {
    tab_id = tab_id,
  }
end)

