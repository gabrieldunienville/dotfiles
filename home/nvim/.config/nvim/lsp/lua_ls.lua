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
      diagnostics = { disable = { 'missing-fields' } },
      -- Not sure if needed
      -- runtime = {
      --   version = 'LuaJIT',
      -- },
    },
  },
}
