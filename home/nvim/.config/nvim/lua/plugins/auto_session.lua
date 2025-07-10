return {
  'rmagatti/auto-session',
  enabled = false,
  config = function()
    vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
    require('auto-session').setup {
      log_level = 'info',
      suppressed_dirs = { '~/', '~/Downloads', '/' },
      auto_restore_enabled = false, -- Disable automatic restoration
      auto_save_enabled = true,     -- Keep automatic saving
      auto_clean_after_session_restore = true,
    }
  end,
}
