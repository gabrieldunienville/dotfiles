function _G.fold_test()
  -- Set foldmethod temporarily
  vim.opt.foldmethod = 'manual'

  -- Set custom fold text
  vim.opt.foldtext = 'v:lua.custom_fold_text()'

  local parser = vim.treesitter.get_parser()
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Find event objects with type property and extract string value
  local query_str = [[
(object_type
  (property_signature
    name: (property_identifier) @prop_name
    type: (type_annotation
      (literal_type
        (string
          (string_fragment) @event_type)))
    (#eq? @prop_name "type"))) @event_object
]]

  local query = vim.treesitter.query.parse('typescript', query_str)
  local event_folds = {}

  for id, node, metadata in query:iter_captures(root, 0) do
    local capture_name = query.captures[id]
    local start_row, _, end_row, _ = node:range()

    if capture_name == 'event_object' then
      event_folds[start_row] = {
        node = node,
        start_row = start_row,
        end_row = end_row,
        event_type = 'unknown',
      }
    elseif capture_name == 'event_type' then
      local text = vim.treesitter.get_node_text(node, 0)
      -- Find the corresponding event_object
      for obj_start_row, fold_data in pairs(event_folds) do
        if obj_start_row <= start_row and start_row <= fold_data.end_row then
          fold_data.event_type = text
          break
        end
      end
    end
  end

  -- Create folds
  for _, fold_data in pairs(event_folds) do
    print(string.format('Found event object "%s" at lines %d-%d', fold_data.event_type or 'unknown', fold_data.start_row + 1, fold_data.end_row + 1))

    -- Store event type for fold text
    _G.fold_event_types = _G.fold_event_types or {}
    _G.fold_event_types[fold_data.start_row + 1] = fold_data.event_type

    vim.api.nvim_buf_call(0, function()
      vim.cmd(string.format('%d,%dfold', fold_data.start_row + 1, fold_data.end_row + 1))
    end)
  end
end

function _G.custom_fold_text()
  local line_count = vim.v.foldend - vim.v.foldstart + 1
  local event_type = _G.fold_event_types and _G.fold_event_types[vim.v.foldstart]
  local first_line = vim.fn.getline(vim.v.foldstart)

  if event_type then
    -- Extract the indentation and | from the original line
    local indent = first_line:match '^%s*'
    local has_pipe = first_line:match '^%s*|'

    if has_pipe then
      return string.format('%s| [ %s ]', indent, event_type)
    else
      return string.format('%s[ %s ]', indent, event_type)
    end
  else
    return string.format('🔽 FOLD: %s (%d lines)', first_line:match '%w+' or 'unknown', line_count)
  end
end
