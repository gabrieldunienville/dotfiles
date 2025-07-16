return {
  'frankroeder/parrot.nvim',
  dependencies = { 'ibhagwan/fzf-lua', 'nvim-lua/plenary.nvim' },
  -- optionally include "folke/noice.nvim" or "rcarriga/nvim-notify" for beautiful notifications
  config = function()
    require('parrot').setup {
      -- Providers must be explicitly added to make them available.
      providers = {
        anthropic = {
          api_key = os.getenv 'ANTHROPIC_API_KEY',
        },
      },
      chat_user_prefix = '🗨: User',
      llm_prefix = '🦜: ',
      chat_free_cursor = true,
      hooks = {
        CodeConsultant = function(prt, params)
          local chat_prompt = [[
          Your task is to analyze the provided {{filetype}} code and suggest
          improvements to optimize its performance. Identify areas where the
          code can be made more efficient, faster, or less resource-intensive.
          Provide specific suggestions for optimization, along with explanations
          of how these changes can enhance the code's performance. The optimized
          code should maintain the same functionality as the original code while
          demonstrating improved efficiency.

          Here is the code
          ```{{filetype}}
          {{filecontent}}
          ```
        ]]
          prt.ChatNew(params, chat_prompt)
        end,
        FileChat = function(prt, params)
          local chat_prompt = [[
          I have the following code from {{filename}}:

          <file-name>
          {{filename}}
          </file-name>

          <file-content>
          ```{{filetype}}

          {{filecontent}}

          ```
          </file-content>

          <extract>
          {{selection}}
          </extract>

          <task>
          The given extract is a part of the given file-content. Answer the following question/s about extract with respect to the content of the file it is extracted from.
          </task>
          ]]
          prt.ChatNew(params, chat_prompt)
        end,
      },
    }

    -- Key bindings
    vim.keymap.set('v', '<leader>ka', ":<C-u>'<,'>PrtChatNew<cr>", { desc = 'ChatNew using selection' })
    vim.keymap.set('n', '<leader>ka', ':PrtChatNew<cr>', { desc = 'ChatNew' })
    vim.keymap.set('n', '<leader>kf', ':PrtChatFinder<cr>', { desc = 'ChatFinder' })
    vim.keymap.set('v', '<leader>kp', ":<C-u>'<,'>PrtChatPaste<cr>", { desc = 'ChatPaste' })
  end,
}
