return {
  cmd = { 'ruff', 'server' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
  },
  settings = {
    -- Ruff language server settings go here
  },
}
