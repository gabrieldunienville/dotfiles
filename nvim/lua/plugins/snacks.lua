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
        lsp_symbols = {
          filter = {
            default = {
              'Class',
              'Constant', -- Add this to include const declarations
              -- 'Constructor',
              'Enum',
              -- 'Field',
              'Function',
              'Interface',
              'Method',
              'Module',
              'Namespace',
              'Package',
              -- 'Property',
              'Struct',
              'Trait',
            },
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
            ['<a-y>'] = { 'yank', mode = { 'n', 'i' } },
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
    {
      '<leader>s.',
      function()
        Snacks.picker.recent()
      end,
      desc = 'Recent Files',
    },
    {
      '<leader>sr',
      function()
        Snacks.picker.resume()
      end,
      desc = 'Resume Last Picker',
    },
    -- {
    --   '<leader>wi',
    --   function()
    --     -- Snacks.picker.lsp_workspace_symbols({
    --     --   filter = {
    --     --     path
    --     -- })
    --     Snacks.picker.lsp_workspace_symbols {
    --       filter = {
    --         filter = function(item, filter)
    --           -- Debug: print the actual file paths
    --           if item.file then
    --             print('File path:', item.file)
    --           end
    --           -- Exclude actors for now
    --           return not (item.file and item.file:find('actors', 1, true))
    --         end,
    --       },
    --     }
    --   end,
    --   desc = 'Lsp Workspace Symbols',
    -- },
  },
}
