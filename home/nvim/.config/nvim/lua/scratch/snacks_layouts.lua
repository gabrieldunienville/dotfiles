local layout = Snacks.layout.new {
  show = true,
  -- fullscreen = true,
  layout = {
    box = 'horizontal',
    position = 'left',
    {
      win = 'left',
      width = 0.6,
    },
    {
      win = 'right',
      width = 0.4,
    },
  },
  wins = {
    left = Snacks.win.new {
      border = 'rounded',
    },
    right = Snacks.win.new {
      border = 'single',
    },
  },
}

_G.L = layout
