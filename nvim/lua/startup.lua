local windows = require 'workspace.windows'

Snacks.explorer.open()

-- Delay this to allow the explorer to open first
vim.defer_fn(function()
  windows.open_window 'code'
end, 50)
