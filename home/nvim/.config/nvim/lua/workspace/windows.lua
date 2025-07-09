local M = {}

local win_tab_map = {
  code = 'main',
  tools = 'main',
  terminal = 'terminal',
}

function M.open_window(window_name)
  local tab_name = win_tab_map[window_name]
  if not tab_name then
    error('No tab mapping found for window: ' .. window_name)
  end

end
