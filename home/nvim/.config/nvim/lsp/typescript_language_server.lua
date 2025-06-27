return {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = {
    'typescript',
    'typescriptreact',
    'javascript',
    'javascriptreact',
  },
  root_markers = {
    'package.json',
    'tsconfig.json',
    '.git',
  },
  -- init_options = {
  --   preferences = {
  --     disableSuggestions = false,
  --   },
  -- },
  settings = {
    -- typescript = {
    --   inlayHints = {
    --     includeInlayParameterNameHints = 'all',
    --     includeInlayParameterNameHintsWhenArgumentMatchesName = false,
    --     includeInlayFunctionParameterTypeHints = true,
    --     includeInlayVariableTypeHints = true,
    --     includeInlayPropertyDeclarationTypeHints = true,
    --     includeInlayFunctionLikeReturnTypeHints = true,
    --     includeInlayEnumMemberValueHints = true,
    --   },
    -- },
    -- javascript = {
    --   inlayHints = {
    --     includeInlayParameterNameHints = 'all',
    --     includeInlayParameterNameHintsWhenArgumentMatchesName = false,
    --     includeInlayFunctionParameterTypeHints = true,
    --     includeInlayVariableTypeHints = true,
    --     includeInlayPropertyDeclarationTypeHints = true,
    --     includeInlayFunctionLikeReturnTypeHints = true,
    --     includeInlayEnumMemberValueHints = true,
    --   },
    -- },
  },
}
