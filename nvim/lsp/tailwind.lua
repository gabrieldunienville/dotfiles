return {
  cmd = { 'tailwindcss-language-server', '--stdio' },
  filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'svelte' },
  root_markers = {
    'turbo.json',
    '.git',
    'package.json',
  },
  settings = {},
}
