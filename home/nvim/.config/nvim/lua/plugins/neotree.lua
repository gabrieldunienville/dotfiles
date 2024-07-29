return {
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'v3.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-tree/nvim-web-devicons', -- not strictly required, but recommended
    'MunifTanjim/nui.nvim',
    -- "3rd/image.nvim", -- Optional image support in preview window: See `# Preview Mode` for more information
  },
  config = function()
    -- See recipes here for customisation: https://github.com/nvim-neo-tree/neo-tree.nvim/wiki/Recipes

    require('neo-tree').setup {
      filesystem = {
        filtered_items = {
          hide_hidden = false,
        },
        window = {
          mappings = {
            -- ['tf'] = 'telescope_find',
            -- ['tg'] = 'telescope_grep',
            [',g'] = function(state)
              print 'Custom shit'
              local node = state.tree:get_node()
              local path = node:get_id()
              require('telescope.builtin').live_grep {
                search_dirs = { path },
                prompt_title = string.format('Grep in [%s]', vim.fs.basename(path)),
              }
            end,
          },
        },
      },
    }
    -- vim.keymap.set('n','<A-w>', '<Plug>SlimeParagraphSend', { remap = true, silent = false })
    vim.keymap.set('n', '<leader>t', '<Cmd>Neotree toggle reveal<CR>', { desc = 'File [T]ree' })
  end,
}
