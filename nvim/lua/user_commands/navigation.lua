function OpenNextFile()
  local current_file = vim.fn.expand '%:p'
  local dir = vim.fn.expand '%:p:h'
  local files = vim.fn.glob(dir .. '/*', false, true)
  table.sort(files)

  local idx = -1
  for i, file in ipairs(files) do
    if file == current_file then
      idx = i
      break
    end
  end

  if idx >= 0 and idx < #files then
    vim.cmd('edit ' .. vim.fn.fnameescape(files[idx + 1]))
  else
    vim.notify('No next file found', vim.log.levels.INFO)
  end
end

function OpenPrevFile()
  local current_file = vim.fn.expand '%:p'
  local dir = vim.fn.expand '%:p:h'
  local files = vim.fn.glob(dir .. '/*', false, true)
  table.sort(files)

  local idx = -1
  for i, file in ipairs(files) do
    if file == current_file then
      idx = i
      break
    end
  end

  if idx > 1 then
    vim.cmd('edit ' .. vim.fn.fnameescape(files[idx - 1]))
  else
    vim.notify('No previous file found', vim.log.levels.INFO)
  end
end

function DeleteCurrentFile()
  local current_file = vim.fn.expand '%'

  if current_file ~= '' and vim.fn.filewritable(current_file) == 1 then
    local success = os.remove(current_file)
    if success then
      Snacks.bufdelete()
    else
      print('Failed to delete file: ' .. current_file)
    end
  end
end

vim.api.nvim_create_user_command('OpenNextFile', OpenNextFile, {})
vim.api.nvim_create_user_command('OpenPrevFile', OpenPrevFile, {})
vim.api.nvim_create_user_command('DeleteCurrentFile', DeleteCurrentFile, {})
