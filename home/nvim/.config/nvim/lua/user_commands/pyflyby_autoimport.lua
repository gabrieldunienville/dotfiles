vim.api.nvim_create_user_command('PyflybyAutoImport', function(opts)

  vim.cmd 'w'
  local cmd = {
    'tidy-imports',
    vim.fn.expand '%',
    '--replace',
    '--black',
  }
  vim.fn.system(cmd)
  vim.cmd 'e'
end, {})
