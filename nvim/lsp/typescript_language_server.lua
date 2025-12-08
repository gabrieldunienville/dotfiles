-- https://neovim.io/doc/user/lsp.html#vim.lsp.Config
-- https://neovim.io/doc/user/lsp.html#vim.lsp.ClientConfig

-- LSPConfig is also a good config reference
-- https://github.com/neovim/nvim-lspconfig/blob/master/lsp/ts_ls.lua
--
-- npm install -g typescript-language-server typescript

---@type vim.lsp.Config
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
  -- capabilities = {
  --   textDocument = {
  --     semanticTokens = nil,
  --   },
  -- },
  init_options = {
    -- https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md#initializationoptions
    hostInfo = {
      name = 'neovim',
    },
    maxTsServerMemory = 8192,
    preferences = {
      includePackageJsonAutoImports = 'on',
      -- importModuleSpecifierPreference = 'non-relative',
      -- importModuleSpecifierEnding = 'minimal', -- or 'index', 'js'
    },
    -- The "Move to file" code action is different from other code actions as it is interactive (it needs to ask the
    -- user for a file path) and therefore requires custom implementation in the client.
    --  I've implemented this in neveom via custom user command :MoveToFile
    supportsMoveToFileCodeAction = true,
    tsserver = {
      -- Spawn both a full server and a lighter weight server dedicated to syntax operations.
      -- The syntax server is used to speed up syntax operations and provide IntelliSense
      -- while projects are loading.
      useSyntaxServer = 'auto',
      watchOptions = {
        watchFile = 'useFsEvents',
        watchDirectory = 'useFsEvents',
        fallbackPolling = 'dynamicPriority',
        excludeDirectories = { '**/node_modules', '**/dist', '**/.turbo' },
        excludeFiles = { '**/node_modules/**' },
      },
      -- TODO: make these dynamically configurable
      logDirectory = '.log',
      -- Verbosity of the information logged into the tsserver log files. Log levels from least to most amount
      -- of details: 'off', 'terse', 'normal', 'requestTime', 'verbose'. Default: 'off'
      -- logVerbosity = 'verbose',
      -- The verbosity of logging of the tsserver communication. Delivered through the LSP messages and not
      -- related to file logging. Allowed values are: 'off', 'messages', 'verbose'. Default: 'off'
      -- trace = 'verbose',
    },
  },
  -- Sent as response when server sends workspace/configuration request
  -- TODO: these are probably not the right schema
  settings = {
    -- https://github.com/typescript-language-server/typescript-language-server/blob/master/docs/configuration.md#workspacedidchangeconfiguration
    typescript = {
      -- inlayHints = {
      --   includeInlayParameterNameHints = 'all',
      --   includeInlayParameterNameHintsWhenArgumentMatchesName = false,
      --   includeInlayFunctionParameterTypeHints = true,
      --   includeInlayVariableTypeHints = true,
      -- },
    },
  },
  on_attach = function(client, bufnr)
    -- Doesn't seem to do anything, so updating server capabilities directly
    -- vim.lsp.semantic_tokens.stop(bufnr, client.id)

    client.server_capabilities.semanticTokensProvider = nil

    -- TODO: add these to normal code actions at `gra` or make key binding
    -- ts_ls provides `source.*` code actions that apply to the whole file. These only appear in
    -- `vim.lsp.buf.code_action()` if specified in `context.only`.
    -- vim.api.nvim_buf_create_user_command(bufnr, 'LspTypescriptSourceAction', function()
    --   local source_actions = vim.tbl_filter(function(action)
    --     return vim.startswith(action, 'source.')
    --   end, client.server_capabilities.codeActionProvider.codeActionKinds)
    --
    --   vim.lsp.buf.code_action {
    --     context = {
    --       only = source_actions,
    --     },
    --   }
    -- end, {})
  end,
}
