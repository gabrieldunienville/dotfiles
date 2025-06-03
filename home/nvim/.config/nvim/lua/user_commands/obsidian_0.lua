function Search()
  local obsidian = require 'obsidian'
  local client = obsidian.get_client()
  local snacks = require 'snacks'

  client:find_notes_async('', function(all_notes)
    local entries = {}

    for _, note in ipairs(all_notes) do
      -- Create multiple searchable entries per note
      local searchable_terms = {}

      -- Add all aliases
      for _, alias in ipairs(note.aliases) do
        table.insert(searchable_terms, alias)
      end

      -- Add title
      if note.title then
        table.insert(searchable_terms, note.title)
      end

      -- Add note ID
      table.insert(searchable_terms, tostring(note.id))

      -- Add filename (without extension)
      if note.path then
        table.insert(searchable_terms, note.path.stem)
      end

      -- Create the ordinal (what gets searched) by combining all terms
      local ordinal = table.concat(searchable_terms, ' ')

      -- Display logic: prioritize alias, then title, then filename stem
      local display
      if #note.aliases > 0 then
        display = table.concat(note.aliases, ', ')
      elseif note.title then
        display = note.title
      else
        display = note.path and note.path.stem or tostring(note.id)
      end

      table.insert(entries, {
        text = display,
        item = note,
        match = ordinal, -- This is the searchable text
        file = tostring(note.path),
      })
    end

    vim.schedule(function()
      snacks.picker.pick {
        items = entries,
        title = string.format('Enhanced Quick Switch (%d notes)', #entries),
        on_select = function(item)
          client:open_note(item.item)
        end,
      }
    end)
  end, {
    search = { sort = true },
    notes = { max_lines = 100 },
  })
end

local function create_obsidian_picker(obsidian_files, opts)
  opts = opts or {}

  -- Transform your obsidian files into picker items
  local items = {} ---@type snacks.picker.Item[]
  for _, file_data in ipairs(obsidian_files) do
    table.insert(items, {
      file = file_data.path,
      text = file_data.alias or vim.fn.fnamemodify(file_data.path, ':t:r'), -- fallback to filename without extension
      alias = file_data.alias,
      path = file_data.path,
    })
  end

  -- Custom format function to display alias instead of filename
  local function obsidian_format(item, picker)
    local ret = {} ---@type snacks.picker.Highlight[]

    -- Add file icon if available
    if picker.opts.icons.files.enabled ~= false then
      local icon, hl = Snacks.util.icon('md', 'file', {
        fallback = picker.opts.icons.files,
      })
      icon = Snacks.picker.util.align(icon, picker.opts.formatters.file.icon_width or 2)
      ret[#ret + 1] = { icon, hl, virtual = true }
    end

    -- Display the alias as the main text
    ret[#ret + 1] = { item.alias or item.text, 'SnacksPickerFile', field = 'alias' }

    -- Optionally show the actual filename in a dimmed color
    if item.alias then
      ret[#ret + 1] = { ' ' }
      local filename = vim.fn.fnamemodify(item.path, ':t')
      ret[#ret + 1] = { '(' .. filename .. ')', 'SnacksPickerDimmed' }
    end

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

vim.api.nvim_create_user_command('ObSearch', Search, {})
