return {
  'carbon-steel/detour.nvim',
  config = function()
    require('detour').setup {
      -- Put custom configuration here
    }
    vim.keymap.set('n', '<c-w><enter>', ':Detour<cr>')
    vim.keymap.set('n', '<c-w>.', ':DetourCurrentWindow<cr>')

    -- My TUI is slightly wider than the floating window it's in:
    --  This is something I noticed happening when I upgraded to Neovim 0.10.
    --  After you create your detour floating window, make sure to turn off signcolumn.
    vim.opt.signcolumn = 'no'

    vim.keymap.set('n', '<A-o>', function()
      local popup_id = require('detour').Detour()
      if popup_id then
        require('telescope.builtin').live_grep {
          cwd = vim.fs.joinpath(vim.env.VIMRUNTIME, 'doc'),
        }
      else
        local keys = vim.api.nvim_replace_termcodes(':h ', true, true, true)
        vim.api.nvim_feedkeys(keys, 'n', true)
      end
    end)
  end,
}
