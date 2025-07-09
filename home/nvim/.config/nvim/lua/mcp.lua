local M = {}

function M.get_diagnostics()
  local bufnr = vim.api.nvim_get_current_buf()
  local diagnostics = vim.diagnostic.get(bufnr)

  if #diagnostics == 0 then
    return 'No diagnostics found'
  end

  local severity_map = {
    [1] = 'ERROR',
    [2] = 'WARNING',
    [3] = 'INFO',
    [4] = 'HINT',
  }

  local result = {}
  for _, diag in ipairs(diagnostics) do
    table.insert(result, string.format('[%s] Line %d: %s', severity_map[diag.severity] or 'UNKNOWN', diag.lnum + 1, diag.message))
  end

  return table.concat(result, '\n')
end

return M
