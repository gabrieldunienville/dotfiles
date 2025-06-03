return {
  'olimorris/codecompanion.nvim',
  opts = {},
  dependencies = {
    'nvim-lua/plenary.nvim',
    'nvim-treesitter/nvim-treesitter',
    'ravitemer/mcphub.nvim',
    {
      'echasnovski/mini.diff',
      config = function()
        local diff = require 'mini.diff'
        diff.setup {
          -- Disabled by default
          source = diff.gen_source.none(),
        }
      end,
    },
    'ravitemer/codecompanion-history.nvim',
  },
  config = function()
    require('codecompanion').setup {
      strategies = {
        chat = {
          adapter = 'anthropic',
          keymaps = {
            send = {
              modes = { n = '<C-g>', i = '<C-g>' },
            },
            close = {
              modes = { n = '<C-c>', i = '<C-c>' },
            },
          },
        },
        diff = {
          provider = 'mini_diff',
        },
        inline = {
          adapter = 'anthropic',
        },
      },
      opts = {
        log_level = 'DEBUG',
        system_prompt = function(opts)
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
              local content = file:read '*all'
              if file then
                file:close()
                table.insert(prompt_parts, content)
                -- vim.notify('Successfully read: ' .. file_path, vim.log.levels.INFO)
              else
                vim.notify('Warning: Could not open file ' .. file_path, vim.log.levels.WARN)
              end
            end

            -- Join all parts with a separator
            local combined_prompt = table.concat(prompt_parts, '\n\n')

            return combined_prompt
          end
          local default_prompt = [[
              You are an AI programming assistant named "CodeCompanion". You are currently
              plugged in to the Neovim text editor on a user's machine.

              Your core tasks include:

              - Answering general programming questions.
              - Explaining how the code in a Neovim buffer works.
              - Reviewing the selected code in a Neovim buffer.
              - Generating unit tests for the selected code.
              - Proposing fixes for problems in the selected code.
              - Scaffolding code for a new workspace.
              - Finding relevant code to the user's query.
              - Proposing fixes for test failures.
              - Answering questions about Neovim.
              - Running tools.

              You must:

              - Follow the user's requirements carefully and to the letter.
              - Keep your answers short and impersonal, especially if the user responds with
                context outside of your tasks.
              - Minimize other prose.
              - Use Markdown formatting in your answers.
              - Include the programming language name at the start of the Markdown code
                blocks.
              - Avoid including line numbers in code blocks.
              - Avoid wrapping the whole response in triple backticks.
              - Only return code that's relevant to the task at hand. You may not need to
                return all of the code that the user has shared.
              - Use actual line breaks instead of '\n' in your response to begin new lines.
              - Use '\n' only when you want a literal backslash followed by a character 'n'.
              - All non-code responses must be in %s.

              When given a task:

              1. Think step-by-step and describe your plan for what to build in pseudocode,
                 written out in great detail, unless asked not to do so.
              2. Output the code in a single code block, being careful to only return relevant
                 code.
              3. You should always generate short suggestions for the next user turns that are
                 relevant to the conversation.
              4. You can only give one reply for each conversation turn.
            ]]

          local custom_prompt = getSystemPrompt()
          if custom_prompt == nil then
            return default_prompt
          else
            return default_prompt .. '\n\n' .. custom_prompt
          end
        end,
      },
      prompt_library = {
        ['Clarify Writing'] = {
          strategy = 'chat',
          description = 'Structure my writing for better clarity',
          opts = {
            -- mapping = '<LocalLeader>ce',
            modes = { 'v' },
            is_slash_cmd = true,
            auto_submit = false,
            short_name = 'clarify',
            stop_context_insertion = true, -- Otherwise text will be duplicated as a code block
          },
          prompts = {
            {
              role = 'system',
              content = function(context)
                return [[
                  You are a senior product manager who is an expert in clear, consise writing. You write in a way that can be understood by the product, marketing and engineering teams alike.

                  I will give you a passage of text. You will reccomend any changes to this text you think will improve clarity, readablity and style. 

                  The text may be a scattered assortment of notes that are really lacking structure. In this case, you make take more liberties in making edits to shape a clear, structured message, including removing duplicate or redundant information. ]]
              end,
            },
            {
              role = 'user',
              content = function(context)
                local text = require('codecompanion.helpers.actions').get_code(context.start_line, context.end_line)
                return 'Here is the text:\n\n' .. text .. '\n\n'
              end,
              -- opts = {
              --   contains_code = true,
              -- },
            },
          },
        },
      },
      extensions = {
        mcphub = {
          callback = 'mcphub.extensions.codecompanion',
          opts = {
            show_result_in_chat = true, -- Show mcp tool results in chat
            make_vars = true, -- Convert resources to #variables
            make_slash_commands = true, -- Add prompts as /slash commands
          },
        },
        history = {
          enabled = true,
          opts = {
            -- Keymap to open history from chat buffer (default: gh)
            keymap = 'gh',
            -- Keymap to save the current chat manually (when auto_save is disabled)
            save_chat_keymap = 'sc',
            -- Save all chats by default (disable to save only manually using 'sc')
            auto_save = true,
            -- Number of days after which chats are automatically deleted (0 to disable)
            expiration_days = 0,
            -- Picker interface ("telescope" or "snacks" or "fzf-lua" or "default")
            picker = 'telescope',
            ---Automatically generate titles for new chats
            auto_generate_title = true,
            title_generation_opts = {
              ---Adapter for generating titles (defaults to active chat's adapter)
              adapter = nil, -- e.g "copilot"
              ---Model for generating titles (defaults to active chat's model)
              model = nil, -- e.g "gpt-4o"
            },
            ---On exiting and entering neovim, loads the last chat on opening chat
            continue_last_chat = false,
            ---When chat is cleared with `gx` delete the chat from history
            delete_on_clearing_chat = false,
            ---Directory path to save the chats
            dir_to_save = vim.fn.stdpath 'data' .. '/codecompanion-history',
            ---Enable detailed logging for history extension
            enable_logging = false,
          },
        },
      },
    }
  end,
}
