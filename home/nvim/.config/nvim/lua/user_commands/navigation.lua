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

  -- Store the alternate buffer number (previously accessed buffer)
  local alternate_buffer = vim.fn.bufnr '#'

  -- Check if file exists and is writable
  if current_file ~= '' and vim.fn.filewritable(current_file) == 1 then
    -- Delete the file from disk
    local success = os.remove(current_file)
    if success then
      -- Close the buffer without saving
      vim.cmd 'bd!'

      -- Switch to the alternate buffer if it exists and is valid
      if alternate_buffer ~= -1 and vim.fn.buflisted(alternate_buffer) == 1 then
        vim.cmd('buffer ' .. alternate_buffer)
        print('File deleted: ' .. current_file)
      else
        print('File deleted: ' .. current_file .. ' (no previous buffer available)')
      end
    else
      print('Failed to delete file: ' .. current_file)
    end
  else
    -- If it's not a real file or not writable, just close the buffer and switch
    vim.cmd 'bd!'

    -- Switch to the alternate buffer if it exists and is valid
    if alternate_buffer ~= -1 and vim.fn.buflisted(alternate_buffer) == 1 then
      vim.cmd('buffer ' .. alternate_buffer)
    end
  end
end

vim.api.nvim_create_user_command('OpenNextFile', OpenNextFile, {})
vim.api.nvim_create_user_command('OpenPrevFile', OpenPrevFile, {})
vim.api.nvim_create_user_command('DeleteCurrentFile', DeleteCurrentFile, {})
