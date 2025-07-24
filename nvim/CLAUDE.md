# Claude: Repo Information and Instructions

This is my neovim configuration repo. It contains a combination of plugin
configuration and my own lua code for custom enhancements.

## Stack

- Neovim 0.11
- Built-in LSP (not nvim-lspconfig as was used previously)

## Layout

- `after/` - Configurations that load after plugins (overrides)
- `ftplugin/` - Filetype-specific settings and configurations
- `lsp/` - Lsp config directory, one file per language server
- `lua/` - Main configuration directory
  - `options.lua` - Misc vim global opt settings
  - `keymaps.lua` - Keymap config for various commands (note keymaps also
    scattered throughout plugin configs)
  - `startup.lua` - Script containing commands to run at neovim startup
  - `plugins/` - Individual plugin configurations (generally one file per
    plugin)
  - `user_commands/` - Custom Neovim commands and utilities
  - `workspace/` - Custom workspace management system
  - `scratch/` - Experimental/work-in-progress features
  - `*rest*` - All the other files here are various modules that should be
    better organised
- `filetype.lua` - Custom filetype detection patterns
- `init.lua` - Entry point that loads all configurations
- `lazy-lock.json` - Plugin version lockfile for reproducible installs
