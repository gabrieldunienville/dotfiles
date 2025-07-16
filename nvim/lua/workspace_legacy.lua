local M = {}

local claude_win = nil
local claude_buf = nil

function _G.open_claude_terminal()
  -- If claude_win is nil, create a new window
  if not claude_win then
    print 'Creating new Claude terminal window'
    claude_win = Snacks.win.new {
      show = true,
      title = 'Claude Code Terminal',
      position = 'right',
      width = 0.5,
      on_win = function(win)
        -- Create a new buffer for the terminal
        claude_buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_name(0, 'Claude Code - ' .. claude_buf)
        win:set_buf(claude_buf)

        -- Open terminal in the window
        vim.cmd 'terminal'

        -- Set local options for the terminal buffer
        vim.opt_local.number = false
        vim.opt_local.relativenumber = false

        local opts = { buffer = 0 }
        vim.keymap.set('t', '<C-h>', [[<C-\><C-n><C-w>h]], opts)
        vim.keymap.set('t', '<C-j>', [[<C-\><C-n><C-w>j]], opts)
        vim.keymap.set('t', '<C-k>', [[<C-\><C-n><C-w>k]], opts)
        vim.keymap.set('t', '<C-l>', [[<C-\><C-n><C-w>l]], opts)

        vim.defer_fn(function()
          vim.fn.chansend(vim.b.terminal_job_id, 'claude\n')
        end, 100)
      end,
    }
  end
  claude_win:show()
  claude_win:focus()
  vim.cmd 'startinsert'
end

function _G.paste_to_claude()
  local text = vim.fn.getreg '+'
  if text == '' then
    print 'No text in clipboard to paste'
    return
  end

  if claude_buf then
    local job_id = vim.api.nvim_buf_get_var(claude_buf, 'terminal_job_id')
    vim.fn.chansend(job_id, vim.fn.getreg '+')
  end
end

local function get_visual_selection()
  local _, start_row, start_col, _ = unpack(vim.fn.getpos "'<")
  local _, end_row, end_col, _ = unpack(vim.fn.getpos "'>")

  local lines = vim.api.nvim_buf_get_lines(0, start_row - 1, end_row, false)

  if #lines == 1 then
    return lines[1]:sub(start_col, end_col)
  else
    lines[1] = lines[1]:sub(start_col)
    lines[#lines] = lines[#lines]:sub(1, end_col)
    return table.concat(lines, '\n')
  end
end

function _G.paste_visual_selection_to_claude()
  local text = get_visual_selection()
  if text == '' then
    print 'No text selected to paste'
    return
  end
  if claude_buf then
    local job_id = vim.api.nvim_buf_get_var(claude_buf, 'terminal_job_id')
    vim.fn.chansend(job_id, text .. '\n')
  end
end

function _G.paste_diagnostics_to_claude()
  local text = require('diagnostics').get_diagnostics()
  if text == '' then
    print 'No diagnostics to paste'
    return
  end
  if claude_buf then
    local job_id = vim.api.nvim_buf_get_var(claude_buf, 'terminal_job_id')
    vim.fn.chansend(job_id, text .. '\n')
  end
end

function _G.close_claude_terminal()
  if claude_buf and vim.api.nvim_buf_is_valid(claude_buf) then
    local job_id = vim.api.nvim_buf_get_var(claude_buf, 'terminal_job_id')
    vim.fn.jobstop(job_id)
    -- Snacks.bufdelete.delete(claude_buf)
    vim.api.nvim_buf_delete(claude_buf, { force = true })
    claude_buf = nil
  end
  if claude_win then
    claude_win:close()
    claude_win = nil
  end
end

vim.keymap.set('n', '<leader>wc', '<cmd>lua open_claude_terminal()<CR>', {
  noremap = true,
  silent = true,
  desc = 'Open Claude Code Terminal',
})

vim.keymap.set('t', '<C-e>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

return M

-- Yanked
