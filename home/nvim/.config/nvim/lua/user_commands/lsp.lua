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
