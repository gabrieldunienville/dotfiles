return {
  'folke/which-key.nvim',
  event = 'VimEnter',
  config = function()
    require('which-key').setup {
      preset = 'modern',
      debug = vim.uv.cwd():find 'which%-key',
      win = {},
      spec = {},
      plugins = {
        registers = true, -- shows your registers on " in NORMAL or <C-r> in INSERT mode
        -- the presets plugin, adds help for a bunch of default keybindings in Neovim
        -- No actual key bindings are created
        -- spelling = {
        --   enabled = true, -- enabling this will show WhichKey when pressing z= to select spelling suggestions
        --   suggestions = 8,
        -- },
      },
    }
  end,
}
