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

function _G.fold_xstate_2()
  vim.opt.foldtext = 'v:lua.custom_fold_text()'

  local parser = vim.treesitter.get_parser()
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Load query string from after/queries/typescript/xstate.scm
  local query = vim.treesitter.query.get('typescript', 'xstate')

  _G.fold_texts = {}

  for id, node, metadata in query:iter_captures(root, 0) do
    local capture_name = query.captures[id]
    if not capture_name:match '^_' then
      print('Capture:', capture_name)
      print('Node', node:type())
      print(vim.treesitter.get_node_text(node, 0))
      print('Metadata:', vim.inspect(metadata))
    end
  end
end

function _G.fold_xstate()
  vim.opt.foldtext = 'v:lua.custom_fold_text()'

  local parser = vim.treesitter.get_parser()
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Load query string from after/queries/typescript/xstate.scm
  local query = vim.treesitter.query.get('typescript', 'xstate')

  _G.fold_texts = {}

  -- Group captures by their match pattern
  local events = {}

  for pattern, match, metadata in query:iter_matches(root, 0) do
    local captures = {}
    for id, nodes in pairs(match) do
      local capture_name = query.captures[id]
      if not capture_name:match '^_' then
        captures[capture_name] = captures[capture_name] or {}
        for _, node in ipairs(nodes) do
          table.insert(captures[capture_name], node)
        end
      end
    end
    table.insert(events, captures)
  end

  for _, captures in pairs(events) do
    local captures_text = {}
    for id, nodes in pairs(captures) do
      if nodes and #nodes > 0 then
        captures_text[id] = {}
        for i, node in ipairs(nodes) do
          captures_text[id][i] = vim.treesitter.get_node_text(node, 0)
        end
      end
    end
    print('Captures text', vim.inspect(captures_text))

    local target = 'event'

    if captures[target] then
      print(vim.inspect(captures))
      local start_row, start_col, end_row, end_col = captures[target]:range()
      local original_line = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]
      local event_type = vim.treesitter.get_node_text(captures.event_key, 0)

      local before = original_line:sub(1, start_col)
      local after = original_line:sub(end_col + 1)
      local fold_text = before .. string.format('[ %s ]', event_type) .. after

      print(vim.inspect {
        captures = captures,
        start_row = start_row,
        end_row = end_row,
        original_line = original_line,
        event_type = event_type,
        fold_text = fold_text,
      })

      _G.fold_texts[start_row + 1] = fold_text

      vim.api.nvim_buf_call(0, function()
        vim.cmd(string.format('%d,%dfold', start_row + 1, end_row + 1))
      end)
    end
  end
end

function _G.fold_test()
  -- Set foldmethod temporarily
  vim.opt.foldmethod = 'manual'

  -- Set custom fold text
  vim.opt.foldtext = 'v:lua.custom_fold_text()'

  local parser = vim.treesitter.get_parser()
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Find individual object types with event properties
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

  _G.fold_texts = {}

  for pattern, match, metadata in query:iter_matches(root, 0) do
    local captures = parse_captures(match, query)
    local start_row, start_col, end_row, end_col = captures.event_object:range()

    -- Get the original line and replace object with event type
    local original_line = vim.api.nvim_buf_get_lines(0, start_row, start_row + 1, false)[1]
    -- local object_text = vim.treesitter.get_node_text(captures.event_object, 0)

    local event_type = vim.treesitter.get_node_text(captures.event_type, 0)

    -- For single-line objects, replace using column positions
    local before = original_line:sub(1, start_col)
    local after = original_line:sub(end_col + 1)
    local fold_text = before .. string.format('[ %s ]', event_type) .. after

    print(vim.inspect {
      original_line = original_line,
      event_type = event_type,
      fold_text = fold_text,
    })

    -- Create fold text by replacing object with [event_type]
    -- local fold_text = original_line:gsub(vim.pesc(object_text), replace_text)

    -- Store the complete fold text
    _G.fold_texts[start_row + 1] = fold_text

    vim.api.nvim_buf_call(0, function()
      vim.cmd(string.format('%d,%dfold', start_row + 1, end_row + 1))
    end)
  end
