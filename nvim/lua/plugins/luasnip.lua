return {
  {
    'L3MON4D3/LuaSnip',
    -- Optional: build instructions if needed
    build = 'make install_jsregexp',
    dependencies = {
      -- If you want to use nvim-cmp for snippet completion
      -- "hrsh7th/nvim-cmp",
      -- "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local ls = require 'luasnip'

      local clipboard_block = ls.snippet('cbp', {
        ls.text_node '```',
        -- Filetype insert node - this is where you'll first land and type the filetype
        ls.insert_node(1, ''),
        ls.text_node { '', '' },
        ls.function_node(function()
          -- Get clipboard content
          local clipboard = vim.fn.getreg '+'

          -- Split the clipboard content by newlines to create an array of strings
          local lines = {}
          for line in clipboard:gmatch '[^\r\n]+' do
            table.insert(lines, line)
          end

          -- Return the array of lines
          return lines
        end, {}), -- The empty table is important here
        ls.text_node { '', '```', '' }, -- Added an extra empty string for a newline
        -- This final insert node (with index 0) is where the cursor will land after
        -- you tab through the filetype node
        ls.insert_node(0),
      })

      local empty_block = ls.snippet('cb', {
        ls.text_node '```',
        ls.insert_node(1, ''),
        ls.text_node { '', '' },
        ls.insert_node(2, ''),
        ls.text_node { '', '```', '' },
        ls.insert_node(0),
      })

      -- Add to snippets
      ls.add_snippets('all', {
        clipboard_block,
        empty_block,
      })

      -- Use the reference in your keybinding
      vim.keymap.set({ 'i', 'n' }, '<M-p>', function()
        ls.snip_expand(clipboard_block)
      end, { desc = 'Code block with clipboard content' })

      vim.keymap.set({ 'i', 's' }, '<M-p>', function()
        if ls.jumpable(1) then
          ls.jump(1)
        end
      end, { silent = true })
    end,
  },
}
