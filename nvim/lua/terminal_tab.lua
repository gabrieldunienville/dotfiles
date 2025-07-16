local M = {}

local terminal_tab = nil
local terminal_buf = nil

function _G.open_terminal_tab()
  -- Check if the terminal tab already exists
  if terminal_tab and vim.api.nvim_tabpage_is_valid(terminal_tab) then
    -- Switch to the existing terminal tab
    vim.api.nvim_set_current_tabpage(terminal_tab)
    if terminal_buf and vim.api.nvim_buf_is_valid(terminal_buf) then
      vim.api.nvim_set_current_buf(terminal_buf)
    end
    vim.cmd 'startinsert'
    return
  end

  -- Create a new tab
  vim.cmd 'tabnew'
  terminal_tab = vim.api.nvim_get_current_tabpage()

  -- Create terminal buffer
  terminal_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(terminal_buf, 'Terminal')
  vim.api.nvim_set_current_buf(terminal_buf)

  -- Open terminal
  vim.cmd 'terminal'

  -- Set local options for the terminal buffer
  vim.opt_local.number = false
  vim.opt_local.relativenumber = false

  -- Set up keymaps for terminal mode navigation
  local opts = { buffer = terminal_buf }
  vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], opts)
  vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], opts)
  vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], opts)
  vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], opts)
  vim.keymap.set('t', '<C-e>', '<C-\\><C-n>', opts)

  -- Start in insert mode
  vim.cmd 'startinsert'
end

-- Clean up function when tab is closed
vim.api.nvim_create_autocmd('TabClosed', {
  callback = function(args)
    if terminal_tab and tonumber(args.file) == terminal_tab then
      terminal_tab = nil
      terminal_buf = nil
    end
  end,
})

vim.keymap.set('n', '<leader>wt', '<cmd>lua open_terminal_tab()<CR>', {
  noremap = true,
  silent = true,
  desc = 'Open Claude Code Terminal',
})

return M
