---
allowed-tools: Read(~/.claude)
description: Plan a task
---

# Plan

Gathers requirements for a task and generates a detailed plan that can be
executed later.

## Create a TODO with EXACTLY these items

NEVER create more todo items than the following:

### Create task document

Create the new task file at `tasks/$ARGUMENTS.md` using the template
@~/.claude/templates/task.md

### Recieve overview

Ask me to provide an overview of the task. I will provide as much detail as I
think in necessary for us to get started planning the task.

My input here my be very unstructured or scattered - it's basically a brain dump
of my thoughts on the task at the present time.

Once I have give you this, we will move onto the next step without documenting
anything. At this stage we are just building a shared overview of the problem.

### Gather problem details and requirements

In this step you take the overview I have given you and try to explore your
understanding of the problem and requirements. My overview was likely missing
important details, it's your job to fill them in. In this step we are deepening
our shared understanding of the problem and requirements.

Start by asking me more details about the problem that are unclear. Then ask
questions about the problem and requirements as needed. You MUST keep asking me
questions until we have reached a solid understanding.

Document the problem details and requirements established during this phase in
our task file.

This phase MUST not end until I indicate we are moving onto the next phase.

### Create reference list

Now we will link any important information that has come from reference material
used thus far. This is important because the implementer may not have all the
context we have.

If I have referenced any MCP resources, ask me which ones I want to capture in
the reference list and I will indicate which ones to include in the list. If we
have used an other important references from the web, ask me if I want want
those listed as MCP resources too.

### Create implementation plan


