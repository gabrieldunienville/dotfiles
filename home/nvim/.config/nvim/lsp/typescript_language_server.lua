return {
  cmd = { 'typescript-language-server', '--stdio' },
  filetypes = {
    'typescript',
    'typescriptreact',
    'javascript',
    'javascriptreact',
  },
  root_markers = {
    'turbo.json',
    '.git',
    'package.json',
  },
  init_options = {
    hostInfo = {
      name = 'neovim',
    },
    preferences = {
      includePackageJsonAutoImports = 'on',
      -- importModuleSpecifierPreference = 'non-relative',
      -- importModuleSpecifierEnding = 'minimal', -- or 'index', 'js'
    },
  },
  settings = {
    typescript = {
      inlayHints = {
        includeInlayParameterNameHints = 'all',
        includeInlayParameterNameHintsWhenArgumentMatchesName = false,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
      },
      -- Critical for monorepos
      tsserver = {
        useSyntaxServer = 'never',
        maxTsServerMemory = 8192,
        watchOptions = {
          watchFile = 'useFsEvents',
          watchDirectory = 'useFsEvents',
          fallbackPolling = 'dynamicPriority',
          excludeDirectories = { '**/node_modules', '**/dist', '**/.turbo' },
          excludeFiles = { '**/node_modules/**' },
        },
      },
    },
  },
}
