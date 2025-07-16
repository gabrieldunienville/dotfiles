return {
  'folke/edgy.nvim',
  event = 'VeryLazy',
  opts = {
    left = {
      -- -- Neo-tree filesystem
      -- {
      --   title = 'Neo-Tree',
      --   ft = 'neo-tree',
      --   filter = function(buf)
      --     return vim.b[buf].neo_tree_source == 'filesystem'
      --   end,
      -- },
      -- Snacks Explorer
      -- {
      --   ft = 'snacks_picker_input',
      --   size = { height = 1 },
      -- },
      -- {
      --   ft = 'snacks_picker_list',
      -- },
      -- -- Aerial
      -- {
      --   title = 'Aerial',
      --   ft = 'aerial',
      --   size = { height = 0.5 },
      -- },
    },
    wo = {
      -- Window options that might help stabilize
      winfixwidth = true,
      -- winfixheight = true,
    },
    animate = {
      enabled = false,
    },
    options = {
      left = {
        size = 0.15,
      },
    },
  },
}
