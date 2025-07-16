local M = {}

function M.dump_tree()
  local bufnr = vim.api.nvim_get_current_buf()
  local language = vim.bo.filetype
  local lang_tree = vim.treesitter.get_parser(bufnr, language)
  local tree = lang_tree:parse()[1]
  local root = tree:root()

  print('File type: ' .. language)
  print('Language tree: ' .. vim.inspect(vim.treesitter.language.get_lang(language)))

  local function dump_node(node, depth, name)
    if not node then
      return
    end

    local node_type = node:type()
    local text = vim.treesitter.get_node_text(node, bufnr)
    if text and #text > 20 then
      text = text:sub(1, 17) .. '...'
    end

    local prefix = string.rep('  ', depth)
    print(prefix .. (name or '') .. ' (' .. node_type .. ')' .. (text and ': ' .. text or ''))

    for child_node, child_name in node:iter_children() do
      dump_node(child_node, depth + 1, child_name)
    end
  end

  dump_node(root, 0, 'root')

  -- Also print injection queries
  local lang = vim.treesitter.language.get_lang(language)
  if lang then
    print('\nInjection queries for ' .. lang .. ':')
    local query = vim.treesitter.query.get_query(lang, 'injections')
    if query then
      print(query)
    else
      print 'No injection queries found'
    end
  end
end

return M
