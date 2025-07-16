vim.bo.syntax = "jinja.html"
vim.bo.filetype = "jinja.html"

if vim.fn.exists(":TSBufEnable") > 0 then
  vim.cmd("TSBufEnable highlight")
end
