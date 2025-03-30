return { -- Autoformat
  'stevearc/conform.nvim',
  lazy = false,
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format {
          async = true,
          lsp_fallback = false,
        }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    -- format_on_save = function(bufnr)
    --   -- Disable "format_on_save lsp_fallback" for languages that don't
    --   -- have a well standardized coding style. You can add additional
    --   -- languages here or re-enable it for the disabled ones.
    --   local disable_filetypes = { c = true, cpp = true }
    --   return {
    --     timeout_ms = 500,
    --     -- lsp_fallback = not disable_filetypes[vim.bo[bufnr].filetype],
    --     lsp_fallback = false,
    --   }
    -- end,

    -- Install these using mason-tool-installer in lsp config file
    formatters_by_ft = {
      lua = { 'stylua' },
      -- Conform can also run multiple formatters sequentially
      -- python = { 'isort', 'black', 'autoflake' },
      python = { 'isort', 'black' },
      --
      -- You can use a sub-list to tell conform to run *until* a formatter
      -- is found.
      -- javascript = { { "prettierd", "prettier" } },
      javascript = { 'prettierd' },
      typescript = { 'prettierd' },
      svelte = { 'prettierd' },
      typescriptreact = { 'prettierd' },
      htmldjango = { 'prettierd' },
      html = { 'prettierd' },
      yaml = { 'prettierd' },
      xml = { 'prettierd' },
      json = { 'jq' },
      -- ['jinja.html'] = { 'prettierd' },
    },
    formatters = {
      prettierd = {
        -- The default configuration for prettierd, extended for Jinja
        env = {
          PRETTIER_PLUGINS = 'prettier-plugin-jinja-template',
          -- You can also set this if your plugins are in a specific location
          -- PRETTIER_PLUGIN_PATH = "/path/to/node_modules"
        },
      },
      autoflake = {
        -- This can be a string or a function that returns a string.
        -- When defining a new formatter, this is the only field that is required
        command = 'autoflake',
        -- A list of strings, or a function that returns a list of strings
        -- Return a single string instead of a list to run the command in a shell
        args = { '--remove-all-unused-imports', '$FILENAME' },
        -- If the formatter supports range formatting, create the range arguments here
        range_args = function(self, ctx)
          return { '--line-start', ctx.range.start[1], '--line-end', ctx.range['end'][1] }
        end,
        -- Send file contents to stdin, read new contents from stdout (default true)
        -- When false, will create a temp file (will appear in "$FILENAME" args). The temp
        -- file is assumed to be modified in-place by the format command.
        stdin = true,
        -- A function that calculates the directory to run the command in
        -- cwd = require("conform.util").root_file({ ".editorconfig", "package.json" }),
        -- When cwd is not found, don't run the formatter (default false)
        -- require_cwd = true,
        -- When stdin=false, use this template to generate the temporary file that gets formatted
        -- tmpfile_format = ".conform.$RANDOM.$FILENAME",
        -- When returns false, the formatter will not be used
        -- condition = function(self, ctx)
        --   return vim.fs.basename(ctx.filename) ~= "README.md"
        -- end,
        -- Exit codes that indicate success (default { 0 })
        -- exit_codes = { 0, 1 },
        -- Environment variables. This can also be a function that returns a table.
        -- env = {
        --   VAR = "value",
        -- },
        -- Set to false to disable merging the config with the base definition
        -- inherit = true,
        -- When inherit = true, add these additional arguments to the command.
        -- This can also be a function, like args
        -- prepend_args = { "--use-tabs" },
      },
    },
  },
}
