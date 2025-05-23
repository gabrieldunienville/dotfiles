return {
  cmd = { 'basedpyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    '.git',
  },
  settings = {
    basedpyright = {
      analysis = {
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        diagnosticMode = 'openFilesOnly',
      },
    },
  },
}

-- Old settings
-- basedpyright = {
--   -- Using Ruff's import organizer
--   disableOrganizeImports = true,
--   analysis = {
--     autoSearchPaths = true,
--     useLibraryCodeForTypes = true,
--     diagnosticMode = 'openFilesOnly',
--     typeCheckingMode = 'strict',
--   },
-- },
-- python = {
--   analysis = {},
-- },
