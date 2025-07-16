local M = {}

-- Window detection utilities
local function find_window_by_name(name)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_name = vim.api.nvim_buf_get_name(buf)
    if buf_name:match(name) then
      return win
    end
  end
  return nil
end

local function find_terminal_with_process(process_name)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_type = vim.api.nvim_buf_get_option(buf, 'buftype')
    if buf_type == 'terminal' then
      local buf_name = vim.api.nvim_buf_get_name(buf)
      if buf_name:match(process_name) then
        return win
      end
    end
  end
  return nil
end

-- Navigate to editor window (main editing area)
function M.navigate_to_editor()
  -- Find the main editor window (non-terminal, non-special buffers)
  for _, win in ipairs(vim.api.nvim_list_wins()) do
    local buf = vim.api.nvim_win_get_buf(win)
    local buf_type = vim.api.nvim_buf_get_option(buf, 'buftype')
    local buf_name = vim.api.nvim_buf_get_name(buf)

    -- Main editor: normal buffer type, not terminal, has a file
    if buf_type == '' and buf_name ~= '' and not buf_name:match 'term://' then
      vim.api.nvim_set_current_win(win)
      return
    end
  end

  -- If no editor window found, create one
  vim.cmd 'enew'
end

-- Navigate to or create bottom terminal
function M.navigate_to_terminal()
  -- Look for existing bottom terminal
  local term_win = find_terminal_with_process 'term://'
  if term_win then
    vim.api.nvim_set_current_win(term_win)
    return
  end

  -- Create new bottom terminal
  vim.cmd.vnew()
  vim.cmd.term()
  vim.cmd.wincmd 'J'
  vim.api.nvim_win_set_height(0, 12)
end

-- Navigate to or create Claude Code terminal
function M.navigate_to_claude()
  -- Look for existing Claude terminal
  local claude_win = find_window_by_name 'Claude Code'
  if claude_win then
    vim.api.nvim_set_current_win(claude_win)
    return
  end

  -- Create new Claude terminal in right split
  vim.cmd 'vsplit'
  vim.cmd 'wincmd l'
  vim.cmd('vertical resize ' .. math.floor(vim.o.columns * 0.4))
  vim.cmd 'terminal'

  -- Rename buffer for identification
  vim.api.nvim_buf_set_name(0, 'Claude Code')

  -- Auto-start claude if available
  vim.defer_fn(function()
    local job_id = vim.b.terminal_job_id
    if job_id then
      vim.fn.chansend(job_id, 'claude\n')
    end
  end, 100)
end

-- Navigate to or create IPython terminal
function M.navigate_to_ipython()
  -- Look for existing IPython terminal
  local ipython_win = find_terminal_with_process 'ipython'
  if ipython_win then
    vim.api.nvim_set_current_win(ipython_win)
    return
  end

  -- Create new IPython terminal in right split
  vim.cmd 'vsplit'
  vim.cmd 'wincmd l'
  vim.cmd('vertical resize ' .. math.floor(vim.o.columns * 0.4))
  vim.cmd 'terminal'

  -- Rename buffer for identification
  vim.api.nvim_buf_set_name(0, 'IPython REPL')

  -- Start IPython with uv
  vim.defer_fn(function()
    local job_id = vim.b.terminal_job_id
    if job_id then
      vim.fn.chansend(job_id, 'uv run ipython\n')
    end
  end, 100)
end

return M

