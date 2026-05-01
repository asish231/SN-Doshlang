# Agent Instructions

This repo has multiple AI agents working on it simultaneously. Follow these rules every session.

## Mandatory: Read AGENT_STATE.md First

Before doing any work, read `AGENT_STATE.md`. It tells you:
- What the other agent is currently working on (avoid conflicts)
- What is currently broken (don't build on top of it)
- What interfaces changed since your last session (update your mental model)

## Claim Your Zone

Before editing any `src/*.s` file, update the "Active Work Zones" table in `AGENT_STATE.md` with your agent name and "in progress". Set it back to idle when done.

## Interface Changes Are Critical

If you rename a label, change register arguments to a function, or change a shared buffer layout in `data.s`, update the "Interfaces Between Zones" table in `AGENT_STATE.md` immediately. The other agent's code will break silently if you don't.

## End of Session Checklist

1. Set your zone back to idle in `AGENT_STATE.md`
2. Write a one-line summary of what you did under "Last Completed Work"
3. If you need the other agent to do something, add it to "Pending Handoffs"
4. If you broke something and didn't fix it, add it to "Known Broken Things"

## How to Start a Session

When starting any session on this repo, tell the agent:

```
Read AGENT_STATE.md. You are Agent A.
```

or

```
Read AGENT_STATE.md. You are Agent B.
```

Pick A or B based on which agent/CLI you are using. Stick to the same letter across sessions so the state file stays consistent.

## How to End a Session

Before closing, tell the agent:

```
Update AGENT_STATE.md with what you did and set your zone back to idle.
```

The agent will write its summary, clear its zone claim, and note any broken things or handoffs.
