return {
  'Wansmer/treesj',
  keys = { '<leader>j' },
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    require('treesj').setup {
      use_default_keymaps = false,
      max_join_length = 9999,
    }
    -- For default preset
    vim.keymap.set('n', '<leader>jt', require('treesj').toggle)
    -- For extending default preset with `recursive = true`
    vim.keymap.set('n', '<leader>jr', function()
      require('treesj').toggle { split = { recursive = true } }
    end)
  end,
}
