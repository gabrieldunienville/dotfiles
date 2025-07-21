---
allowed-tools: Read(~/.claude)
description: Implement the plan
---

# Implement

Implement the changes outlined in our current plan document on a phase by phase
basis.

## Setup

If you don't already have the plan, read it from `tasks/$ARGUMENTS.md`.

## Phase tasks

We implement phase by phase. NEVER move onto the next phase unless I have
confirmed the current phase is implemented correctly.

Each phase MUST be handed off to a new subagent. This subagent will execute the
full phase implementation until it's done. Once I confirm the phase, the
subagent used for that phase can be terminated. A fresh subagent should be used
when moving onto the next phase.

In each phase, create a TODO list with exactly these items:

### Identify missing requirements

Read the phase details and files that are relevant to the proposed changes.

Identify anything major that is ambiguous, then ask me for clarification. Focus
on decisions that would significantly affect downstream phases.

If there are no missing requirements you can move onto the next item without
waiting for my confirmation.

### Implement interfaces

Now we will implement any new interfaces that the plan calls for. You can create
new files, classes, types, functions, etc in skeleton form with no
implementation details within them.

If the plan calls for modifying existing interfaces, don't do that yet. Leave
existing interfaces as they are.

If this step has raised any questions that are important for the full
implementation, raise them here.

If you have made any changes in this step, wait for my confirmation before
moving on.

### Full implementation

Now you can crack on and fill in all the implementation details.

You may ask questions if you hit major hurdles.
