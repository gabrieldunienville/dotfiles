function Search()
  local obsidian = require 'obsidian'
  local client = obsidian.get_client()

  client:find_notes_async('', function(all_notes)
    local items = {} ---@type snacks.picker.Item[]

    for _, note in ipairs(all_notes) do
      local searchable_terms = {}

      for _, alias in ipairs(note.aliases) do
        table.insert(searchable_terms, alias)
      end

      ---@type snacks.picker.Item
      local item = {
        -- Required
        text = table.concat(searchable_terms, ' '),
        path = note.path,
        -- Custom
        id = note.id,
        alias = note.aliases[1] or nil, -- Use the first alias as the main text
        tags = note.tags,
      }

      table.insert(items, item)
    end
  end, {
    search = { sort = true },
    notes = { max_lines = 100 },
  })
end

local function create_obsidian_picker(items, opts)
  opts = opts or {}

  -- Custom format function to display alias instead of filename
  local function obsidian_format(item, picker)
    local ret = {} ---@type snacks.picker.Highlight[]

    -- Add file icon if available
    if picker.opts.icons.files.enabled ~= false then
      local icon, hl = Snacks.util.icon('md', 'file', {
        fallback = picker.opts.icons.files,
      })
      icon = Snacks.picker.util.align(icon, picker.opts.formatters.file.icon_width or 2)
      ret[#ret + 1] = {
        icon,
        hl,
        virtual = true,
      }
    end

    -- Display the alias as the main text
    ret[#ret + 1] = {
      item.alias or item.text,
      'SnacksPickerFile',
      field = 'alias',
    }

    -- -- Optionally show the actual filename in a dimmed color
    -- if item.alias then
    --   ret[#ret + 1] = { ' ' }
    --   local filename = vim.fn.fnamemodify(item.path, ':t')
    --   ret[#ret + 1] = { '(' .. filename .. ')', 'SnacksPickerDimmed' }
    -- end

    return ret
  end

  return Snacks.picker.pick(vim.tbl_deep_extend('force', {
    title = 'Obsidian Files',
    items = items,
    format = obsidian_format,
    preview = 'file', -- This will preview the actual markdown file
    -- Make search work on both alias and filename
    matcher = {
      fuzzy = true,
      smartcase = true,
      ignorecase = true,
    },
  }, opts))
end

vim.api.nvim_create_user_command('ObSearch', functon, {})
