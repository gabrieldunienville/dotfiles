local M = {}

local function parse_captures(match, query)
  local captures = {}
  for id, nodes in pairs(match) do
    local capture_name = query.captures[id]
    if not capture_name:match '^_' then
      captures[capture_name] = captures[capture_name] or {}
      for _, node in ipairs(nodes) do
        if node then
          table.insert(captures[capture_name], node)
        end
      end
    end
  end
  return captures
end

local function refresh_fold_state()
  local parser = vim.treesitter.get_parser()
  local tree = parser:parse()[1]
  local root = tree:root()
  local query = vim.treesitter.query.get('typescript', 'xstate')

  _G.fold_state = {}

  local targets = { 'event', 'entry', 'invoke', 'setup_action', 'context_init' }
  for pattern, match, metadata in query:iter_matches(root, 0) do
    local captures = parse_captures(match, query)

    for _, target in ipairs(targets) do
      if captures[target] and captures[target][1] then
        local start_row, start_col, end_row, end_col = captures[target][1]:range()

        local original_line = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]
        local before = original_line:sub(1, start_col)
        local num_lines = end_row - start_row + 1
        local fold_text = before .. '{' .. string.format('%d lines', num_lines) .. '}'

        _G.fold_state[start_row + 1] = {
          text = fold_text,
          start_row = start_row + 1,
          end_row = end_row + 1,
        }
      end
    end
  end
end

function M.fold_xstate()
  vim.opt.foldtext = 'v:lua.custom_fold_text()'

  refresh_fold_state()

  for _, state in pairs(_G.fold_state) do
    vim.api.nvim_buf_call(0, function()
      vim.cmd(string.format('%d,%dfold', state.start_row, state.end_row))
    end)
  end

  -- Set up autocmd to refresh fold texts when buffer changes
  local group = vim.api.nvim_create_augroup('XStateFolding', { clear = true })
  vim.api.nvim_create_autocmd({ 'TextChanged', 'TextChangedI' }, {
    buffer = 0,
    group = group,
    callback = refresh_fold_state,
    desc = 'Refresh custom fold texts after text changes',
  })
end

function _G.custom_fold_text()
  -- vim.v.foldstart
  -- vim.v.foldend
  -- vim.v.foldlevel

  return _G.fold_state[vim.v.foldstart].text or vim.fn.foldtext()
end

return M
