return {
  'Wansmer/treesj',
  keys = { '<leader>j' },
  dependencies = { 'nvim-treesitter/nvim-treesitter' },
  config = function()
    local tsj = require 'treesj'
    local tsj_utils = require 'treesj.langs.utils'
    local langs = {
      xml = tsj_utils.merge_preset(require 'treesj.langs.html', {
      }),
    }

    tsj.setup {
      use_default_keymaps = false,
      max_join_length = 9999,
      langs = langs,
    }
    -- For default preset
    vim.keymap.set('n', '<leader>jt', require('treesj').toggle)
    -- For extending default preset with `recursive = true`
    vim.keymap.set('n', '<leader>jr', function()
      require('treesj').toggle { split = { recursive = true } }
    end)
  end,
}
