local size = 2
vim.bo.tabstop = size -- size of a hard tabstop (ts).
vim.bo.shiftwidth = size -- size of an indentation (sw).
vim.bo.expandtab = true -- always uses spaces instead of tab characters (et)
vim.bo.softtabstop = size -- number of spaces a <Tab> counts for. When 0, feature is off (sts).

-- vim.keymap.set('n', '<leader>e', function()
--   require('pretty-ts-errors').show_formatted_error()
--   vim.defer_fn(function()
--     require('windows').focus_float()
--   end, 150)
-- end, { desc = 'Show diagnostic [E]rror messages', buffer = true })

vim.keymap.set('n', '<leader>e', function()
  vim.api.nvim_create_autocmd('WinNew', {
    once = true,
    callback = function(ev)
      local win = vim.api.nvim_get_current_win()
      vim.schedule(function()
        vim.api.nvim_set_current_win(win)
      end)
    end,
  })
  require('pretty-ts-errors').show_formatted_error()
end, { desc = 'Show diagnostic [E]rror messages', buffer = true })
