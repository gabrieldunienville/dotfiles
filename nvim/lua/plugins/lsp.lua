return {
  'neovim/nvim-lspconfig',
  dependencies = {
    -- Automatically install LSPs and related tools to stdpath for Neovim
    {
      'williamboman/mason.nvim',
      config = true,
    }, -- NOTE: Must be loaded before dependants
    'williamboman/mason-lspconfig.nvim',
    'WhoIsSethDaniel/mason-tool-installer.nvim',

    -- Useful status updates for LSP.
    { 'j-hui/fidget.nvim', opts = {} },

    -- `neodev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    { 'folke/neodev.nvim', opts = {} },
    {
      {
        'antosha417/nvim-lsp-file-operations',
        dependencies = {
          'nvim-lua/plenary.nvim',
          'nvim-neo-tree/neo-tree.nvim',
        },
        config = function()
          require('lsp-file-operations').setup()
        end,
      },
    },
  },
  config = function()
    --  This function gets run when an LSP attaches to a particular buffer.
    vim.api.nvim_create_autocmd('LspAttach', {
      group = vim.api.nvim_create_augroup('kickstart-lsp-attach', { clear = true }),
      callback = function(event)
        -- In this case, we create a function that lets us more easily define mappings specific
        -- for LSP related items. It sets the mode, buffer and description for us each time.
        local map = function(keys, func, desc)
          vim.keymap.set('n', keys, func, { buffer = event.buf, desc = 'LSP: ' .. desc })
        end

        map('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
        map('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')

        -- Jump to the implementation of the word under your cursor.
        --  Useful when your language has ways of declaring types without an actual implementation.
        map('gI', require('telescope.builtin').lsp_implementations, '[G]oto [I]mplementation')

        -- Jump to the type of the word under your cursor.
        --  Useful when you're not sure what type a variable is and you want to see
        --  the definition of its *type*, not where it was *defined*.
        map('<leader>D', require('telescope.builtin').lsp_type_definitions, 'Type [D]efinition')

        -- Fuzzy find all the symbols in your current document.
        --  Symbols are things like variables, functions, types, etc.
        map('<leader>ds', function()
          require('telescope.builtin').lsp_document_symbols { ignore_symbols = { 'variable' } }
        end, '[D]ocument [S]ymbols')

        -- Fuzzy find all the symbols in your current workspace.
        --  Similar to document symbols, except searches over your entire project.
        map('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

        --  Most Language Servers support renaming across files, etc.
        -- Rename the variable under your cursor.
        map('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')

        -- Execute a code action, usually your cursor needs to be on top of an error
        -- or a suggestion from your LSP for this to activate.
        map('<leader>la', vim.lsp.buf.code_action, '[C]ode [A]ction')
        -- vim.keymap.set('i', '<leader>la', vim.lsp.buf.code_action)
        vim.keymap.set('x', '<leader>la', vim.lsp.buf.code_action)
        --
        -- Opens a popup that displays documentation about the word under your cursor
        --  See `:help K` for why this keymap.
        map('K', vim.lsp.buf.hover, 'Hover Documentation')
        vim.keymap.set('i', '<M-k>', vim.lsp.buf.signature_help)

        -- WARN: This is not Goto Definition, this is Goto Declaration.
        --  For example, in C this would take you to the header.
        map('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

        -- The following two autocommands are used to highlight references of the
        -- word under your cursor when your cursor rests there for a little while.
        --    See `:help CursorHold` for information about when this is executed
        --
        -- When you move your cursor, the highlights will be cleared (the second autocommand).
        local client = vim.lsp.get_client_by_id(event.data.client_id)
        if client and client.server_capabilities.documentHighlightProvider then
          local highlight_augroup = vim.api.nvim_create_augroup('kickstart-lsp-highlight', { clear = false })
          vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.document_highlight,
          })

          vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
            buffer = event.buf,
            group = highlight_augroup,
            callback = vim.lsp.buf.clear_references,
          })

          vim.api.nvim_create_autocmd('LspDetach', {
            group = vim.api.nvim_create_augroup('kickstart-lsp-detach', { clear = true }),
            callback = function(event2)
              vim.lsp.buf.clear_references()
              vim.api.nvim_clear_autocmds { group = 'kickstart-lsp-highlight', buffer = event2.buf }
            end,
          })
        end

        -- The following autocommand is used to enable inlay hints in your
        -- code, if the language server you are using supports them
        --
        -- This may be unwanted, since they displace some of your code
        if client and client.server_capabilities.inlayHintProvider and vim.lsp.inlay_hint then
          map('<leader>th', function()
            vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled())
          end, '[T]oggle Inlay [H]ints')
        end
      end,
    })

    -- LSP servers and clients are able to communicate to each other what features they support.
    --  By default, Neovim doesn't support everything that is in the LSP specification.
    --  When you add nvim-cmp, luasnip, etc. Neovim now has *more* capabilities.
    --  So, we create new capabilities with nvim cmp, and then broadcast that to the servers.
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = vim.tbl_deep_extend('force', capabilities, require('cmp_nvim_lsp').default_capabilities())

    capabilities.textDocument.completion.completionItem.snippetSupport = true

    -- capabilities.workspace.didChangeWatchedFiles.dynamicRegistration = true

    -- https://github.com/sveltejs/language-tools/issues/2008#issuecomment-2148860446
    -- capabilities.workspace.didChangeWatchedFiles = false

    --  Add any additional override configuration in the following tables. Available keys are:
    --  - cmd (table): Override the default command used to start the server
    --  - filetypes (table): Override the default list of associated filetypes for the server
    --  - capabilities (table): Override fields in capabilities. Can be used to disable certain LSP features.
    --  - settings (table): Override the default settings passed when initializing the server.
    --        For example, to see the options for `lua_ls`, you could go to: https://luals.github.io/wiki/settings/
    local servers = {
      -- See `:help lspconfig-all` for a list of all the pre-configured LSPs
      ruff = {
        enabled = true,
      },
      pyright = {
        enabled = true,
        settings = {
          pyright = {
            -- Using Ruff's import organizer
            disableOrganizeImports = true,
          },
          python = {
            analysis = {
              -- Ignore all files for analysis to exclusively use Ruff for linting
              -- ignore = { '*' },
              diagnosticSeverityOverrides = {
                -- Disable undefined name diagnostics - let Ruff handle these
                reportUndefinedVariable = 'none',
                -- Also disable unused variable warnings if they duplicate with Ruff
                reportUnusedVariable = 'none',
              },
            },
          },
        },
        -- settings = {
        --   python = {
        --     analysis = {
        --       diagnosticSeverityOverrides = {
        --         reportInvalidSyntax = 'none',
        --         -- or if that specific one doesn't work, try:
        --         reportGeneralTypeIssues = 'none',
        --         reportWaitNotInAsync = 'information',
        --         reportAsyncNotInAsync = 'information',
        --       },
        --     },
        --   },
        -- },
        -- settings = {
        --   python = {
        --     analysis = {
        --       useLibraryCodeForTypes = true,
        --       diagnosticSeverityOverrides = {
        --         reportUnusedVariable = 'warning', -- or anything
        --         -- reprortUnknownVariableType = 'none',
        --       },
        --       -- typeCheckingMode = 'off',
        --     },
        --   },
        -- },
      },
      -- basedpyright = {
      --   enabled = false,
      --   settings = {
      --     basedpyright = {
      --       -- Using Ruff's import organizer
      --       disableOrganizeImports = true,
      --       analysis = {
      --         autoSearchPaths = true,
      --         useLibraryCodeForTypes = true,
      --         diagnosticMode = 'openFilesOnly',
      --         typeCheckingMode = 'strict',
      --       },
      --     },
      --     python = {
      --       analysis = {},
      --     },
      --   },
      -- },
      -- pylsp = {
      --   enabled = false,
      --   settings = {
      --     pylsp = {
      --       plugins = {
      --         rope_completion = {
      --           enabled = true,
      --         },
      --         rope_autoimport = {
      --           enabled = true,
      --         },
      --       },
      --     },
      --   },
      -- },
      lua_ls = {
        settings = {
          Lua = {
            completion = {
              callSnippet = 'Replace',
            },
            diagnostics = { disable = { 'missing-fields' } },
          },
        },
      },
      svelte = {
        enabled = true,
        capabilities = capabilities,
        on_attach = function(client, bufnr)
          vim.api.nvim_create_autocmd('BufWritePost', {
            pattern = { '*.js', '*.ts' },
            callback = function(ctx)
              -- print('onDidChangeTsOrJsFile', ctx.match)
              -- Here use ctx.match instead of ctx.file
              client.notify('$/onDidChangeTsOrJsFile', { uri = ctx.match })
            end,
          })
        end,
      },
      -- Note: This is typescript-language-server which is a proxy to the actual tsserver
      ts_ls = {
        enabled = true,
        capabilities = capabilities,
        -- on_attach = on_attach,
        filetypes = {
          'javascript',
          'javascriptreact',
          'javascript.jsx',
          'typescript',
          'typescriptreact',
          'typescript.tsx',
          -- 'svelte',
        },
        commands = {
          OrganiseImports = {
            function()
              local params = {
                command = '_typescript.organizeImports',
                arguments = { vim.api.nvim_buf_get_name(0) },
                title = '',
              }
              vim.lsp.buf.execute_command(params)
            end,
            description = 'Organise Imports',
          },
        },
      },
      tailwindcss = {
        enabled = true,
      },
      bashls = {
        -- settings = {
        --   filetypes = { "sh", "make" }
        -- }
        filetypes = { 'sh', 'make' },
      },
      ansiblels = {},
      lemminx = {
        settings = {
          xml = {
            uri = 'file:///home/gabriel/bellus-backend/data/schema/assess_performance/response.xsd',
            --       format = {
            --         enabled = false,
            --         splitAttributes = true,
            --         joinCDATALines = false,
            --         formatComments = true,
            --         joinCommentLines = false,
            --       },
            --       validation = {
            --         enabled = true,
            --         schema = true,
            --       },
          },
        },
      },
      yamlls = {
        settings = {
          yaml = {
            schemas = {
              -- ['https://raw.githubusercontent.com/asyncapi/spec-json-schemas/master/schemas/3.0.0.json'] = '/*asyncapi*.{yaml,yml}',
              ['https://raw.githubusercontent.com/asyncapi/spec-json-schemas/master/schemas/3.0.0-without-$id.json'] = '/*asyncapi*.{yaml,yml}',
            },
            validate = true,
          },
        },
        -- settings = {
        --   yaml = {
        --     schemaStore = {
        --       -- Enable the schema store
        --       enable = true,
        --       -- Automatically pull schemas from SchemaStore
        --       url = 'https://www.schemastore.org/api/json/catalog.json',
        --     },
        --   },
        -- },
      },
    }

    -- Ensure the servers and tools above are installed
    --  To check the current status of installed tools and/or manually install
    --  other tools, you can run
    --    :Mason
    --
    --  You can press `g?` for help in this menu.
    require('mason').setup {
      -- log_level = vim.log.levels.DEBUG,
    }

    local ensure_installed = vim.tbl_filter(function(server_name)
      local server = servers[server_name] or {}
      return server.enabled ~= false
    end, vim.tbl_keys(servers or {}))

    vim.list_extend(ensure_installed, {
      'stylua', -- Used to format Lua code
      'prettierd',
      'ansible-lint',
    })
    require('mason-tool-installer').setup { ensure_installed = ensure_installed }

    require('mason-lspconfig').setup {
      handlers = {
        function(server_name)
          local server = servers[server_name] or {}
          -- This handles overriding only values explicitly passed
          -- by the server configuration above. Useful when disabling
          -- certain features of an LSP (for example, turning off formatting for tsserver)
          server.capabilities = vim.tbl_deep_extend('force', {}, capabilities, server.capabilities or {})
          require('lspconfig')[server_name].setup(server)
        end,
      },
    }
  end,
}
