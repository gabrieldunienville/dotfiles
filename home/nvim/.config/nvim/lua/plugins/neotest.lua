return {
  'nvim-neotest/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    'nvim-treesitter/nvim-treesitter',
    'nvim-neotest/neotest-python',
  },
  config = function()
    require('neotest').setup {
      adapters = {
        require 'neotest-python' {
          -- Extra arguments for nvim-dap configuration
          -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings for values
          dap = { justMyCode = false },
          -- Command line arguments for runner
          -- Can also be a function to return dynamic values
          -- args = { '--log-level', 'DEBUG', '-s' },
          args = { '-s' },
          -- Runner to use. Will use pytest if available by default.
          -- Can be a function to return dynamic value.
          runner = 'pytest',
          -- Custom python path for the runner.
          -- Can be a string or a list of strings.
          -- Can also be a function to return dynamic value.
          -- If not provided, the path will be inferred by checking for
          -- virtual envs in the local directory and for Pipenev/Poetry configs
          -- python = ".venv/bin/python",
          -- python = 'poetry run -m python',
          -- Returns if a given file path is a test file.
          -- NB: This function is called a lot so don't perform any heavy tasks within it.
          -- is_test_file = function(file_path)
          --   ...
          -- end,
          -- !!EXPERIMENTAL!! Enable shelling out to `pytest` to discover test
          -- instances for fil
          pytest_discover_instances = true,
        },
      },
      -- log_level = 0,
    }

    vim.keymap.set('n', '<leader>uc', function()
      vim.cmd 'wa'
      require('neotest').run.run()
    end, { desc = '[U]nit test run [C]losest' })

    vim.keymap.set('n', '<leader>ul', function()
      require('neotest').run.run_last()
    end, { desc = '[U]nit test run [L]ast' })

    vim.keymap.set('n', '<leader>us', function()
      require('neotest').summary.toggle()
    end, { desc = '[U]nit test toggle [S]ummary' })

    vim.keymap.set('n', '<leader>uo', function()
      require('neotest').output.open { enter = true }
    end, { desc = '[U]nit test open [O]utput popup' })

    vim.keymap.set('n', '<leader>up', function()
      require('neotest').output_panel.open()
    end, { desc = '[U]nit test open Output [P]anel' })
  end,
}
