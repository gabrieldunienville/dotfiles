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

function M.fold_xstate()
  -- vim.opt.foldmethod = 'manual'
  vim.opt.foldtext = 'v:lua.custom_fold_text()'

  local parser = vim.treesitter.get_parser()
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Load query string from after/queries/typescript/xstate.scm
  local query = vim.treesitter.query.get('typescript', 'xstate')

  _G.fold_texts = {}

  for pattern, match, metadata in query:iter_matches(root, 0) do
    local captures = parse_captures(match, query)
    local targets = { 'event', 'entry', 'invoke' }

    for _, target in ipairs(targets) do
      if captures[target] and captures[target][1] then
        local start_row, start_col, end_row, end_col = captures[target][1]:range()

        local original_line = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]
        local before = original_line:sub(1, start_col)
        -- local after = original_line:sub(end_col + 1)
        local num_lines = end_row - start_row + 1
        local fold_text = before .. '{' .. string.format('%d lines', num_lines) .. '}'

        -- print(vim.inspect {
        --   captures = captures,
        --   start_row = start_row,
        --   end_row = end_row,
        --   original_line = original_line,
        --   fold_text = fold_text,
        -- })

        _G.fold_texts[start_row + 1] = fold_text

        vim.api.nvim_buf_call(0, function()
          vim.cmd(string.format('%d,%dfold', start_row + 1, end_row + 1))
        end)
      end
    end
  end
end

function _G.custom_fold_text()
  -- vim.v.foldstart
  -- vim.v.foldend
  -- vim.v.foldlevel

  -- print('custom fold text', vim.inspect(_G.fold_texts))

  return _G.fold_texts[vim.v.foldstart] or vim.fn.foldtext()
end

return M
