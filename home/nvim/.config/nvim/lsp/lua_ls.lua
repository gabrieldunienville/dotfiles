return {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  -- Files that share a root directory will reuse
  -- the connection to the same LSP server.
  root_markers = { '.luarc.json', '.luarc.jsonc' },
  -- Specific settings to send to the server. The schema for this is
  -- defined by the server. For example the schema for lua-language-server
  -- can be found here https://raw.githubusercontent.com/LuaLS/vscode-lua/master/setting/schema.json
  settings = {
    Lua = {
      completion = {
        callSnippet = 'Replace',
      },
      diagnostics = {
        disable = {
          'missing-fields',
        },
        globals = {
          'vim',
        },
      },
      runtime = {
        version = 'LuaJIT',
      },
      -- workspace = {
      --   -- This is crucial for finding plugin type definitions
      --   library = vim.api.nvim_get_runtime_file('', true),
      --   checkThirdParty = false,
      -- },
      workspace = {
        library = {
          vim.env.VIMRUNTIME,
          vim.fn.stdpath 'data' .. '/lazy',
        },
        checkThirdParty = false,
        maxPreload = 100000,
        preloadFileSize = 10000,
      },
    },
  },
}
