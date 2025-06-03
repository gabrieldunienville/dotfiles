function Search()
  local obsidian = require 'obsidian'
  local client = obsidian.get_client()
  local picker = client:picker()

  if not picker then
    vim.notify('No picker configured', vim.log.levels.ERROR)
    return
  end

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

      -- Display format showing the most relevant info
      local display_name = note:display_name()
      local display

      if #note.aliases > 0 then
        -- display = string.format('%s [%s]', display_name, table.concat(note.aliases, ', '))
        display = table.concat(note.aliases, ', ')
        vim.notify 'Using alias'
      else
        display = display_name
      end

      table.insert(entries, {
        value = note,
        display = display,
        ordinal = ordinal, -- This is the searchable text
        filename = tostring(note.path),
      })
    end

    vim.schedule(function()
      picker:pick(entries, {
        prompt_title = string.format('Enhanced Quick Switch (%d notes)', #entries),
        callback = function(note)
          client:open_note(note)
        end,
      })
    end)
  end, {
    search = { sort = true },
    notes = { max_lines = 100 },
  })
end

vim.api.nvim_create_user_command('ObSearch', Search, {})
