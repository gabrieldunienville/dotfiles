return {
  'numToStr/Comment.nvim',
  dependencies = {
    'JoosepAlviste/nvim-ts-context-commentstring',
  },
  config = function()
    require('Comment').setup {
      toggler = {
        line = '<leader>cc',
        block = '<leader>zc',
      },
      opleader = {
        line = '<leader>c',
        block = '<leader>z',
      },
      extra = {
        above = '<leader>cO',
        below = '<leader>co',
        eol = '<leader>cA',
      },
      -- LSP-based commenting for JSX
      pre_hook = require('ts_context_commentstring.integrations.comment_nvim').create_pre_hook(),
    }
  end,
}
