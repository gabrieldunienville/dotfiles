return {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'pyrightconfig.json',
  },
  settings = {
    pyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        -- Ignore all files for analysis to exclusively use Ruff for linting
        -- ignore = { '*' },
      },
    },
  },
  handlers = {
    ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
      -- Filter out the specific await error
      if result and result.diagnostics then
        result.diagnostics = vim.tbl_filter(function(diagnostic)
          return not string.match(diagnostic.message, '"await" allowed only within async function')
        end, result.diagnostics)
      end

      -- Call the default handler with filtered diagnostics
      vim.lsp.diagnostic.on_publish_diagnostics(err, result, ctx, config)
    end,
  },
}
