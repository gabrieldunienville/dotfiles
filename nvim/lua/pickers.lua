local M = {}

---@class WorkspaceSymbolsFilteredOpts
---@field filter? fun(file: string, name: string): boolean Filter function for file paths
---@field format_path? fun(path: string): string Format function for display paths
---@field kinds? string[] List of symbol kinds to include (default: all kinds)

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

        if opts.filter and not opts.filter(relative_path, item.name) then
          return false
        end

        -- Format the display path
        item._display_path = relative_path
        if opts.format_path then
          item._display_path = opts.format_path(relative_path)
        end

        return item
      end,
      -- Custom format
      format = function(item, picker)
        -- local opts = picker.opts --[[@as snacks.picker.lsp.symbols.Config]]
        local ret = {}

        local kind = item.kind or 'Unknown'
        local kind_hl = 'SnacksPickerIcon' .. kind

        ret[#ret + 1] = { picker.opts.icons.kinds[kind], kind_hl }
        ret[#ret + 1] = { ' ' }

        -- Add symbol name with highlighting
        local name = vim.trim(item.name:gsub('\r?\n', ' '))
        name = name == '' and item.detail or name
        Snacks.picker.highlight.format(item, name, ret)

        local offset = Snacks.picker.highlight.offset(ret, { char_idx = true })
        ret[#ret + 1] = { Snacks.picker.util.align(' ', 40 - offset) }
        ret[#ret + 1] = { item._display_path, 'SnacksPickerFile' }

        return ret
      end,
      -- filter = {
      --   ['Class'] = true,
      --   ['Constant'] = true,
      -- },
      filter = opts.kinds and {
        default = opts.kinds,
      } or {},
    }
  end
end

return M
