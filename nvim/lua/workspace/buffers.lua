local M = {}

local state = require 'workspace.state'
local config = require 'workspace.config'
local windows = require 'workspace.windows'

function M.initialize() end

local startinsert_cmd = vim.api.nvim_replace_termcodes('<Cmd>startinsert<CR>', true, false, true)

local function enter_insert_after_cursor()
  local pos = vim.api.nvim_win_get_cursor(0)
  local line = vim.api.nvim_get_current_line()
  if pos[2] < #line then
    vim.api.nvim_win_set_cursor(0, { pos[1], pos[2] + 1 })
  end
  vim.api.nvim_feedkeys(startinsert_cmd, 'n', false)
end

local function setup_compose_keymaps(compose_buf, buf_name)
  local opts = { buffer = compose_buf, noremap = true, silent = true }

  vim.keymap.set('n', '<CR>', function()
    M.send_compose(buf_name)
  end, opts)

  vim.keymap.set('n', '<C-m>', function()
    M.scroll_tui(buf_name, 'down')
  end, opts)

  vim.keymap.set('n', '<C-,>', function()
    M.scroll_tui(buf_name, 'up')
  end, opts)
end

function M.get_or_create_compose_buf(buf_name)
  local compose = state.get_compose(buf_name)
  if compose and compose.buf_id and vim.api.nvim_buf_is_valid(compose.buf_id) then
    return compose.buf_id
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.bo[buf].filetype = 'markdown'
  vim.bo[buf].bufhidden = 'hide'
  vim.bo[buf].buflisted = false
  setup_compose_keymaps(buf, buf_name)
  state.set_compose_buf(buf_name, buf)
  return buf
end

function M.show_compose(buf_name)
  local compose = state.get_compose(buf_name)

  if compose and compose.win_id and vim.api.nvim_win_is_valid(compose.win_id) then
    vim.api.nvim_set_current_win(compose.win_id)
    enter_insert_after_cursor()
    return
  end

  local compose_buf = M.get_or_create_compose_buf(buf_name)

  vim.cmd 'belowright 16split'
  local compose_win = vim.api.nvim_get_current_win()
  vim.api.nvim_set_current_buf(compose_buf)
  vim.wo[compose_win].winfixheight = true
  vim.wo[compose_win].number = false
  vim.wo[compose_win].relativenumber = false
  vim.wo[compose_win].signcolumn = 'no'
  vim.wo[compose_win].wrap = true
  state.set_compose_win(buf_name, compose_win)
  enter_insert_after_cursor()
end

function M.close_active_compose()
  for _, compose in pairs(state.get_all_compose()) do
    if compose.win_id and vim.api.nvim_win_is_valid(compose.win_id) then
      vim.api.nvim_win_close(compose.win_id, true)
      compose.win_id = nil
    end
  end
end

function M.send_compose(buf_name)
  local compose = state.get_compose(buf_name)
  if not compose or not compose.buf_id or not vim.api.nvim_buf_is_valid(compose.buf_id) then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(compose.buf_id, 0, -1, false)
  local text = table.concat(lines, '\n')
  if vim.trim(text) == '' then
    return
  end

  vim.fn.setreg('c', text)

  local buf_config = config.get_buf_config(buf_name)
  local tui_buf = state.get_buffer(buf_name, buf_config.win_name)
  if tui_buf and vim.api.nvim_buf_is_valid(tui_buf) then
    local ok, job_id = pcall(vim.api.nvim_buf_get_var, tui_buf, 'terminal_job_id')
    if ok and job_id and job_id ~= 0 then
      vim.fn.chansend(job_id, text)
      vim.defer_fn(function()
        vim.fn.chansend(job_id, '\r')
      end, 100)
    end
  end

  vim.api.nvim_buf_set_lines(compose.buf_id, 0, -1, false, { '' })
  vim.cmd 'startinsert'
end

function M.scroll_tui(buf_name, direction)
  local buf_config = config.get_buf_config(buf_name)
  local win = state.get_window(buf_config.win_name)
  if not win or not win.win or not vim.api.nvim_win_is_valid(win.win) then
    return
  end

  local height = vim.api.nvim_win_get_height(win.win)
  local count = math.floor(height / 4)
  local key = direction == 'down' and Snacks.util.keycode '<C-e>' or Snacks.util.keycode '<C-y>'
  vim.api.nvim_win_call(win.win, function()
    vim.cmd(('normal! %d%s'):format(count, key))
  end)
end

function M.append_to_compose(buf_name, text)
  local compose_buf = M.get_or_create_compose_buf(buf_name)
  local lines = vim.split(text, '\n')
  local line_count = vim.api.nvim_buf_line_count(compose_buf)
  local last_line = vim.api.nvim_buf_get_lines(compose_buf, line_count - 1, line_count, false)[1]

  if last_line == '' and line_count == 1 then
    vim.api.nvim_buf_set_lines(compose_buf, 0, -1, false, lines)
  else
    vim.api.nvim_buf_set_lines(compose_buf, line_count, line_count, false, lines)
  end

  local compose = state.get_compose(buf_name)
  if compose and compose.win_id and vim.api.nvim_win_is_valid(compose.win_id) then
    local new_line_count = vim.api.nvim_buf_line_count(compose_buf)
    local last = vim.api.nvim_buf_get_lines(compose_buf, new_line_count - 1, new_line_count, false)[1]
    vim.api.nvim_win_set_cursor(compose.win_id, { new_line_count, math.max(0, #last - 1) })
  end
end

function M.open_buffer(buf_name)
  local buf_config = config.get_buf_config(buf_name)
  local window_name = buf_config.win_name

  if buf_config.compose then
    local compose = state.get_compose(buf_name)
    if compose and compose.win_id and vim.api.nvim_win_is_valid(compose.win_id) then
      vim.api.nvim_set_current_win(compose.win_id)
      enter_insert_after_cursor()
      return
    end
  end

  M.close_active_compose()

  windows.open_window(window_name)

  local buf_id = state.get_buffer(buf_name, window_name)

  if not buf_id then
    if buf_config.launch then
      buf_config.launch()
    end
    buf_id = vim.api.nvim_get_current_buf()
    state.set_buffer(buf_name, window_name, buf_id)
  elseif buf_id ~= vim.api.nvim_get_current_buf() then
    vim.api.nvim_set_current_buf(buf_id)
  end

  state.set_active_buffer(window_name, buf_name)

  if buf_config.compose then
    M.show_compose(buf_name)
  end
end

function M.hide_buffer(buf_name)
  local buf_config = config.get_buf_config(buf_name)
  if buf_config.compose then
    M.close_active_compose()
  end
  local window_name = buf_config.win_name
  windows.hide_window(window_name)
end

function M.paste_to_buffer(win_name, buf_name, text)
  local buf_id = state.get_buffer(buf_name, win_name)
  local job_id = vim.api.nvim_buf_get_var(buf_id, 'terminal_job_id')
  if not job_id or job_id == 0 then
    print(string.format('No terminal job found for buffer %s', buf_name))
    return
  end
  vim.fn.chansend(job_id, text .. '\n')
end

return M
