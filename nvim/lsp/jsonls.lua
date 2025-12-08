--- Install:
--- npm i -g vscode-langservers-extracted

---@type vim.lsp.Config
return {
  { 'vscode-json-language-server', '--stdio' },
  filetypes = { 'json', 'jsonc' },
  root_markers = {
    '.git',
  },
  init_options = {
    provideFormatter = true,
  },
}
