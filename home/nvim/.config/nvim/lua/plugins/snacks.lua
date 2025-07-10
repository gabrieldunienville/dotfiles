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
    -- explorer = {
    --   enabled = true,
    -- },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    win = {
      enable = true,
    },
    -- layout = {
    --   show = true,
    --   fullscreen = true,
    --   layout = {
    --     box = 'horizontal',
    --     position = 'left',
    --     {
    --       win = 'left',
    --       width = 0.6,
    --     },
    --     {
    --       win = 'right',
    --       width = 0.4,
    --     },
    --   },
    --   -- wins = {
    --   --   left = Snacks.win.new {
    --   --     border = 'rounded',
    --   --   },
    --   --   right = Snacks.win.new {
    --   --     border = 'single',
    --   --   },
    --   -- },
    -- },
    -- layout = {
    --   wins = {
    --     editor = Snacks.win {
    --       title = 'Neovim Editor',
    --       -- Your main editor window config
    --     },
    --     terminal = Snacks.win {
    --       title = 'Neovim Terminal',
    --       -- Terminal for build/test/git
    --     },
    --     claude = Snacks.win {
    --       title = 'Claude Code Terminal',
    --       -- Claude Code or IPython repr
    --     },
    --   },
    -- },
    --   layout = {
    --     box = 'horizontal',
    --     width = 0.9,
    --     height = 0.8,
    --     {
    --       -- Left column (editor + terminal)
    --       box = 'vertical',
    --       width = 0.6,
    --       {
    --         win = 'editor',
    --         height = 0.7, -- 70% of left column
    --       },
    --       {
    --         win = 'terminal',
    --         height = 0.3, -- 30% of left column
    --       },
    --     },
    --     {
    --       -- Right column (Claude)
    --       win = 'claude',
    --       width = 0.4,
    --     },
    --   },
    -- },
  },
}
