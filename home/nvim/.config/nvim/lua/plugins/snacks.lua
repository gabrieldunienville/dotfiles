return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    picker = {
      enabled = true,
      icons = {
        files = {
          enabled = true, -- Make sure this is true
          dir = '󰉋 ',
          file = '󰈔 ',
        },
      },
    },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
  },
}
