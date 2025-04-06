vim.filetype.add {
  -- extension = {
  --   jinja = 'jinja.html',
  -- },
  pattern = {
    ['.*%.jinja%.html'] = 'jinja.html',
    ['.*%.jinja%.xml'] = 'jinja.xml',
  },
}
