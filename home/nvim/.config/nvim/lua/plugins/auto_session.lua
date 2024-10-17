return {
  'rmagatti/auto-session',
  config = function()
    vim.o.sessionoptions = 'blank,buffers,curdir,folds,help,tabpages,winsize,winpos,terminal,localoptions'
    require('auto-session').setup {
      -- lazy = true,
      log_level = 'info',
      suppressed_dirs = { '~/', '~/Downloads', '/' },
      auto_clean_after_session_restore = true,
    }
  end,
}
