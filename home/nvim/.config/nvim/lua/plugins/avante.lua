return {
  'yetone/avante.nvim',
  event = 'VeryLazy',
  version = false, -- Never set this value to "*"! Never!
  -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
  build = 'make',
  -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'stevearc/dressing.nvim',
    'nvim-lua/plenary.nvim',
    'MunifTanjim/nui.nvim',
    --- The below dependencies are optional,
    -- 'echasnovski/mini.pick', -- for file_selector provider mini.pick
    'nvim-telescope/telescope.nvim', -- for file_selector provider telescope
    'hrsh7th/nvim-cmp', -- autocompletion for avante commands and mentions
    -- 'ibhagwan/fzf-lua', -- for file_selector provider fzf
    'nvim-tree/nvim-web-devicons', -- or echasnovski/mini.icons
    -- 'zbirenbaum/copilot.lua', -- for providers='copilot'
    {
      -- support for image pasting
      'HakonHarnes/img-clip.nvim',
      event = 'VeryLazy',
      opts = {
        -- recommended settings
        default = {
          embed_image_as_base64 = false,
          prompt_for_file_name = false,
          drag_and_drop = {
            insert_mode = true,
          },
          -- required for Windows users
          use_absolute_path = true,
        },
      },
    },
    {
      -- Make sure to set this up properly if you have lazy=true
      'MeanderingProgrammer/render-markdown.nvim',
      opts = {
        file_types = { 'markdown', 'Avante' },
      },
      ft = { 'markdown', 'Avante' },
    },
  },
  config = function()
    local function getSystemPrompt()
      -- Get the current working directory (project root)
      local cwd = vim.fn.getcwd()
      local context_dir = cwd .. '/context'

      -- Check if context directory exists
      if vim.fn.isdirectory(context_dir) ~= 1 then
        vim.notify('Context directory not found: ' .. context_dir, vim.log.levels.WARN)
        return
      end

      local prompt_parts = {}

      -- Get all files from the context directory
      local files = vim.fn.glob(context_dir .. '/*', false, true)

      if #files == 0 then
        vim.notify('No files found in context directory', vim.log.levels.WARN)
        return
      end

      -- Read each file and add its content to prompt_parts
      for _, file_path in ipairs(files) do
        local file = io.open(file_path, 'r')
        if file then
          local content = file:read '*all'
          file:close()
          table.insert(prompt_parts, content)
          vim.notify('Successfully read: ' .. file_path, vim.log.levels.INFO)
        else
          vim.notify('Warning: Could not open file ' .. file_path, vim.log.levels.WARN)
        end
      end

      -- Join all parts with a separator
      local combined_prompt = table.concat(prompt_parts, '\n\n')

      return combined_prompt
    end

    require('avante').setup {
      provider = 'claude',
      claude = {
        endpoint = 'https://api.anthropic.com',
        model = 'claude-3-7-sonnet-latest',
        timeout = 30000, -- Timeout in milliseconds
        temperature = 0,
        max_tokens = 4096,
      },
      system_prompt = function()
        local hub = require('mcphub').get_hub_instance()
        local default_system_prompt = hub and hub:get_active_servers_prompt() or ''
        local full_prompt = default_system_prompt .. '\n\n' .. getSystemPrompt()
        return full_prompt
      end,
      -- Using function prevents requiring mcphub before it's loaded
      custom_tools = function()
        return {
          require('mcphub.extensions.avante').mcp_tool(),
        }
      end,
    }

    -- vim.api.nvim_create_autocmd('User', {
    --   pattern = 'ToggleCritic',
    --   callback = function()
    --     local combined_prompt = getSystemPrompt()
    --     require('avante.config').override { system_prompt = combined_prompt }
    --   end,
    -- })

    -- vim.keymap.set('n', '<leader>amc', function()
    --   vim.api.nvim_exec_autocmds('User', { pattern = 'ToggleCritic' })
    -- end, { desc = 'avante: toggle critic prompt' })
  end,
}
