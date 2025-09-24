return {
  'jpalardy/vim-slime',
  dependencies = {
    'Klafyvel/vim-slime-cells',
  },
  -- https://github.com/jpalardy/vim-slime/blob/main/assets/doc/advanced.md
  init = function()
    -- these two should be set before the plugin loads
    -- vim.g.slime_target = 'tmux'
    vim.g.slime_target = 'neovim'

    vim.g.slime_no_mappings = true
  end,
  config = function()
    vim.g.slime_neovim_ignore_unlisted = false

    -- Used with tmux target
    -- vim.g.slime_default_config = { socket_name = 'default', target_pane = ':.2' }

    -- Used with neovim target
    -- vim.g.slime_get_jobid = function()
    --   local buf_id = require('workspace').state.get_buffer('ipython', 'tools')
    --   local job_id = vim.api.nvim_buf_get_var(buf_id, 'terminal_job_id')
    --   return job_id
    -- end
    -- vim.g.slime_input_pid = false
    -- vim.g.slime_suggest_default = false
    -- vim.g.slime_menu_config = false
    -- vim.g.slime_neovim_ignore_unlisted = false

    vim.g.slime_dont_ask_default = true
    vim.g.slime_preserve_curpos = 0
    vim.g.slime_cell_delimiter = '^#\\s--'

    vim.g.slime_python_ipython = 1

    -- Set this so we can execute a whole code block as one cell in the REPL
    --    Note from docs: If your target supports bracketed-paste, that's a better option than g:slime_python_ipython
    --    See https://github.com/jpalardy/vim-slime/blob/main/ftplugin/python/README.md
    -- vim.g.slime_bracketed_paste = 1

    -- Send line
    vim.keymap.set('n', '<A-e>', '<Plug>SlimeLineSend', { remap = true, silent = false })

    -- Send visual block
    vim.keymap.set('x', '<A-e>', '<Plug>SlimeRegionSend', { remap = true, silent = false })

    -- Send paragraph
    vim.keymap.set('n', '<A-w>', '<Plug>SlimeParagraphSend', { remap = true, silent = false })

    -- Send entire file
    vim.keymap.set('n', '<A-q>', ':%SlimeSend<CR>', { remap = true, silent = false })

    -- Send cell
    vim.keymap.set('n', '<A-r>', '<Plug>SlimeSendCell', { remap = true, silent = false })
    vim.keymap.set('n', '<A-t>', '<Plug>SlimeCellsSendAndGoToNext', { remap = true, silent = false })

    -- Navigate cells
    vim.keymap.set('n', '<A-c>', '<Plug>SlimeCellsNext', { remap = true, silent = false })
    vim.keymap.set('n', '<A-v>', '<Plug>SlimeCellsPrev', { remap = true, silent = false })
  end,
}
