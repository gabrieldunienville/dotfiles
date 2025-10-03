M = {}

function M.focus_float()
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.api.nvim_win_get_config(win).relative ~= '' then
      vim.api.nvim_set_current_win(win)
      break
    end
  end
end

return M
