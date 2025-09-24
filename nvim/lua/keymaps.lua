-- Stop highlighting the search matches but keep search context so can resume if needed
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Save
vim.keymap.set('n', '<C-s>', '<cmd>wa<CR>', { desc = 'Save all files' })

-- Quit
vim.keymap.set('n', '<C-q>', '<cmd>q<CR>', { desc = 'Quit' })

-- Diagnostic keymaps
vim.keymap.set('n', '<M-i>', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', '<M-u>', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Disable arrow keys in normal mode to force use of hjkl
vim.keymap.set('n', '<left>', '<cmd>echo "Use h to move!!"<CR>')
vim.keymap.set('n', '<right>', '<cmd>echo "Use l to move!!"<CR>')
vim.keymap.set('n', '<up>', '<cmd>echo "Use k to move!!"<CR>')
vim.keymap.set('n', '<down>', '<cmd>echo "Use j to move!!"<CR>')

-- Navigate split windows
--  See `:help wincmd` for a list of all window commands
vim.keymap.set('n', '<C-h>', '<C-w><C-h>', { desc = 'Move focus to the left window' })
vim.keymap.set('n', '<C-l>', '<C-w><C-l>', { desc = 'Move focus to the right window' })
vim.keymap.set('n', '<C-j>', '<C-w><C-j>', { desc = 'Move focus to the lower window' })
vim.keymap.set('n', '<C-k>', '<C-w><C-k>', { desc = 'Move focus to the upper window' })

-- Move lines
vim.keymap.set('v', '<A-j>', ":m '>+1<CR>gv=gv")
vim.keymap.set('v', '<A-k>', ":m '<-2<CR>gv=gv")
vim.keymap.set('n', '<A-j>', ':m .+1<CR>==')
vim.keymap.set('n', '<A-k>', ':m .-2<CR>==')

-- Easer than ctrl-^
vim.api.nvim_set_keymap('n', '<M-b>', '<C-^>', { noremap = true })

-- vim.keymap.set('n', '<leader>w', ':w')

-- Copy absolute path to clipboard
vim.keymap.set('n', '<leader>yp', function()
  vim.fn.setreg('+', vim.fn.expand '%:p')
end, { noremap = true, silent = true, desc = 'Copy absolute path to clipboard' })
-- Copy relative path to clipboard
vim.keymap.set('n', '<leader>yr', function()
  vim.fn.setreg('+', vim.fn.expand '%:~:.')
end, { noremap = true, silent = true, desc = 'Copy relative path to clipboard' })
-- Copy filename to clipboard
vim.keymap.set('n', '<leader>yf', function()
  vim.fn.setreg('+', vim.fn.expand '%:t')
end, { noremap = true, silent = true, desc = 'Copy filename to clipboard' })

-- Python: string to f-string
vim.keymap.set('n', '<leader>lf', 'mmF"if<Esc>`mli{}<Left>')

-- Spell checking
vim.keymap.set('n', ')', ']s', { desc = 'Next spelling error' })
vim.keymap.set('n', '(', '[s', { desc = 'Previous spelling error' })
-- vim.keymap.set('n', '<leader>if', 'z=', { desc = 'Show spelling fixed' })
-- vim.keymap.set('n', '<leader>if', function()
--   vim.cmd('normal! z=')
-- end, { desc = 'Show spelling fixes' })

vim.keymap.set('n', '<leader>ia', 'zg', { desc = 'Add word to dictionary' })
vim.keymap.set('n', '<leader>iu', 'zug', { desc = 'Undo add word to dictionary' })
vim.keymap.set('n', '<leader>io', '<cmd>set spell<CR>', { desc = 'Turn on spell checking' })
-- Note: <leader>if in misc.lua

-- Find and replace
vim.keymap.set('v', '<C-r>', '"sy:%s/<C-r>s/<C-r>s/g<Left><Left>', { desc = 'Find and Replace' })
vim.keymap.set('v', '<C-t>', '"sy/<C-r>s<CR>', { desc = 'Find' })

-- Notes
--  Repeat last substitution on current line: &
--  Repeat last substitution on current line with same flags: :&&
--  Repeat last substitution on entire buffer: g&
--  Repeat last substitution on entire buffer with same flags: :%&&

-- Command line completion (Doesn't work)
-- vim.keymap.set('c', '<Down>', '<C-n>', { desc = 'Next completion' })
-- vim.keymap.set('c', '<Up>', '<C-p>', { desc = 'Previous completion' })

-- LSP
-- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = 'Go to definition' })
vim.keymap.set('n', 'gd', Snacks.picker.lsp_definitions, { desc = 'Go to definition' })
vim.keymap.set('i', '<M-k>', vim.lsp.buf.signature_help)
vim.keymap.set('n', 'K', function()
  vim.lsp.buf.hover {
    width = 80,
  }
end, { desc = 'Hover documentation' })
vim.keymap.set('n', 'grr', function()
  Snacks.picker.lsp_references()
end, { desc = 'LSP references' })

