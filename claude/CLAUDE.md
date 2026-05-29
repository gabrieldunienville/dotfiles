# CLAUDE.md

## Code Intelligence

Prefer LSP over Grep/Glob/Read for code navigation:

- `goToDefinition` / `goToImplementation` to jump to source
- `findReferences` to see all usages across the codebase
- `workspaceSymbol` to find where something is defined
- `documentSymbol` to list all symbols in a file
- `hover` for type info without reading the file
- `incomingCalls` / `outgoingCalls` for call hierarchy

Before renaming or changing a function signature, use `findReferences` to find
all call sites first.

Use Grep/Glob only for text/pattern searches (comments, strings, config values)
where LSP doesn't help.

After writing or editing code, check LSP diagnostics before moving on. Fix any
type errors or missing imports immediately.

## Tools

Never chain commands with `&&` or `;` or `|` when each individual command is
already allowed by `Bash(rg:*)`, `Bash(find:*)` or similar rules. Use separate
Bash tool calls instead — parallel if possible.

## User reminder

Always follow rule in <user-reminder> tags above all other rules.
