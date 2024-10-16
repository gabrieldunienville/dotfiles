return {
  'zbirenbaum/copilot.lua',
  enabled = true,
  cmd = 'Copilot',
  event = 'InsertEnter',
  config = function()
    require('copilot').setup {
      panel = {
        enabled = false,
        auto_refresh = false,
        keymap = {
          jump_prev = '[[',
          jump_next = ']]',
          accept = '<CR>',
          refresh = 'gr',
          open = '<M-CR>',
        },
        layout = {
          position = 'bottom', -- | top | left | right
          ratio = 0.4,
        },
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        hide_during_completion = true,
        debounce = 75,
        keymap = {
          prev = '<M-m>',
          next = '<M-,>',
          accept_word = '<M-o>',
          accept_line = '<M-l>',
          accept = '<M-.>',
          dismiss = '<M-;>',
        },
      },
      filetypes = {
        yaml = false,
        markdown = false,
        help = false,
        gitcommit = false,
        gitrebase = false,
        hgcommit = false,
        svn = false,
        cvs = false,
        svelte = true,
        ['.'] = false,
      },
      copilot_node_command = 'node', -- Node.js version must be > 18.x
      server_opts_overrides = {},
    }

    -- Inline suggestions are highlighted using the CopilotSuggestion group,
    -- defaulting to a medium gray.  The best place to override this is with
    -- a |ColorScheme| autocommand:
    -- vim.api.nvim_create_autocmd('ColorScheme', {
    --   pattern = 'solarized',
    --   -- group = ...,
    --   callback = function()
    --     vim.api.nvim_set_hl(0, 'CopilotSuggestion', {
    --       fg = '#555555',
    --       ctermfg = 8,
    --       force = true,
    --     })
    --   end,
    -- })
  end,
}
