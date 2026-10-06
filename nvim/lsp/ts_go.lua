-- https://neovim.io/doc/user/lsp.html#vim.lsp.Config
-- https://neovim.io/doc/user/lsp.html#vim.lsp.ClientConfig

-- TypeScript 7 (native, Go) language server. Since 7.0 GA (July 2026) it
-- ships in the standard package as `tsc --lsp`; `@typescript/native-preview`
-- (`tsgo`) is frozen at 7.0.0-dev.20260707 — nightlies are `typescript@next`.
--
--   npm install -g typescript@latest     (or typescript@next for nightlies)
--
--   sudo apt install inotify-tools
--
-- The native server does NOT watch the filesystem itself on Linux: it
-- registers `workspace/didChangeWatchedFiles` watchers and relies on the
-- editor to deliver them. Neovim disables that capability on Linux by
-- default, so files edited outside a buffer (generated .gen.ts, AI edits,
-- git) went stale until re-opened. Advertise it explicitly below; Neovim
-- then runs `inotifywait` (install inotify-tools — without it Neovim falls
-- back to a slow per-directory poller).
--
-- Even with inotify working, files that are open as Neovim buffers have a
-- second problem: the server uses the buffer content (via didChange) not
-- disk, so an external edit to a buffered file goes unnoticed. And even
-- after the buffer is reloaded (checktime + autoread), the server doesn't
-- send `workspace/diagnostic/refresh` after didChange — it only sends it
-- after didChangeWatchedFiles. Fix: on_attach sets up a per-buffer
-- FileChangedShellPost autocmd that re-pulls diagnostics for all attached
-- buffers after an external-edit reload. The user's init still needs a
-- checktime trigger (FocusGained/CursorHold) to drive the reload itself.

---@type vim.lsp.Config
return {
  cmd = { 'tsc', '--lsp', '--stdio' },
  capabilities = {
    workspace = {
      didChangeWatchedFiles = {
        dynamicRegistration = true,
        relativePatternSupport = true,
      },
      -- The server uses PULL diagnostics (`textDocument/diagnostic`). Neovim
      -- re-pulls only on didOpen/didChange of the buffer itself, so when a
      -- dependency changes on disk (a regenerated .gen.ts) the red squiggles
      -- stay stale until you type. The server asks for a re-pull with
      -- `workspace/diagnostic/refresh` IF the client advertises support —
      -- Neovim 0.11 advertises it for inlay hints and semantic tokens but
      -- not for diagnostics, and ships no handler; both added here.
      diagnostics = { refreshSupport = true },
    },
  },
  handlers = {
    ['workspace/diagnostic/refresh'] = function(_, _, ctx)
      local client = vim.lsp.get_client_by_id(ctx.client_id)
      if not client then
        return vim.NIL
      end
      for bufnr in pairs(client.attached_buffers) do
        if vim.api.nvim_buf_is_loaded(bufnr) then
          -- Same request Neovim's own pull path issues; the default
          -- `textDocument/diagnostic` handler publishes the result.
          client:request('textDocument/diagnostic', {
            textDocument = vim.lsp.util.make_text_document_params(bufnr),
          }, nil, bufnr)
        end
      end
      return vim.NIL
    end,
  },
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
    -- NOTE: this `tsserver` block is typescript-language-server configuration
    -- (kept from the ts_ls days); the native server ignores it — in
    -- particular `watchOptions` has no effect here, see the file watching
    -- note at the top.
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

    -- When an external tool (AI agent, build script) edits this file and
    -- autoread + checktime reloads the buffer, re-pull diagnostics for all
    -- attached buffers. ts_go sends diagnostic/refresh after
    -- didChangeWatchedFiles but not after didChange, so dependent buffers
    -- go stale without this.
    vim.api.nvim_create_autocmd('FileChangedShellPost', {
      buffer = bufnr,
      callback = function()
        vim.defer_fn(function()
          if client:is_stopped() then
            return
          end
          for b in pairs(client.attached_buffers) do
            if vim.api.nvim_buf_is_loaded(b) then
              client:request('textDocument/diagnostic', {
                textDocument = vim.lsp.util.make_text_document_params(b),
              }, nil, b)
            end
          end
        end, 100)
      end,
    })

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
