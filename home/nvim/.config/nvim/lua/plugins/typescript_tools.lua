return {
  'pmizio/typescript-tools.nvim',
  enabled = false,
  dependencies = {
    'nvim-lua/plenary.nvim',
    'neovim/nvim-lspconfig',
  },
  config = function()
    require('typescript-tools').setup {
      filetypes = {
        'javascript',
        'typescript',
        -- 'svelte',
      },
      settings = {
        -- Svelte-specific settings
        -- svelte = {
        --   plugin = {
        --     typescript = {
        --       enabled = true,
        --     },
        --   },
        -- },
      },
    }
  end,
}
