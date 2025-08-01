-- Highlight when yanking (copying) text
--  Try it with `yap` in normal mode
--  See `:help vim.highlight.on_yank()`
vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking (copying) text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
  pattern = '.envrc',
  command = 'set filetype=sh',
})

-- Temp
-- vim.api.nvim_create_autocmd("BufEnter", {
--   callback = function()
--     local bufnr = vim.api.nvim_get_current_buf()
--     local filetype = vim.bo[bufnr].filetype
--     local formatters = require("conform").list_formatters_for_buffer(bufnr)
--     print("File type: " .. filetype .. ", Available formatters: " .. vim.inspect(formatters))
--   end
-- })
--

-- Turn off built in markdown plugin as it interferes
vim.g.markdown_recommended_style = 0 -- Disables the built-in style settings

-- -- Open the last open file when neovim starts
-- vim.api.nvim_create_autocmd('VimEnter', {
--   callback = function()
--     -- Only run if no arguments were passed to nvim
--     if vim.fn.argc() == 0 then
--       vim.schedule(function()
--         local oldfiles = vim.v.oldfiles
--         if oldfiles and #oldfiles > 0 then
--           for _, file in ipairs(oldfiles) do
--             if vim.fn.filereadable(file) == 1 then
--               vim.cmd('edit ' .. vim.fn.fnameescape(file))
--               break
--             end
--           end
--         end
--         -- if vim.fn.argc() == 0 then
--         --   vim.cmd 'Neotree show'
--         -- end
--       end)
--     end
--   end,
-- })

-- Better spelling suggestions
-- From https://github.com/neovim/neovim/pull/25833
local spell_on_choice = vim.schedule_wrap(function(_, idx)
  if type(idx) == 'number' then
    vim.cmd('normal! ' .. idx .. 'z=')
  end
end)

local spellsuggest_select = function()
  if vim.v.count > 0 then
    spell_on_choice(nil, vim.v.count)
    return
  end

  local cword = vim.fn.expand '<cword>'
  local suggestions = vim.fn.spellsuggest(cword, 8)

  if #suggestions == 0 then
    print('No spelling suggestions for: ' .. cword)
    return
  end

  -- Build the display message
  local lines = { 'Spelling suggestions for "' .. cword .. '":' }
  for i, suggestion in ipairs(suggestions) do
    table.insert(lines, i .. '. ' .. suggestion)
  end
  table.insert(lines, 'Press 1-' .. #suggestions .. ' to select, any other key to cancel')

  -- Show the suggestions
  local message = table.concat(lines, '\n')
  vim.api.nvim_echo({ { message, 'Normal' } }, false, {})

  -- Wait for input
  local choice = vim.fn.getchar()

  -- Clear the message
  vim.cmd 'redraw'

  -- Handle the choice
  if type(choice) == 'number' then
    if choice >= 49 and choice <= 48 + math.min(8, #suggestions) then -- ASCII codes for '1'-'8'
      local idx = choice - 48 -- Convert ASCII to number
      vim.cmd('normal! ' .. idx .. 'z=')
    end
  end
end

vim.keymap.set('n', '<leader>if', spellsuggest_select, { desc = 'Shows spelling suggestions' })

-- local function win_test()
--   Snacks.win {
--     -- style = 'input',
--     text = 'This is a test message',
--     enter = true,
--     width = 50,
--     height = 20,
--     -- row =10,
--     -- col = 2,
--   }
-- end
-- vim.keymap.set('n', '<leader>wt', win_test, { desc = 'Test Snacks window' })

-- For edgy
---- views can only be fully collapsed with the global statusline
vim.opt.laststatus = 3
-- Default splitting will cause your main splits to jump when opening an edgebar.
-- To prevent this, set `splitkeep` to either `screen` or `topline`.
vim.opt.splitkeep = 'screen'

-- Code folding
vim.opt.foldmethod = 'manual'
-- vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
-- vim.opt.foldexpr = 'v:lua.vim.lsp.foldexpr()'
vim.opt.foldtext = '' -- Use treesitter for fold text
vim.opt.fillchars = { fold = ' ' }
vim.opt.foldnestmax = 3
vim.opt.foldminlines = 1
-- Helps with buffer switching and navigation
vim.opt.foldenable = true
vim.opt.foldlevelstart = 99
