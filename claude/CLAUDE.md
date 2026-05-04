# CLAUDE.md

## Task Specification

Before executing the more complex tasks, we explore the problem space, gather
requirements, and build an execution plan. Each task document is placed in the
project in the `tasks/` dir.

## Markdown Templates

### Include ONLY sections defined template

When asked to generate a file base on a template, make sure in include only the
sections defined in the template. NEVER add new sections you think might be
needed later.

### Variable substitution

Variables should be substituted into `{{ variable_here }}` blocks using the
context you have.

Sometimes there will be natural language formatting instructions after the pipe
symbol. Eg for `{{ name | title case }}` you should render "My Name".

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
