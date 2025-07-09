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
  end,
})

-- Add to Neovim config
function _G.open_claude_terminal()
  -- Open terminal in vertical split (right side, 50% width)
  vim.cmd 'vsplit'
  vim.cmd 'wincmd l'
  vim.cmd('vertical resize ' .. math.floor(vim.o.columns * 0.5))
  vim.cmd 'terminal'

  -- Rename buffer for easy identification
  vim.api.nvim_buf_set_name(0, 'Claude Code')

  -- Optional: auto-start claude if available
  vim.defer_fn(function()
    vim.fn.chansend(vim.b.terminal_job_id, 'claude\n')
  end, 100)
end

local function open_bottom_terminal()
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, 10)
end

vim.keymap.set('n', '<leader>kz', open_claude_terminal, { desc = 'Open Claude Code terminal' })
vim.keymap.set('n', '<leader>kb', open_bottom_terminal, { desc = 'Open bottom terminal' })

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
vim.keymap.set('t', '<C-e>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
