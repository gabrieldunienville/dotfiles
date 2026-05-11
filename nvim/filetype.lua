vim.filetype.add {
  filename = {
    ['dot-zshrc'] = 'zsh',
  },
  pattern = {
    ['.*%.jinja%.html'] = 'jinja.html',
    ['.*%.jinja%.xml'] = 'jinja.xml',
    ['.envrc'] = 'sh',
    ['%.envrc%..*'] = 'sh',
    ['.env.local'] = 'sh',
  },
}
