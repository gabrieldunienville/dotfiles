local function callback()
  -- Create two windows for side-by-side layout
  local left_win = Snacks.win {
    buf = vim.api.nvim_create_buf(false, true), -- Create new buffer
    width = 0.5,
    height = 0.8,
    border = 'rounded',
    title = 'Left Panel',
  }

  local right_win = Snacks.win {
    buf = vim.api.nvim_create_buf(false, true), -- Create new buffer
    width = 0.5,
    height = 0.8,
    border = 'rounded',
    title = 'Right Panel',
  }

  -- Create the side-by-side layout
  local layout = Snacks.layout.new {
    wins = {
      left = left_win,
      right = right_win,
    },
    layout = {
      box = 'horizontal',
      position = 'left', -- Use split instead of float
      width = 0.8,
      height = 0.8,
      border = 'rounded',
      {
        win = 'left',
        width = 0.5, -- 50% of layout width
      },
      {
        win = 'right',
        width = 0.5, -- 50% of layout width
      },
    },
  }
end

-- vim.api.nvim_create_autocmd('VimEnter', {callback})
vim.api.nvim_create_user_command('OpenSideBySideLayout', callback, { desc = 'Open side-by-side layout with Snacks' })
