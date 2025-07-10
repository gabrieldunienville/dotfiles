local M = {}

M.win_tab_map = {
  code = {
    tab_name = 'main',
    win_args = nil, -- is the initial window of tab
  },
  tools = {
    tab_name = 'main',
    win_args = {
      position = 'right',
      width = 0.5,
    },
  },
  terminal = {
    tab_name = 'terminal',
    win_args = nil,
  },
  git = {
    tab_name = 'terminal',
    win_args = {
      position = 'right',
      width = 0.5,
    },
  },
}

M.primary_win_by_tab = {}
for key, value in pairs(M.win_tab_map) do
  if value.win_args == nil then
    M.primary_win_by_tab[value.tab_name] = key
  end
end

return M
