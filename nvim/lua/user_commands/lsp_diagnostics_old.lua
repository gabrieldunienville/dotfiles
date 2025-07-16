local buf_utils = require 'codecompanion.utils.buffers'

local function print_table(t, indent)
  indent = indent or 0
  for k, v in pairs(t) do
    if type(v) == 'table' then
      print(string.rep('  ', indent) .. k .. ':')
      print_table(v, indent + 1)
    else
      print(string.rep('  ', indent) .. k .. ': ' .. tostring(v))
    end
  end
end

function GetDiagnostics()
  local severity = {
    [1] = 'ERROR',
    [2] = 'WARNING',
    [3] = 'INFORMATION',
    [4] = 'HINT',
  }

  local bufnr = vim.api.nvim_get_current_buf()
  print('Buffer:', bufnr)

  local winnr = vim.api.nvim_get_current_win()
  print('Current window number:', winnr)

  local cursor = vim.api.nvim_win_get_cursor(winnr)
  print('Current cursor position:', cursor)
  print_table(cursor)

  local diagnostics = vim.diagnostic.get(bufnr, {
    severity = { min = vim.diagnostic.severity.HINT },
  })
  print('Found', diagnostics)

  -- Add code to the diagnostics
  for _, diagnostic in ipairs(diagnostics) do
    for i = diagnostic.lnum, diagnostic.end_lnum do
      if not diagnostic.lines then
        diagnostic.lines = {}
      end
      table.insert(diagnostic.lines, string.format('%d: %s', i + 1, vim.trim(buf_utils.get_content(bufnr, { i, i + 1 }))))
    end
  end

  local formatted = {}
  for _, diagnostic in ipairs(diagnostics) do
    table.insert(
      formatted,
      string.format(
        [[
  Severity: %s
  LSP Message: %s
  Code:
  ```%s
  %s
  ```
  ]],
        severity[diagnostic.severity],
        diagnostic.message,
        'lua',
        table.concat(diagnostic.lines, '\n')
      )
    )
  end

  local output = table.concat(formatted, '\n\n')
  print('LSP Diagnostics:\n' .. output)

  return output
end

vim.api.nvim_create_user_command(
  'GetDiagnostics',
  function()
    local output = GetDiagnostics()
    vim.api.nvim_out_write(output .. '\n')
  end,
  { desc = 'Get LSP diagnostics for the current buffer' }
)
