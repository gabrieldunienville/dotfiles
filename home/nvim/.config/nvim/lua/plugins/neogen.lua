return {
  'danymat/neogen',
  config = function()
    local neogen = require('neogen')
    neogen.setup({})
    local opts = { noremap = true, desc = '[G]enerate [F]unction docs'}
    vim.keymap.set('n', '<leader>gf', function()
      neogen.generate { type = 'func' }
    end, opts)
  end,
}
