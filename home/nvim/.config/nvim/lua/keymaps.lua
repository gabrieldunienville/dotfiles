-- Stop highlighting the search matches but keep search context so can resume if needed
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- Save
vim.keymap.set('n', '<C-s>', '<cmd>wa<CR>', { desc = 'Save all files' })

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

-- Exit terminal mode in the builtin terminal with a shortcut that is a bit easier
-- for people to discover. Otherwise, you normally need to press <C-\><C-n>, which
-- is not what someone will guess without a bit more experience.
--
-- NOTE: This won't work in all terminal emulators/tmux/etc. Try your own mapping
-- or just use <C-\><C-n> to exit terminal mode
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- vim.keymap.set('n', '<leader>w', ':w')

-- Copy path
local function insertFullPath()
  local filepath = vim.fn.expand '%'
  vim.fn.setreg('+', filepath) -- write to clippoard
end

local function insertFileName()
  local filename = vim.fn.expand '%:t' -- the ":t" gets only the tail (filename) part
  vim.fn.setreg('+', filename) -- write to clipboard
end
vim.keymap.set('n', '<leader>yp', insertFullPath, { noremap = true, silent = true })
vim.keymap.set('n', '<leader>yf', insertFileName, { noremap = true, silent = true })

-- vim.keymap.set('n', '<leader>yp', ':let @" = expand("%")<cr>')

-- Python: string to f-string
vim.keymap.set('n', '<leader>lf', 'mmF"if<Esc>`mli{}<Left>')

-- Spell checking
vim.keymap.set('n', ')', ']s', { desc = 'Next spelling error' })
vim.keymap.set('n', '(', '[s', { desc = 'Previous spelling error' })
vim.keymap.set('n', '<leader>is', 'z=', { desc = 'Show spelling suggestions' })
vim.keymap.set('n', '<leader>ia', 'zg', { desc = 'Add word to dictionary' })
vim.keymap.set('n', '<leader>iu', 'zug', { desc = 'Undo add word to dictionary' })
vim.keymap.set('n', '<leader>io', '<cmd>set spell<CR>', { desc = 'Turn on spell checking' })

-- Find and replace
vim.keymap.set('v', '<C-r>', '"sy:%s/<C-r>s/<C-r>s/g<Left><Left>', { desc = 'Find and Replace' })
-- vim.keymap.set('n', '<C-r>', ':%s/<C-r>s/<C-r>s/g<Left><Left>', { desc = 'Find and Replace' })
vim.keymap.set('v', '<C-t>', '"sy/<C-r>s<CR>', { desc = 'Find' })

-- Notes
--  Repeat last substitution on current line: &
--  Repeat last substitution on current line with same flags: :&&
--  Repeat last substitution on entire buffer: g&
--  Repeat last substitution on entire buffer with same flags: :%&&

-- Git
vim.keymap.set('n', '<leader>gs', function()
  require('diffview.config').actions.toggle_stage_entry()
end, { desc = 'Refresh git diff view' })
