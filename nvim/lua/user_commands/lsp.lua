-- Restart all LSP clients for current buffer
local function restart_lsp_all()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients { bufnr = bufnr }
  local client_configs = {}

  -- Store client configurations before stopping
  for _, client in pairs(clients) do
    client_configs[client.name] = client.config
    vim.lsp.stop_client(client.id)
  end

  -- Wait a moment then restart with stored configs
  vim.defer_fn(function()
    for name, config in pairs(client_configs) do
      vim.lsp.start(config)
    end
  end, 500)
end

-- Restart specific LSP by name
local function restart_lsp_by_name(name)
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients { name = name, bufnr = bufnr }
  local config = nil

  -- Store the first matching client's config
  for _, client in pairs(clients) do
    config = client.config
    vim.lsp.stop_client(client.id)
    break
  end

  if not config then
    -- Try to get config from global LSP config if client wasn't attached to current buffer
    local all_clients = vim.lsp.get_clients { name = name }
    for _, client in pairs(all_clients) do
      config = client.config
      vim.lsp.stop_client(client.id)
      break
    end
  end

  vim.defer_fn(function()
    if config then
      vim.lsp.start(config)
    else
      -- Fallback to enable if no config found
      vim.lsp.enable(name)
      -- Force buffer to be re-evaluated
      vim.cmd 'edit'
    end
  end, 500)
end

-- Create user commands
vim.api.nvim_create_user_command('LspRestart', function(opts)
  if opts.args == '' then
    restart_lsp_all()
  else
    restart_lsp_by_name(opts.args)
  end
end, {
  nargs = '?',
  complete = function()
    local clients = vim.lsp.get_clients()
    local names = {}
    for _, client in pairs(clients) do
      table.insert(names, client.name)
    end
    return names
  end,
})

vim.api.nvim_create_user_command('LspRestartAll', restart_lsp_all, {})

vim.api.nvim_create_user_command('LspTrace', function()
  vim.lsp.log.set_level 'trace'
  require('vim.lsp.log').set_format_func(vim.inspect)
end, {})

vim.api.nvim_create_user_command('LspOpenLog', function()
  vim.cmd('tabnew ' .. vim.lsp.log.get_filename())
end, {})

vim.api.nvim_create_user_command('LspServerCapabilities', function()
  print(vim.inspect(vim.lsp.get_clients()[1].server_capabilities))
end, {})

-- Usage: :MoveToFile (will prompt for target file)
-- Implementation ported from typescript-langauge-server test file at
--   src/lsp-server.test.ts (test 'provides "Move to file" code action')
vim.api.nvim_create_user_command('MoveToFile', function()
  local bufnr = vim.api.nvim_get_current_buf()
  local ts_client = vim.lsp.get_clients({ bufnr = bufnr, name = 'typescript_language_server' })[1]

  if not ts_client then
    vim.notify('TypeScript language server not attached to buffer', vim.log.levels.WARN)
    return
  end

  local params = vim.lsp.util.make_range_params()
  params.context = { diagnostics = vim.diagnostic.get(0) }

  ts_client.request('textDocument/codeAction', params, function(err, result, ctx)
    if err then
      vim.notify('Error requesting code actions: ' .. err.message, vim.log.levels.ERROR)
      return
    end

    if not result or vim.tbl_isempty(result) then
      vim.notify('No code actions available', vim.log.levels.WARN)
      return
    end

    -- Find "Move to file" action
    local move_action = nil
    for _, action in ipairs(result) do
      if action.title == 'Move to file' then
        move_action = action
        break
      end
    end

    if not move_action or not move_action.command then
      vim.notify('Move to file action not available at cursor position', vim.log.levels.WARN)
      return
    end

    -- Use Snacks picker for file selection
    local completed = false
    Snacks.picker.smart {
      actions = {
        confirm = function(picker, item)
          if completed then
            return
          end
          completed = true
          picker:close()

          if not item then
            vim.notify('Move to file cancelled', vim.log.levels.INFO)
            return
          end

          vim.schedule(function()
            -- Get absolute path
            local target_file = vim.fn.fnamemodify(item.file, ':p')

            -- Create target file if it doesn't exist
            local target_exists = vim.fn.filereadable(target_file) == 1
            if not target_exists then
              vim.fn.writefile({}, target_file)
            end

            -- Open the target file in a buffer so tsserver knows about it
            local target_bufnr = vim.fn.bufadd(target_file)
            vim.fn.bufload(target_bufnr)

            -- Execute command with interactiveRefactorArguments
            local cmd = move_action.command
            local args = vim.deepcopy(cmd.arguments[1])
            args.interactiveRefactorArguments = { targetFile = target_file }

            ts_client.request('workspace/executeCommand', {
              command = cmd.command,
              arguments = { args },
            }, nil, bufnr)
          end)
        end,
      },
      on_close = function()
        if completed then
          return
        end
        completed = true
        vim.schedule(function()
          vim.notify('Move to file cancelled', vim.log.levels.INFO)
        end)
      end,
    }
  end)
end, {
  desc = 'Move symbol to another file (TypeScript) - Snacks picker',
})

