vim.api.nvim_create_user_command('ReloadModule', function(opts)
  local module_name = opts.args
  if module_name == '' then
    vim.notify('Usage: :ReloadModule <module_name>', vim.log.levels.ERROR)
    return
  end

  package.loaded[module_name] = nil
  local success, err = pcall(require, module_name)
  if success then
    vim.notify(string.format('Module "%s" reloaded successfully', module_name), vim.log.levels.INFO)
  else
    vim.notify(string.format('Failed to reload module "%s": %s', module_name, err), vim.log.levels.ERROR)
  end
end, {
  nargs = 1,
  complete = function(arg_lead, cmd_line, cursor_pos)
    -- Basic completion for common modules
    local modules = {
      'keymaps',
      'plugins',
      'options',
      'autocmds',
      'lsp',
      'terminal',
      'mcp',
    }

    return vim.tbl_filter(function(module)
      return string.sub(module, 1, string.len(arg_lead)) == arg_lead
    end, modules)
  end,
})
