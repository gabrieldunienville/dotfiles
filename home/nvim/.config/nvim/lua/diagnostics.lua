local M = {}

function M.get_diagnostics()
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr)

  -- Get file path relative to workspace root
  local file_path = vim.api.nvim_buf_get_name(bufnr)
  local cwd = vim.fn.getcwd()
  local relative_path = file_path:gsub('^' .. vim.pesc(cwd) .. '/', '')

  -- Get buffer info
  local buf_info = {
    file_path = relative_path,
    total_lines = vim.api.nvim_buf_line_count(bufnr),
    filetype = vim.api.nvim_buf_get_option(bufnr, 'filetype'),
    modified = vim.api.nvim_buf_get_option(bufnr, 'modified'),
  }

  if #diagnostics == 0 then
    return string.format(
      'File: %s (%s, %d lines%s)\nNo diagnostics found',
      buf_info.file_path,
      buf_info.filetype,
      buf_info.total_lines,
      buf_info.modified and ', modified' or ''
    )
  end

  local severity_map = {
    [1] = 'ERROR',
    [2] = 'WARNING',
    [3] = 'INFO',
    [4] = 'HINT',
  }

  local result = {
    string.format('File: %s (%s, %d lines%s)', buf_info.file_path, buf_info.filetype, buf_info.total_lines, buf_info.modified and ', modified' or ''),
    string.format('Found %d diagnostic(s):', #diagnostics),
    '',
  }

  for _, diag in ipairs(diagnostics) do
    local source = diag.source and string.format(' [%s]', diag.source) or ''
    table.insert(result, string.format('[%s] Line %d:%s %s', severity_map[diag.severity] or 'UNKNOWN', diag.lnum + 1, source, diag.message))
  end

  return table.concat(result, '\n')
end

function M.get_diagnostic_under_cursor()
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor_pos = vim.api.nvim_win_get_cursor(0)
  local line = cursor_pos[1] - 1 -- Convert to 0-based indexing
  local col = cursor_pos[2]

  -- Get file path relative to workspace root
  local file_path = vim.api.nvim_buf_get_name(bufnr)
  local cwd = vim.fn.getcwd()
  local relative_path = file_path:gsub('^' .. vim.pesc(cwd) .. '/', '')

  -- Get diagnostics for current line
  local diagnostics = vim.diagnostic.get(bufnr, { lnum = line })

  if #diagnostics == 0 then
    return string.format('File: %s\nLine %d, Column %d\nNo diagnostics found at cursor position', relative_path, line + 1, col + 1)
  end

  local severity_map = {
    [1] = 'ERROR',
    [2] = 'WARNING',
    [3] = 'INFO',
    [4] = 'HINT',
  }

  local result = {
    string.format('File: %s', relative_path),
    string.format('Line %d, Column %d', line + 1, col + 1),
    string.format('Found %d diagnostic(s) on this line:', #diagnostics),
    '',
  }

  for _, diag in ipairs(diagnostics) do
    local source = diag.source and string.format(' [%s]', diag.source) or ''
    local range = ''
    if diag.col and diag.end_col then
      range = string.format(' (columns %d-%d)', diag.col + 1, diag.end_col)
    elseif diag.col then
      range = string.format(' (column %d)', diag.col + 1)
    end

    table.insert(result, string.format('[%s]%s%s %s', severity_map[diag.severity] or 'UNKNOWN', source, range, diag.message))
  end

  return table.concat(result, '\n')
end

function M.capture_diagnostic_under_cursor()
  local diagnostic_info = M.get_diagnostic_under_cursor()
  -- Put in register
  vim.fn.setreg('+', diagnostic_info)
end

return M
