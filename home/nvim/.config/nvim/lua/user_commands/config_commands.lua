vim.api.nvim_create_user_command('ReloadKeymaps', function()
  package.loaded['keymaps'] = nil
  require 'keymaps'
end, {})
