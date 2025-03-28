return {
  'nvim-treesitter/nvim-treesitter',
  build = ':TSUpdate',
  dependencies = {
    'LiadOz/nvim-dap-repl-highlights',
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
      -- We'll handle jinja separately
    },
    auto_install = true,
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = { 'ruby' },
    },
    indent = {
      enable = true,
      disable = {
        'ruby',
        'xml',
        'jinja', -- Using 'jinja' as the parser name
      },
    },
  },
  config = function(_, opts)
    require('nvim-dap-repl-highlights').setup()

    -- Register the cathaysia/tree-sitter-jinja parser
    local parser_config = require('nvim-treesitter.parsers').get_parser_configs()
    parser_config.jinja = {
      install_info = {
        url = 'https://github.com/cathaysia/tree-sitter-jinja',
        files = { 'tree-sitter-jinja/src/parser.c' },
        branch = 'master',
        generate_requires_npm = false,
        requires_generate_from_grammar = false,
      },
      filetype = 'jinja.html',
    }

    -- Set up proper filetype detection for Jinja templates
    vim.filetype.add {
      extension = {
        jinja = 'jinja.html',
        jinja2 = 'jinja.html',
        j2 = 'jinja.html',
      },
      pattern = {
        ['.*%.jinja%.html'] = 'jinja.html',
        ['.*%.html%.jinja'] = 'jinja.html',
        ['.*%.j2%.html'] = 'jinja.html',
        ['.*%.html%.j2'] = 'jinja.html',
        ['.*%.xml%.j2'] = 'jinja.xml',
      },
    }

    -- For Neovim's filetype detection mechanism
    vim.api.nvim_create_autocmd({ 'BufRead', 'BufNewFile' }, {
      pattern = { '*.jinja.html', '*.html.jinja', '*.j2.html', '*.html.j2' },
      callback = function()
        vim.bo.filetype = 'jinja.html'
      end,
      group = vim.api.nvim_create_augroup('JinjaFiletypeSetup', { clear = true }),
    })

    -- Configure Treesitter
    require('nvim-treesitter.install').prefer_git = true
    require('nvim-treesitter.configs').setup(opts)

    -- Register parser association with filetypes
    local ft_to_parser = require('nvim-treesitter.parsers').filetype_to_parsername
    ft_to_parser.jinja = 'jinja'
    ft_to_parser['jinja.html'] = 'jinja'

    -- Install the Jinja parser
    vim.defer_fn(function()
      vim.cmd 'TSInstall jinja'
    end, 1000)

    -- Create a command to help diagnose issues if needed
    vim.api.nvim_create_user_command('DebugJinja', function()
      print('Current filetype: ' .. vim.bo.filetype)
      local parser_name = require('nvim-treesitter.parsers').get_parser_from_ft(vim.bo.filetype)
      print('Parser for current filetype: ' .. (parser_name or 'none'))
      print('Is jinja installed: ' .. tostring(vim.fn.executable 'tree-sitter-jinja' == 1))

      -- Get info about active parsers for this buffer
      local has_ts, ts_info = pcall(function()
        local buf = vim.api.nvim_get_current_buf()
        return vim.treesitter.highlighter.active[buf]
      end)

      if has_ts and ts_info then
        print 'Tree-sitter is active for this buffer'
        for lang, _ in pairs(ts_info.trees) do
          print('Active language: ' .. lang)
        end
      else
        print 'Tree-sitter is not active for this buffer'
      end
    end, {})
  end,
}
