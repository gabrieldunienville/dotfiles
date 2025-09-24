return {
  event = 'VimEnter',
  'nvim-telescope/telescope.nvim',
  branch = '0.1.x',
  dependencies = {
    'nvim-lua/plenary.nvim',
    { -- If encountering errors, see telescope-fzf-native README for installation instructions
      'nvim-telescope/telescope-fzf-native.nvim',

      -- `build` is used to run some command when the plugin is installed/updated.
      -- This is only run then, not every time Neovim starts up.
      build = 'make',

      -- `cond` is a condition used to determine whether this plugin should be
      -- installed and loaded.
      cond = function()
        return vim.fn.executable 'make' == 1
      end,
    },
    { 'nvim-telescope/telescope-ui-select.nvim' },

    -- Useful for getting pretty icons, but requires a Nerd Font.
    { 'nvim-tree/nvim-web-devicons', enabled = vim.g.have_nerd_font },

    { 'xiyaowong/telescope-emoji.nvim' },
  },
  config = function()
    local focus_preview = function(prompt_bufnr)
      local action_state = require 'telescope.actions.state'
      local picker = action_state.get_current_picker(prompt_bufnr)
      local prompt_win = picker.prompt_win
      local previewer = picker.previewer
      local winid = previewer.state.winid
      local bufnr = previewer.state.bufnr
      vim.keymap.set('n', '<Tab>', function()
        vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', prompt_win))
      end, { buffer = bufnr })
      vim.cmd(string.format('noautocmd lua vim.api.nvim_set_current_win(%s)', winid))
      -- api.nvim_set_current_win(winid)
    end

    -- Two important keymaps to use while in Telescope are:
    --  - Insert mode: <c-/>
    --  - Normal mode: ?
    --
    -- This opens a window that shows you all of the keymaps for the current
    -- Telescope picker. This is really useful to discover what Telescope can
    -- do as well as how to actually do it!

    local actions = require 'telescope.actions'
    local action_state = require 'telescope.actions.state' -- Add this line

    -- [[ Configure Telescope ]]
    -- See `:help telescope` and `:help telescope.setup()`
    require('telescope').setup {
      -- You can put your default mappings / updates / etc. in here
      --  All the info you're looking for is in `:help telescope.setup()`
      --
      defaults = {
        mappings = {
          n = {
            ['<esc>'] = require('telescope.actions').close,
          },
          i = {
            -- ['<c-enter>'] = 'to_fuzzy_refine',
            ['<Tab>'] = focus_preview,
            ['<M-d>'] = require('telescope.actions').delete_buffer,
          },
        },
      },
      pickers = {
        oldfiles = {
          cwd_only = true,
        },
        --   help_tags = {
        --     attach_mappings = function(_, map)
        --       local function help_in_detour(prompt_bufnr)
        --         local selection = action_state.get_selected_entry()
        --         local help_tag = selection.value
        --         actions.close(prompt_bufnr)
        --
        --         local popup_id = require('detour').Detour()
        --         if popup_id then
        --           vim.wo[popup_id].signcolumn = 'no'
        --
        --           -- Load help content FIRST
        --           local help_buf = nil
        --           for _, buf in ipairs(vim.api.nvim_list_bufs()) do
        --             if vim.api.nvim_buf_is_loaded(buf) then
        --               local buf_name = vim.api.nvim_buf_get_name(buf)
        --               if buf_name:match('/' .. help_tag .. '%.txt$') then
        --                 help_buf = buf
        --                 break
        --               end
        --             end
        --           end
        --
        --           if not help_buf then
        --             local success = pcall(function()
        --               vim.cmd('silent help ' .. help_tag)
        --               help_buf = vim.api.nvim_get_current_buf()
        --               local current_win = vim.api.nvim_get_current_win()
        --               if current_win ~= popup_id then
        --                 vim.api.nvim_win_close(current_win, false)
        --               end
        --             end)
        --
        --             if not success then
        --               vim.cmd('help ' .. help_tag)
        --               return
        --             end
        --           end
        --
        --           -- Set the help buffer in detour window
        --           vim.api.nvim_win_set_buf(popup_id, help_buf)
        --           vim.api.nvim_set_current_win(popup_id)
        --
        --           -- NOW resize and center the window
        --           vim.schedule(function()
        --             local max_width = 90
        --             local screen_width = vim.o.columns
        --             local screen_height = vim.o.lines
        --             local desired_width = math.min(max_width, math.floor(screen_width * 0.75))
        --
        --             local current_config = vim.api.nvim_win_get_config(popup_id)
        --             if current_config.relative ~= '' then -- Make sure it's still a floating window
        --               local new_config = vim.tbl_extend('force', current_config, {
        --                 width = desired_width,
        --                 col = math.floor((screen_width - desired_width) / 2),
        --               })
        --               vim.api.nvim_win_set_config(popup_id, new_config)
        --             end
        --           end)
        --         else
        --           vim.cmd('help ' .. help_tag)
        --         end
        --       end
        --
        --       map('i', '<CR>', help_in_detour)
        --       map('n', '<CR>', help_in_detour)
        --       return true
        --     end,
        --   },
      },
      extensions = {
        ['ui-select'] = {
          require('telescope.themes').get_dropdown(),
        },
      },
      -- file_ignore_patterns = {
      --   "^scratch/",
      -- }
    }

    -- Enable Telescope extensions if they are installed
    pcall(require('telescope').load_extension, 'fzf')
    pcall(require('telescope').load_extension, 'ui-select')
    pcall(require('telescope').load_extension 'emoji')

    -- See `:help telescope.builtin`
    local builtin = require 'telescope.builtin'
    vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
    vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })

    -- Handled by snacks.picker
    -- vim.keymap.set('n', '<leader>sf', function()
    --   builtin.find_files { hidden = true }
    -- end, { desc = '[S]earch [F]iles' })
    -- vim.keymap.set('n', '<leader>sg', function()
    --   builtin.live_grep { grep_open_files = false }
    -- end, { desc = '[S]earch by [G]rep' })

    vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
    -- vim.keymap.set('n', '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
    vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })

    -- vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
    -- vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
    vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

    -- Slightly advanced example of overriding default behavior and theme
    vim.keymap.set('n', '<leader>/', function()
      -- You can pass additional configuration to Telescope to change the theme, layout, etc.
      builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
        winblend = 10,
        previewer = false,
      })
    end, { desc = '[/] Fuzzily search in current buffer' })

    -- It's also possible to pass additional configuration options.
    --  See `:help telescope.builtin.live_grep()` for information about particular keys
    vim.keymap.set('n', '<leader>s/', function()
      builtin.live_grep {
        grep_open_files = true,
        prompt_title = 'Live Grep in Open Files',
      }
    end, { desc = '[S]earch [/] in Open Files' })

    -- Shortcut for searching your Neovim configuration files
    vim.keymap.set('n', '<leader>sn', function()
      builtin.find_files { cwd = vim.fn.stdpath 'config' }
    end, { desc = '[S]earch [N]eovim files' })
  end,
}
