local size = 2
vim.bo.tabstop = size -- size of a hard tabstop (ts).
vim.bo.shiftwidth = size -- size of an indentation (sw).
vim.bo.expandtab = true -- always uses spaces instead of tab characters (et)
vim.bo.softtabstop = size -- number of spaces a <Tab> counts for. When 0, feature is off (sts).

vim.keymap.set('n', '<leader>e', function()
  require('pretty-ts-errors').show_formatted_error()
  vim.defer_fn(function()
    require('windows').focus_float()
  end, 50)
end, { desc = 'Show diagnostic [E]rror messages', buffer = true })