end

function _G.custom_fold_text()
  -- vim.v.foldstart
  -- vim.v.foldend
  -- vim.v.foldlevel

  -- print('custom fold text', vim.inspect(_G.fold_texts))

  return _G.fold_texts[vim.v.foldstart] or vim.fn.foldtext()
end

-- function _G.fold_test()
--   -- Set foldmethod temporarily
--   vim.opt.foldmethod = 'manual'
--
--   -- Set custom fold text
--   vim.opt.foldtext = 'v:lua.custom_fold_text()'
--
--   local parser = vim.treesitter.get_parser()
--   local tree = parser:parse()[1]
--   local root = tree:root()
--
--   -- Find individual object types with event properties
--   local query_str = [[
-- (object_type
--   (property_signature
--     name: (property_identifier) @prop_name
--     type: (type_annotation
--       (literal_type
--         (string
--           (string_fragment) @event_type)))
--     (#eq? @prop_name "type"))) @event_object
-- ]]
--
--   local query = vim.treesitter.query.parse('typescript', query_str)
--   print(vim.inspect(query.captures))
--   local event_folds = {}
--
--   for pattern, match, metadata in query:iter_matches(root, 0) do
--     local event_object_node = nil
--     local event_type_text = nil
--
--     for id, node in pairs(match) do
--       if node then
--         local capture_name = query.captures[id]
--         if capture_name == 'event_object' then
--           event_object_node = node
--         elseif capture_name == 'event_type' then
--           event_type_text = vim.treesitter.get_node_text(node, 0)
--         end
--       end
--       print(event_type_text)
--     end
--   end
--
--   for id, node, metadata in query:iter_captures(root, 0) do
--     -- print(vim.inspect(node))
--     local capture_name = query.captures[id]
--     local start_row, _, end_row, _ = node:range()
--
--     if capture_name == 'event_object' then
--       event_folds[start_row] = {
--         node = node,
--         start_row = start_row,
--         end_row = end_row,
--         event_type = 'unknown',
--         object_text = vim.treesitter.get_node_text(node, 0),
--       }
--     elseif capture_name == 'event_type' then
--       local text = vim.treesitter.get_node_text(node, 0)
--       -- Find the corresponding event_object
--       for obj_start_row, fold_data in pairs(event_folds) do
--         if obj_start_row <= start_row and start_row <= fold_data.end_row then
--           fold_data.event_type = text
--           break
--         end
--       end
--     end
--   end
--
--   -- Create folds
--   for _, fold_data in pairs(event_folds) do
--     print(string.format('Found event object "%s" at lines %d-%d', fold_data.event_type or 'unknown', fold_data.start_row + 1, fold_data.end_row + 1))
--
--     -- Store treesitter data for fold text
--     _G.fold_event_data = _G.fold_event_data or {}
--     _G.fold_event_data[fold_data.start_row + 1] = {
--       event_type = fold_data.event_type,
--       object_text = fold_data.object_text,
--     }
--
--     vim.api.nvim_buf_call(0, function()
--       vim.cmd(string.format('%d,%dfold', fold_data.start_row + 1, fold_data.end_row + 1))
--     end)
--   end
-- end
--
-- function _G.custom_fold_text()
--   local line_count = vim.v.foldend - vim.v.foldstart + 1
--   local fold_data = _G.fold_event_data and _G.fold_event_data[vim.v.foldstart]
--
--   local first_line = vim.fn.getline(vim.v.foldstart)
--
--   if fold_data and fold_data.event_type and fold_data.object_text then
--     -- Replace the object part with the event type in brackets
--     local replacement = string.format('[ %s ]', fold_data.event_type)
--     local result = first_line:gsub(vim.pesc(fold_data.object_text), replacement)
--     return result
--   else
--     return string.format('🔽 FOLD: %s (%d lines)', first_line:match '%w+' or 'unknown', line_count)
--   end
-- end