vim.api.nvim_create_user_command('LspFixAll', function(opts)
  local kind = opts.args
  if kind == '' then
    vim.notify('Please specify a fix kind (e.g., source.removeUnusedImports.ts)', vim.log.levels.WARN)
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local ts_client = vim.lsp.get_clients({ bufnr = bufnr, name = 'typescript_language_server' })[1]

  if not ts_client then
    vim.notify('TypeScript language server not attached to buffer', vim.log.levels.WARN)
    return
  end

  local file = vim.api.nvim_buf_get_name(bufnr)
  local params = {
    command = '_typescript.applyFixAllCodeAction',
    arguments = {
      {
        type = 'file',
        action = kind,
        uri = vim.uri_from_fname(file),
      },
    },
  }

  ts_client.request('workspace/executeCommand', params, function(err, result)
    if err then
      vim.notify('Error applying fix: ' .. vim.inspect(err), vim.log.levels.ERROR)
    end
  end, bufnr)
end, {
  nargs = 1,
  desc = 'Apply all fixes of a certain kind (TypeScript)',
})

vim.api.nvim_create_user_command('LspSourceAction', function(opts)
  local kind = opts.args

  -- If no kind provided, show menu with all source actions
  if kind == '' then
    local clients = vim.lsp.get_clients { bufnr = 0 }
    local source_actions = {}

    for _, client in ipairs(clients) do
      if client.server_capabilities.codeActionProvider then
        local kinds = client.server_capabilities.codeActionProvider.codeActionKinds or {}
        for _, action in ipairs(kinds) do
          if vim.startswith(action, 'source.') then
            table.insert(source_actions, action)
          end
        end
      end
    end

    if #source_actions == 0 then
      vim.notify('No source actions available', vim.log.levels.WARN)
      return
    end

    vim.lsp.buf.code_action {
      context = {
        only = source_actions,
        diagnostics = vim.diagnostic.get(0),
      },
    }
    return
  end

  -- Apply specific source action directly
  -- For source actions, use full document range instead of cursor position
  local bufnr = vim.api.nvim_get_current_buf()
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  local params = {
    textDocument = vim.lsp.util.make_text_document_params(bufnr),
    range = {
      start = { line = 0, character = 0 },
      ['end'] = { line = line_count, character = 0 },
    },
    context = {
      diagnostics = vim.lsp.diagnostic.from(vim.diagnostic.get(bufnr)),
      only = { kind },
    },
  }

  -- Only send to TypeScript language server, not Copilot or other clients
  local ts_client = vim.lsp.get_clients({ bufnr = bufnr, name = 'typescript_language_server' })[1]

  if not ts_client then
    vim.notify('TypeScript language server not attached to buffer', vim.log.levels.WARN)
    return
  end

  ts_client.request('textDocument/codeAction', params, function(err, result)
    if err or not result or vim.tbl_isempty(result) then
      return -- Silently do nothing
    end

    for _, action in ipairs(result) do
      if action.edit then
        vim.lsp.util.apply_workspace_edit(action.edit, 'utf-8')
      elseif action.command then
        ts_client.request('workspace/executeCommand', action.command)
      end
    end
  end, bufnr)
end, {
  nargs = '?',
  desc = 'Apply TypeScript source action',
})