-- Git
vim.keymap.set('n', '<leader>gs', function()
  require('diffview.config').actions.toggle_stage_entry()
end, { desc = 'Refresh git diff view' })
vim.keymap.set('n', '<leader>gd', '<cmd>DiffviewOpen<CR>', { desc = 'Open git diff view' })

-- Obsidian
vim.keymap.set('n', '<leader>on', '<cmd>Obsidian new<CR>', { desc = 'Create new note' })
vim.keymap.set('n', '<leader>od', '<cmd>Obsidian today<CR>', { desc = 'Create daily note for today' })
vim.keymap.set('n', '<leader>oy', '<cmd>Obsidian yesterday<CR>', { desc = 'Create daily note for yesterday' })
vim.keymap.set('n', '<leader>ot', '<cmd>Obsidian tags<CR>', { desc = 'View tags' })
vim.keymap.set('n', '<leader>ol', '<cmd>Obsidian dailies<CR>', { desc = 'List dailies' })
vim.keymap.set('n', '<leader>ob', '<cmd>Obsidian backlinks<CR>', { desc = 'List dailies' })

-- Navigation
vim.keymap.set('n', '<M-h>', '<cmd>OpenPrevFile<CR>', { desc = 'Open prevous file' })
vim.keymap.set('n', '<M-l>', '<cmd>OpenNextFile<CR>', { desc = 'Open next file' })

-- Code companion
-- vim.keymap.set({ 'n', 'v' }, '<leader>an', '<cmd>CodeCompanionChat<cr>', { noremap = true, silent = true })
-- vim.keymap.set({ 'n', 'v' }, '<leader>at', '<cmd>CodeCompanionChat Toggle<cr>', { noremap = true, silent = true })
-- vim.keymap.set({ 'n', 'v' }, '<leader>aa', '<cmd>CodeCompanionActions<cr>', { noremap = true, silent = true })
-- vim.keymap.set({ 'n', 'v' }, '<leader>ah', '<cmd>CodeCompanionHistory<cr>', { noremap = true, silent = true })
-- vim.keymap.set('v', '<leader>ap', '<cmd>CodeCompanionChat Add<cr>', { noremap = true, silent = true })

-- -- Workspace Navigation
-- local workspace = require('workspace')
-- vim.keymap.set('n', '<leader>we', workspace.navigate_to_editor, { desc = 'Navigate to editor' })
-- vim.keymap.set('n', '<leader>wt', workspace.navigate_to_terminal, { desc = 'Navigate to terminal' })
-- vim.keymap.set('n', '<leader>wc', workspace.navigate_to_claude, { desc = 'Navigate to Claude Code' })
-- vim.keymap.set('n', '<leader>wp', workspace.navigate_to_ipython, { desc = 'Navigate to IPython' })

-- Utils
vim.keymap.set('n', '<leader>ka', '<cmd>AerialToggle!<CR>', { desc = 'Toggle Aerial' })
vim.keymap.set('n', '<leader>kr', '<cmd>ReloadKeymaps<CR>', { desc = 'Reload keymaps' })
-- vim.keymap.set('n', '<leader>kd', '<cmd>DeleteCurrentFile<CR>', { desc = 'Delete current file' })
vim.keymap.set('n', '<leader>ke', Snacks.explorer.reveal, { desc = 'Open file tree' })
vim.keymap.set('n', '<leader>kx', function()
  require('folding').fold_xstate()
end, { desc = 'Fold XState' })

-- Snacks

local custom_pickers = require 'pickers'

vim.keymap.set(
  'n',
  '<leader>wi',
  custom_pickers.workspace_symbols_filtered {
    filter = function(file)
      return file:find '^packages/actors/src/interface/.-%.interface.ts$'
    end,
    format_path = function(path)
      return path:gsub('^packages/.-/src/', '')
    end,
  },
  { desc = 'Actor Interface' }
)

vim.keymap.set(
  'n',
  '<leader>wa',
  custom_pickers.workspace_symbols_filtered {
    filter = function(file)
      return file:find '^packages/actors/src/api/.-%.interface.ts$'
    end,
    format_path = function(path)
      return path:gsub('^packages/.-/src/', '')
    end,
  },
  { desc = 'Actor API' }
)

-- vim.keymap.set(
--   'n',
--   '<leader>wl',
--   custom_pickers.workspace_symbols_filtered {
--     filter = function(file)
--       return file:find '^packages/actors/src/.-%.ts?$'
--     end,
--     format_path = function(path)
--       return path:gsub('^packages/.-/src/', '')
--     end,
--   },
--   { desc = 'Actor Logic' }
-- )

vim.keymap.set('n', '<leader>ww', function()
  Snacks.picker.lsp_workspace_symbols()
end, { desc = 'All Workspace Symbols' })
