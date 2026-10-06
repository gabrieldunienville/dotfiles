return {
  'linux-cultist/venv-selector.nvim',
  dependencies = {
    {
      'folke/snacks.nvim',
    },
  },
  ft = 'python', -- Load when opening Python files
  keys = {
    { '<leader>v', '<cmd>VenvSelect<cr>' }, -- Open picker on keymap
  },
  opts = { -- this can be an empty lua table - just showing below for clarity.
    search = {
      uv_venv = {
        command = "$FD '/bin/python$' '$CWD/.venv' --full-path --color never -a -HI",
      },
    },
    options = {}, -- if you add plugin options, they go here.
  },
}
