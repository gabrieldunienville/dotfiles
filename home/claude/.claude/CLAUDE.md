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
