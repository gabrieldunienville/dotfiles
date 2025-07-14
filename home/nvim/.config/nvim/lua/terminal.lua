vim.api.nvim_create_autocmd('TermOpen', {
  pattern = '*',
  callback = function()
    -- Disable line numbers in terminal
    vim.opt_local.number = false
    vim.opt_local.relativenumber = false

    -- Auto enter insert mode
    vim.cmd 'startinsert'

    -- Set local keymaps for terminal buffers
    local opts = { buffer = 0 }
    vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], opts)
    vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], opts)
    vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], opts)
    vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], opts)

    vim.keymap.set('t', '<C-e>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
  end,
})

vim.api.nvim_create_autocmd('BufEnter', {
  pattern = 'term://*',
  callback = function()
    vim.cmd 'startinsert'
  end,
})

-- -- Set cursor green in terminal insert mode
-- vim.opt.guicursor:append 't:block-TermCursor/lTermCursor'
-- vim.api.nvim_set_hl(0, 'TermCursor', { bg = '#00ff00' })
-- vim.api.nvim_set_hl(0, 'lTermCursor', { bg = '#00ff00' })
