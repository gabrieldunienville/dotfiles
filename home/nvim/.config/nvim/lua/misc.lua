-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '.envrc',
  command = 'set filetype=sh',
})


-- Temp
 -- vim.api.nvim_create_autocmd("BufEnter", {
 --   callback = function()
 --     local bufnr = vim.api.nvim_get_current_buf()
 --     local filetype = vim.bo[bufnr].filetype
 --     local formatters = require("conform").list_formatters_for_buffer(bufnr)
 --     print("File type: " .. filetype .. ", Available formatters: " .. vim.inspect(formatters))
 --   end
 -- })
--

-- Turn off built in markdown plugin as it interferes
vim.g.markdown_recommended_style = 0  -- Disables the built-in style settings


