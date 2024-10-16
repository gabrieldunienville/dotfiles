return {
  'mfussenegger/nvim-dap',
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Required dependency for nvim-dap-ui
    'nvim-neotest/nvim-nio',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'mfussenegger/nvim-dap-python',

    'mxsdev/nvim-dap-vscode-js',
    -- lazy spec to build "microsoft/vscode-js-debug" from source
    {
      'microsoft/vscode-js-debug',
      version = '1.x',
      build = 'npm i && npm run compile vsDebugServerBundle && mv dist out',
    },
  },
  config = function()
    local dap = require 'dap'
    local dapui = require 'dapui'

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_installation = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'python',
      },
    }

    -- Basic debugging keymaps, feel free to change to your liking!
    vim.keymap.set('n', '<F5>', dap.continue, { desc = 'Debug: Start/Continue' })
    vim.keymap.set('n', '<F1>', dap.step_into, { desc = 'Debug: Step Into' })
    vim.keymap.set('n', '<F2>', dap.step_over, { desc = 'Debug: Step Over' })
    vim.keymap.set('n', '<F3>', dap.step_out, { desc = 'Debug: Step Out' })
    vim.keymap.set('n', '<F8>', dap.disconnect, { desc = 'Debug: Disconnect' })
    vim.keymap.set('n', '<F9>', dap.terminate, { desc = 'Debug: Terminate' })
    vim.keymap.set('n', '<leader>b', dap.toggle_breakpoint, { desc = 'Debug: Toggle Breakpoint' })
    vim.keymap.set('n', '<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, { desc = 'Debug: Set Breakpoint' })

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup {
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          run_last = '▶▶',
          terminate = '⏹',
          disconnect = '⏏',
        },
      },
      element_mappings = {},
      expand_lines = true,
      floating = {
        border = 'single',
        mappings = {
          close = { 'q', '<Esc>' },
        },
      },
      force_buffers = true,
      layouts = {
        {
          elements = {
            {
              id = 'scopes',
              size = 0.4,
              -- size = 0.25,
            },
            -- {
            --   id = 'breakpoints',
            --   size = 0.25,
            -- },
            {
              id = 'stacks',
              size = 0.3,
            },
            {
              id = 'watches',
              size = 0.3,
            },
          },
          position = 'left',
          size = 60,
          -- size = 40,
        },
        {
          elements = {
            {
              id = 'repl',
              size = 1,
              -- size = 0.5,
            },
            -- {
            --   id = 'console',
            --   size = 0.5,
            -- },
          },
          position = 'bottom',
          size = 20,
          -- size = 10,
        },
      },
      mappings = {
        edit = 'e',
        expand = { '<CR>', '<2-LeftMouse>' },
        open = 'o',
        remove = 'd',
        repl = 'r',
        toggle = 't',
      },
      render = {
        indent = 1,
        max_value_lines = 100,
        max_type_length = 0,
      },
    }

    -- Toggle to see last session result. Without this, you can't see session output in case of unhandled exception.
    vim.keymap.set('n', '<F7>', dapui.toggle, { desc = 'Debug: See last session result.' })

    dap.listeners.after.event_initialized['dapui_config'] = dapui.open
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- require('dap-go').setup {
    --   delve = {
    --     -- On Windows delve must be run attached or it crashes.
    --     -- See https://github.com/leoluz/nvim-dap-go/blob/main/README.md#configuring
    --     detached = vim.fn.has 'win32' == 0,
    --   },
    require('dap-python').setup 'python'

    -- dap.configurations
    -- ------------------
    -- In addition to launching (possibly) and connecting to a debug adapter, Neovim
    -- needs to instruct the debug adapter itself how to launch and connect to the
    -- debugee. The debugee is the application you want to debug.
    --
    -- Configurations are set in the `dap.configurations` table. The keys are
    -- filetypes. If you run |dap.continue()| it will look up configurations under the
    -- current filetype.
    --
    -- The following config is passed through to the debugpy debugger itself

    table.insert(dap.configurations.python, {
      type = 'python',
      request = 'launch',
      name = 'Launch current file',
      program = '${file}',
    })

    table.insert(dap.configurations.python, {
      type = 'python',
      request = 'launch',
      name = 'Launch pick file',
      program = '${command:pickFile}',
    })

    table.insert(dap.configurations.python, {
      type = 'python',
      request = 'attach',
      name = 'Launch pick process',
      program = '${command:pickProcess}',
    })

    require('dap-vscode-js').setup {
      debugger_path = vim.fn.stdpath 'data' .. '/lazy/vscode-js-debug',
      adapters = { 'pwa-node', 'pwa-chrome', 'pwa-msedge', 'node-terminal', 'pwa-extensionHost' },
    }

    for _, language in ipairs { 'typescript', 'javascript', 'svelte' } do
      require('dap').configurations[language] = {
        -- attach to a node process that has been started with
        -- `--inspect` for longrunning tasks or `--inspect-brk` for short tasks
        -- npm script -> `node --inspect-brk ./node_modules/.bin/vite dev`
        {
          -- use nvim-dap-vscode-js's pwa-node debug adapter
          type = 'pwa-node',
          -- attach to an already running node process with --inspect flag
          -- default port: 9222
          request = 'attach',
          -- allows us to pick the process using a picker
          processId = require('dap.utils').pick_process,
          -- name of the debug action you have to select for this config
          name = 'Attach debugger to existing `node --inspect` process',
          -- for compiled languages like TypeScript or Svelte.js
          sourceMaps = true,
          -- resolve source maps in nested locations while ignoring node_modules
          resolveSourceMapLocations = {
            '${workspaceFolder}/**',
            '!**/node_modules/**',
          },
          -- path to src in vite based projects (and most other projects as well)
          cwd = '${workspaceFolder}/src',
          -- we don't want to debug code inside node_modules, so skip it!
          skipFiles = { '${workspaceFolder}/node_modules/**/*.js' },
        },
        {
          type = 'pwa-chrome',
          name = 'Launch Chrome to debug client',
          request = 'launch',
          url = 'http://localhost:5173/knowledge-model-cards',
          sourceMaps = true,
          protocol = 'inspector',
          port = 9222,
          webRoot = '${workspaceFolder}/src',
          -- skip files from vite's hmr
          skipFiles = { '**/node_modules/**/*', '**/@vite/*', '**/src/client/*', '**/src/*' },
        },
        -- only if language is javascript, offer this debug action
        language == 'javascript'
            and {
              -- use nvim-dap-vscode-js's pwa-node debug adapter
              type = 'pwa-node',
              -- launch a new process to attach the debugger to
              request = 'launch',
              -- name of the debug action you have to select for this config
              name = 'Launch file in new node process',
              -- launch current file
              program = '${file}',
              cwd = '${workspaceFolder}',
            }
          or nil,
      }
    end
  end,
}
