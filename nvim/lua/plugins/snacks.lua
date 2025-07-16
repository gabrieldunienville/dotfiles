return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    picker = {
      enabled = true,
      sources = {
        files = {
          hidden = true,
          ignored = true,
          exclude = {
            '.git',
            'node_modules',
            '.turbo/*',
            '.vscode/*',
            '.claude/*',
            'pnpm-lock.yaml',
            'package-lock.json',
            '.venv',
            '.ruff_cache/*',
            '**/__pycache__/*',
            '.pytest_cache/*',
          },
        },
        grep = {
          hidden = true,
          ignore_case = true,
          exclude = {
            '.git',
            'node_modules',
            '.turbo/*',
            '.vscode/*',
            '.claude/*',
            'pnpm-lock.yaml',
            'package-lock.json',
            '.venv/*',
            '.ruff_cache/*',
            '**/__pycache__/*',
            '.pytest_cache/*',
          },
        },
        -- Seems to work with inlcudes in explorer config not files
        explorer = {
          include = {
            '.env*',
            '.gitignore',
            '.prettierrc',
          },
        },
      },
      icons = {
        files = {
          enabled = true, -- Make sure this is true
          dir = '󰉋 ',
          file = '󰈔 ',
        },
      },
      win = {
        input = {
          keys = {
            ['<a-s>'] = { 'flash', mode = { 'n', 'i' } },
            ['s'] = { 'flash' },
          },
        },
      },
      actions = {
        flash = function(picker)
          require('flash').jump {
            pattern = '^',
            label = { after = { 0, 0 } },
            search = {
              mode = 'search',
              exclude = {
                function(win)
                  return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'snacks_picker_list'
                end,
              },
            },
            action = function(match)
              local idx = picker.list:row2idx(match.pos[1])
              picker.list:_move(idx, true, true)
            end,
          }
        end,
      },
    },
    explorer = {
      enabled = true,
    },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    win = {
      enable = true,
    },
  },
  keys = {
    {
      '<leader>sf',
      function()
        Snacks.picker.smart()
      end,
      desc = 'Smart Find Files',
    },
    {
      '<leader>sg',
      function()
        Snacks.picker.grep()
      end,
      desc = 'Grep',
    },
  },
}
