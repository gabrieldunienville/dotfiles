return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  dependencies = {
    'LiadOz/nvim-dap-repl-highlights',
    'nvim-treesitter/playground',
  },
  opts = {
    ensure_installed = {
      'bash',
      'c',
      'diff',
      'html',
      'lua',
      'luadoc',
      'markdown',
      'vim',
      'vimdoc',
      'svelte',
      'javascript',
      'typescript',
      'tsx',
      'scss',
      'css',
      'dap_repl',
      'dockerfile',
      'xml',
      'terraform',
      'jinja',
      'htmldjango',
    },
    -- Autoinstall languages that are not installed
    auto_install = true,
    highlight = {
      enable = true,
      -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
      --  If you are experiencing weird indenting issues, add the language to
      --  the list of additional_vim_regex_highlighting and disabled languages for indent.
      additional_vim_regex_highlighting = { 'ruby' },
    },
    incremental_selection = {
      enable = true,
    },
    indent = {
      enable = true,
      disable = {
        'ruby',
        'xml',
      },
    },
    injection = {
      enable = true,
    },
  },
  config = function(_, opts)
    require('nvim-dap-repl-highlights').setup()

    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

    -- Prefer git instead of curl in order to improve connectivity in some environments
    require('nvim-treesitter.install').prefer_git = true

    ---@diagnostic disable-next-line: missing-fields
    require('nvim-treesitter.configs').setup(opts)
    --

    -- vim.treesitter.language.register('html', 'jinja.html')
    vim.treesitter.language.register('htmldjango', 'jinja.html')
    -- vim.treesitter.language.register('jinja', 'jinja.html')

    -- Add explicit parser registrations
    -- local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
    -- parser_config.jinja.used_by = { 'html' }

    -- ---- Enable syntax highlighting for Jinja files
    -- vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWinEnter' }, {
    --   pattern = { '*.jinja', '*.jinja.html', '*.html.jinja' },
    --   callback = function()
    --     vim.cmd 'syntax on'
    --   end,
    -- })

    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-contexss
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects

    vim.api.nvim_create_user_command('CheckInjections', function()
      -- Check both jinja and jinja.html injections
      local query_string = vim.treesitter.query.get('jinja', 'injections')
      if query_string then
        print 'Jinja injections query found:'
        print(vim.inspect(query_string))
      else
        print 'No jinja injections query found!'
      end

      -- local jinja_html_query = vim.treesitter.query.get('jinja.html', 'injections')
      -- if jinja_html_query then
      --   print '\nJinja.html injections query found:'
      --   print(vim.inspect(jinja_html_query))
      -- else
      --   print '\nNo jinja.html injections query found!'
      -- end
    end, {})

    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'jinja.html',
      callback = function()
        -- Directly set the injection query for jinja
        -- This completely overrides any queries from runtime directories
        vim.treesitter.query.set(
          'jinja',
          'injections',
          [[
      ;; Inject HTML into all words nodes
      (words) @injection.content
      (#set! injection.language "html")
      
      ;; Also try to capture content between HTML tags directly
      ((words) @injection.content
       (#match? @injection.content "<.*>")
       (#set! injection.language "html"))
    ]]
        )

        -- Make sure highlighting is enabled for this buffer
        local ft = vim.bo.filetype
        local lang = vim.treesitter.language.get_lang(ft)
        if lang then
          -- Start the parser for this buffer
          vim.treesitter.start(0, lang)
        end

        -- Optionally, enable traditional syntax highlighting as a fallback
        vim.cmd 'syntax enable'
      end,
    })

    vim.treesitter.query.set(
      'python',
      'injections',
      [[
  ;; Identify SQL queries in string literals
  ((string) @injection.content
   (#match? @injection.content "SELECT|INSERT|UPDATE|DELETE|CREATE|ALTER")
   (#set! injection.language "sql"))
]]
    )
  end,
}
