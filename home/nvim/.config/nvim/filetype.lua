-- vim.filetype.add({
--   extension = {
--     ["jinja.html"] = "jinja",
--   },
--
-- })
vim.filetype.add {
  extension = {
    jinja = 'jinja.html',
  },
  pattern = {
    ['.*%.jinja%.html'] = 'jinja.html',
  },
}
