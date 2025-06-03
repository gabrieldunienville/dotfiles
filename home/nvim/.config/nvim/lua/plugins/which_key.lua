return {
  'folke/which-key.nvim',
  event = 'VimEnter',
  config = function()
    require('which-key').setup {
      preset = 'modern',
      debug = vim.uv.cwd():find 'which%-key',
      win = {},
      spec = {},
    }
  end,
}
