return {
  cmd = { 'pyright-langserver', '--stdio' },
  filetypes = { 'python' },
  root_markers = {
    'pyproject.toml',
    'pyrightconfig.json',
  },
  settings = {
    -- These are LSP level settings
    -- See https://microsoft.github.io/pyright/#/settings
    pyright = {
      -- Using Ruff's import organizer
      disableOrganizeImports = true,
    },
    python = {
      analysis = {
        -- Options:
        --  https://microsoft.github.io/pyright/#/configuration?id=type-check-diagnostics-settings
        diagnosticSeverityOverrides = {
          reportUndefinedVariable = 'none',
          reportUnusedVariable = 'none',
        },
      },
    },
  },
  handlers = {
    ['textDocument/publishDiagnostics'] = function(err, result, ctx, config)
      -- Filter out the specific await error
      -- Note: This is a hack because Pyright does not support disabling this diagnostic
      -- The purpose is to to be used in ipython scripts
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
