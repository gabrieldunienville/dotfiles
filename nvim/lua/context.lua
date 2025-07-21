local M = {}

function M.get_visual_bounds()
  -- Use 'v' for visual start and '.' for current cursor position
  local _, start_row, start_col, _ = unpack(vim.fn.getpos 'v')
  local _, end_row, end_col, _ = unpack(vim.fn.getpos '.')

  -- Ensure start comes before end
  if start_row > end_row or (start_row == end_row and start_col > end_col) then
    start_row, end_row = end_row, start_row
    start_col, end_col = end_col, start_col
  end

  return start_row, end_row, start_col, end_col
end

function M.get_visual_selection()
  local start_row, end_row, start_col, end_col = M.get_visual_bounds()

  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)

  if #lines == 1 then
    -- For single line, handle visual mode properly
    local mode = vim.fn.mode()
    if mode == 'V' then
      -- Visual line mode - return full line
      return lines[1]
    else
      -- Visual character mode - extract substring
      return lines[1]:sub(start_col, end_col)
    end
  else
    -- Check if we're in visual line mode
    local mode = vim.fn.mode()
    if mode == 'V' then
      -- Visual line mode - return full lines
      return table.concat(lines, '\n')
    else
      -- Visual character mode - handle partial lines
      lines[1] = lines[1]:sub(start_col)
      lines[#lines] = lines[#lines]:sub(1, end_col)
      return table.concat(lines, '\n')
    end
  end
end

function M.get_selection_context()
  local selection = M.get_visual_selection()
  if selection == '' then
    return 'No selection'
  end

  local path = vim.fn.expand '%:~:.'
  local file_type = vim.bo.filetype
  local start_row, end_row, _, _ = M.get_visual_bounds()

  local context = string.format(
    [[
Path: @%s
Lines: %d-%d
```%s
%s
```
]],
    path,
    start_row,
    end_row,
    file_type,
    selection
  )

  return context
end

function M.get_file_context()
  local rel_path = vim.fn.expand '%:~:.'
  return string.format('@%s', rel_path)
end

return M
