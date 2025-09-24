local M = {}

---@class WorkspaceSymbolsFilteredOpts
---@field filter? fun(file: string): boolean Filter function for file paths
---@field format_path? fun(path: string): string Format function for display paths

---@param opts? WorkspaceSymbolsFilteredOpts
function M.workspace_symbols_filtered(opts)
  opts = opts or {}
  return function()
    Snacks.picker.lsp_workspace_symbols {
      transform = function(item, ctx)
        local cwd = ctx.filter.cwd

        -- Make path relative to cwd if it's absolute and within cwd
        local relative_path = item.file
        if vim.startswith(item.file, cwd) then
          relative_path = item.file:sub(#cwd + 2) -- +2 to remove cwd + "/"
        end

        if opts.filter and not opts.filter(relative_path) then
          return false
        end

        -- Format the display path
        item._display_path = relative_path
        if opts.format_path then
          item._display_path = opts.format_path(relative_path)
        end

        return item
      end,
      tree = true,
      -- Custom format
      format = function(item, picker)
        local opts = picker.opts --[[@as snacks.picker.lsp.symbols.Config]]
        local name_hl = 'SnacksPickerMatch'

        -- Pick highlight color based on symbol kind
        local kind_hl = '@lsp.type.' .. (item.kind_name or ''):lower()
        local ret = {
          { item.name, name_hl },
          { '  ', 'Comment' },
          { item.kind_name or '', kind_hl },
        }

        if item._display_path then
          table.insert(ret, { '  ' .. item._display_path, 'Comment' })
        end

        return ret
      end,
    }
  end
end

return M
