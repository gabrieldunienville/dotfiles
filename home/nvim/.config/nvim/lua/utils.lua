local M = {}

function M.safe_reload_buffer(bufnr)
  -- Check if buffer is modified
  if vim.api.nvim_buf_get_option(bufnr, 'modified') then
    -- Prompt user or handle conflict
    print 'Buffer is modified. Please save or discard changes before reloading.'
    return false
  end

  -- Check if file exists
  local filepath = vim.api.nvim_buf_get_name(bufnr)
  if vim.fn.filereadable(filepath) == 1 then
    vim.api.nvim_buf_call(bufnr, function()
      vim.cmd 'edit'
    end)
    return true
  end
  return false
end

return M
