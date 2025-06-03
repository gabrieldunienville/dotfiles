--[[

=====================================================================
==================== READ THIS BEFORE CONTINUING ====================
=====================================================================
========                                    .-----.          ========
========         .----------------------.   | === |          ========
========         |.-""""""""""""""""""-.|   |-----|          ========
========         ||                    ||   | === |          ========
========         ||   KICKSTART.NVIM   ||   |-----|          ========
========         ||                    ||   | === |          ========
========         ||                    ||   |-----|          ========
========         ||:Tutor              ||   |:::::|          ========
========         |'-..................-'|   |____o|          ========
========         `"")----------------(""`   ___________      ========
========        /::::::::::|  |::::::::::\  \ no mouse \     ========
========       /:::========|  |==hjkl==:::\  \ required \    ========
========      '""""""""""""'  '""""""""""""'  '""""""""""'   ========
========                                                     ========
=====================================================================
=====================================================================

What is Kickstart?

  Kickstart.nvim is *not* a distribution.

  Kickstart.nvim is a starting point for your own configuration.
    The goal is that you can read every line of code, top-to-bottom, understand
    what your configuration is doing, and modify it to suit your needs.

    Once you've done that, you can start exploring, configuring and tinkering to
    make Neovim your own! That might mean leaving Kickstart just the way it is for a while
    or immediately breaking it into modular pieces. It's up to you!

    If you don't know anything about Lua, I recommend taking some time to read through
    a guide. One possible example which will only take 10-15 minutes:
      - https://learnxinyminutes.com/docs/lua/

    After understanding a bit more about Lua, you can use `:help lua-guide` as a
    reference for how Neovim integrates Lua.
    - :help lua-guide
    - (or HTML version): https://neovim.io/doc/user/lua-guide.html

Kickstart Guide:

  TODO: The very first thing you should do is to run the command `:Tutor` in Neovim.

    If you don't know what this means, type the following:
      - <escape key>
      - :
      - Tutor
      - <enter key>

    (If you already know the Neovim basics, you can skip this step.)

  Once you've completed that, you can continue working through **AND READING** the rest
  of the kickstart init.lua.

  Next, run AND READ `:help`.
    This will open up a help window with some basic information
    about reading, navigating and searching the builtin help documentation.

    This should be the first place you go to look when you're stuck or confused
    with something. It's one of my favorite Neovim features.

    MOST IMPORTANTLY, we provide a keymap "<space>sh" to [s]earch the [h]elp documentation,
    which is very useful when you're not exactly sure of what you're looking for.

  I have left several `:help X` comments throughout the init.lua
    These are hints about where to find more information about the relevant settings,
    plugins or Neovim features used in Kickstart.

If you experience any errors while trying to install kickstart, run `:checkhealth` for more info.

I hope you enjoy your Neovim journey,
- TJ

P.S. You can delete this when you're done too. It's your config now! :)
--]]

require 'options'
require 'keymaps'
require 'misc'

-- Install `lazy.nvim` plugin manager
local lazypath = vim.fn.stdpath 'data' .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  local lazyrepo = 'https://github.com/folke/lazy.nvim.git'
  vim.fn.system { 'git', 'clone', '--filter=blob:none', '--branch=stable', lazyrepo, lazypath }
end ---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

vim.lsp.enable {
  'ruff',
  -- 'basedpyright',
  'pyright',
  'lua_ls',
}

require('lazy').setup({

  -- Core syntax and language
  { import = 'plugins.treesitter', enabled = true },
  -- { import = 'plugins.lsp', enabled = true },
  -- { import = 'plugins.cmp', enabled = true },
  { import = 'plugins.blink', enabled = true },
  { import = 'plugins.mason', enabled = true },
  { import = 'plugins.typescript_tools', enabled = false },
  { import = 'plugins.tailwind_tools', enabled = false },
  { import = 'plugins.indent_line', enabled = false }, -- 2
  { import = 'plugins.autopairs', enabled = false }, -- disable to test performance
  { import = 'plugins.ts_autotag', enabled = true }, -- disable to test performance

  -- UI and Navigation
  { import = 'plugins.aerial', enabled = true },
  { import = 'plugins.neotree', enabled = true },
  { import = 'plugins.telescope', enabled = true }, -- 3
  { import = 'plugins.trouble', enabled = false }, -- 2
  { import = 'plugins.lualine', enabled = true },
  { import = 'plugins.harpoon', enabled = true },
  { import = 'plugins.spectre', enabled = true },
  { import = 'plugins.detour', enabled = true },
  { import = 'plugins.floating_help', enabled = false },
  { import = 'plugins.snacks', enabled = true },

  -- Git
  { import = 'plugins.git', enabled = true }, -- 3

  -- Neovim Dev
  { import = 'plugins.lazydev', enabled = true },

  -- Testing and Debug
  { import = 'plugins.neotest', enabled = true }, -- 2
  { import = 'plugins.dap', enabled = true },

  -- Completion and AI
  { import = 'plugins.copilot', enabled = true },
  { import = 'plugins.parrot', enabled = true },
  { import = 'plugins.luasnip', enabled = true },
  { import = 'plugins.mcphub', enabled = true },
  { import = 'plugins.avante', enabled = false },
  { import = 'plugins.codecompanion', enabled = true },

  -- Language specific
  { import = 'plugins.ansible', enabled = false }, -- 2
  { import = 'plugins.obsidian', enabled = true },
  { import = 'plugins.markdown', enabled = true },
  { import = 'plugins.venv_selector', enabled = true },

  -- Utilities
  { import = 'plugins.slime', enabled = true }, -- 2
  { import = 'plugins.auto_session', enabled = false },
  { import = 'plugins.which_key', enabled = true },
  { import = 'plugins.yank_assassin', enabled = true },
  { import = 'plugins.vim_sleuth', enabled = false }, -- 2
  { import = 'plugins.tmux_navigator', enabled = true },

  -- UI Enhancements
  { import = 'plugins.todo_comments', enabled = true }, -- 2
  { import = 'plugins.mini', enabled = true },
  { import = 'plugins.comment', enabled = true },
  { import = 'plugins.conform', enabled = true },
  { import = 'plugins.treesj', enabled = true },
  { import = 'plugins.neogen', enabled = false }, -- 2
  { import = 'plugins.catppuccin', enabled = true },
  { import = 'plugins.cyberdream', enabled = false }, -- 2
  { import = 'plugins.neoscroll', enabled = false },
  { import = 'plugins.notify', enabled = true },
}, {
  ui = {
    -- If you are using a Nerd Font: set icons to an empty table which will use the
    -- default lazy.nvim defined Nerd Font icons, otherwise define a unicode icons table
    icons = vim.g.have_nerd_font and {} or {
      cmd = '⌘',
      config = '🛠',
      event = '📅',
      ft = '📂',
      init = '⚙',
      keys = '🗝',
      plugin = '🔌',
      runtime = '💻',
      require = '🌙',
      source = '📄',
      start = '🚀',
      task = '📌',
      lazy = '💤 ',
    },
  },
})

require 'user_commands.ipython_run_imports'
require 'user_commands.pyflyby_autoimport'
require 'user_commands.slime_custom'
require 'user_commands.config_commands'
require 'user_commands.navigation'
