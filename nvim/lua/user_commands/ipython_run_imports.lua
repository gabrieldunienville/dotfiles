local M = {}

function M.extract_python_imports()
  -- This will use Tree-sitter to extract imports
  local has_ts, ts_parsers = pcall(require, 'nvim-treesitter.parsers')
  if not has_ts then
    vim.notify('nvim-treesitter is required for this plugin', vim.log.levels.ERROR)
    return {}
  end

  -- Ensure Python parser is installed
  local lang = 'python'
  if not ts_parsers.has_parser(lang) then
    vim.notify('Python parser not installed for Tree-sitter', vim.log.levels.ERROR)
    return {}
  end

  -- Get current buffer content
  local bufnr = vim.api.nvim_get_current_buf()

  -- Get language tree for the current buffer
  local parser = vim.treesitter.get_parser(bufnr, lang)
  local tree = parser:parse()[1]
  local root = tree:root()

  -- Use Tree-sitter query to find import statements
  local query_str = [[
    (import_statement) @import
    (import_from_statement) @import
  ]]

  local query = vim.treesitter.query.parse(lang, query_str)

  local imports = {}
  for id, node in query:iter_captures(root, bufnr, 0, -1) do
    local name = query.captures[id] -- should be "import"
    if name == 'import' then
      local start_row, _, end_row, _ = node:range()

      -- Extract the text for this node
      local lines = vim.api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
      table.insert(imports, table.concat(lines, '\n'))
    end
  end

  return imports
end

-- Create a user command
vim.api.nvim_create_user_command('IPythonRunImports', function()
  local python_imports = M.extract_python_imports()

  if python_imports and #python_imports > 0 then
    local import_text = table.concat(python_imports, '\n')
    vim.fn['slime#send'](import_text .. '\r')
  else
    vim.notify('No Python imports found', vim.log.levels.WARN)
  end
end, {})

vim.api.nvim_set_keymap('n', '<A-z>', ':IPythonRunImports<CR>', { noremap = true, silent = true, desc = 'Run Imports in Ipython' })

return M
