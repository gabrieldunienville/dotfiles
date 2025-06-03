-- Obsidian picker with proper async handling

local function create_obsidian_picker(items, opts)
  opts = opts or {}

  -- Custom format function to display alias instead of filename
  local function obsidian_format(item, picker)
    local ret = {} ---@type snacks.picker.Highlight[]

    -- Add file icon if available
    if picker.opts.icons.files.enabled ~= false then
      -- local icon, hl = Snacks.util.icon('md', 'file', {
      --   fallback = picker.opts.icons.files,
      -- })
      local filename = vim.fn.fnamemodify(item.file, ':t') -- Gets "note.md"
      local icon, hl = Snacks.util.icon(filename, 'file', {
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

    if item.tags and #item.tags > 0 then
      ret[#ret + 1] = {
        col = 0,
        virt_text = {
          { ' ', 'Normal' }, -- Padding
          {
            table.concat(
              vim.tbl_map(function(tag)
                return '#' .. tag
              end, item.tags),
              ' '
            ),
            'SnacksPickerComment',
          },
          { ' ', 'Normal' }, -- Padding
        },
        virt_text_pos = 'right_align',
        hl_mode = 'combine',
      }
    end

    return ret
  end

  return Snacks.picker.pick(vim.tbl_deep_extend('force', {
    title = 'Obsidian Notes',
    items = items,
    format = obsidian_format,
    preview = 'file', -- This will preview the actual markdown file
    matcher = {
      fuzzy = true,
      smartcase = true,
      ignorecase = true,
    },
  }, opts))
end

-- Main search function that handles the async operation
function Search(tag)
  local obsidian = require 'obsidian'
  local client = obsidian.get_client()

  client:find_notes_async('', function(all_notes)
    -- Process notes into picker items
    local items = {} ---@type snacks.picker.Item[]

    for _, note in ipairs(all_notes) do
      if tag == nil or (note.tags and vim.tbl_contains(note.tags, tag)) then
        local searchable_terms = {}

        -- Add aliases to searchable terms
        for _, alias in ipairs(note.aliases or {}) do
          table.insert(searchable_terms, alias)
        end

        -- Add filename without extension as fallback
        local filename = vim.fn.fnamemodify(tostring(note.path), ':t:r')
        table.insert(searchable_terms, filename)

        ---@type snacks.picker.Item
        local item = {
          -- Required fields
          text = table.concat(searchable_terms, ' '),
          file = tostring(note.path), -- Snacks expects 'file' not 'path'

          -- Custom fields
          id = note.id,
          alias = (note.aliases and note.aliases[1]) or filename,
          tags = note.tags or {},
          path = note.path, -- Keep original if you need it
        }

        table.insert(items, item)
      end
    end

    -- Create and show the picker on the main thread
    vim.schedule(function()
      if #items == 0 then
        Snacks.notify.warn('No Obsidian notes found', { title = 'Obsidian Picker' })
        return
      end

      create_obsidian_picker(items)
    end)
  end, {
    search = { sort = true },
    notes = { max_lines = 100 },
  })
end

vim.api.nvim_create_user_command('ObSearch', function(opts)
  Search(opts.args)
end, {
  desc = 'Search Obsidian notes with Snacks picker',
  nargs = '?',
})
