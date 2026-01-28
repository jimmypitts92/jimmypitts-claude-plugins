---
description: "Explain Ralph Wiggum technique and available commands"
---

# Ralph Wiggum Plugin Help

Please explain the following to the user:

## What is the Ralph Wiggum Technique?

The Ralph Wiggum technique is an iterative development methodology based on continuous AI loops, pioneered by Geoffrey Huntley.

**Core concept:**
```bash
while :; do
  cat PROMPT.md | claude-code --continue
done
```

The same prompt file is read and fed to Claude repeatedly. The "self-referential" aspect comes from Claude seeing its own previous work in the files and git history, not from feeding output back as input.

**Each iteration:**
1. Claude receives the prompt from the file
2. Works on the task, modifying files
3. Tries to exit
4. Stop hook intercepts and reads the prompt file again
5. Claude sees its previous work in the files
6. Iteratively improves until completion

The technique is described as "deterministically bad in an undeterministic world" - failures are predictable, enabling systematic improvement through prompt tuning.

## Available Commands

### /ralph-loop PROMPT_FILE [OPTIONS]

Start a Ralph loop in your current session.

**Usage:**
```
/ralph-loop prompts/refactor.md --max-iterations 20
/ralph-loop tasks/add-tests.txt --completion-promise "TESTS COMPLETE"
```

**Arguments:**
- `PROMPT_FILE` - Path to file containing the prompt for the loop

**Options:**
- `--max-iterations <n>` - Max iterations before auto-stop
- `--completion-promise <text>` - Promise phrase to signal completion

**How it works:**
1. Creates `.claude/.ralph-loop.local.md` state file with prompt file path
2. You work on the task
3. When you try to exit, stop hook intercepts
4. Stop hook reads the prompt file and feeds it back
5. You see your previous work
6. Continues until promise detected or max iterations

---

### /ralphify PROMPT_TEXT or --file FILE [OPTIONS]

Transform a simple prompt into a Ralph-optimized structured prompt.

**Usage:**
```
/ralphify "Build a REST API for todos"
/ralphify --file rough-prompt.txt --output optimized.md
/ralphify --file draft.txt --promise "DONE" --output final.md
```

**Arguments:**
- `PROMPT_TEXT` - Direct prompt text (if not using --file)

**Options:**
- `--file <path>` - Read prompt from file
- `--output <path>` - Save optimized prompt to file
- `--promise <text>` - Custom completion promise text

**What it does:**
Transforms your prompt by adding:
- Clear numbered steps
- Verification/testing after each step
- Self-correction loops ("if tests fail, fix and retry")
- Explicit completion criteria
- Completion promise tags (`<promise>TEXT</promise>`)
- Fallback behavior for being stuck

**Example workflow:**
```
# 1. Optimize your prompt
/ralphify "Fix the auth bug" --output prompts/fix-auth.md --promise "FIXED"

# 2. Run the Ralph loop
/ralph-loop prompts/fix-auth.md --completion-promise "FIXED" --max-iterations 20
```

---

### /cancel-ralph

Cancel an active Ralph loop (removes the loop state file).

**Usage:**
```
/cancel-ralph
```

**How it works:**
- Checks for active loop state file
- Removes `.claude/.ralph-loop.local.md`
- Reports cancellation with iteration count

---

## Key Concepts

### Prompt Quality Matters

Well-structured prompts are crucial for Ralph loops. Use `/ralphify` to transform simple prompts into optimized ones with:
- Clear steps
- Self-correction loops
- Verification steps
- Completion criteria

### Completion Promises

To signal completion, Claude must output a `<promise>` tag:

```
<promise>TASK COMPLETE</promise>
```

The stop hook looks for this specific tag. Without it (or `--max-iterations`), Ralph runs infinitely.

### Self-Reference Mechanism

The "loop" doesn't mean Claude talks to itself. It means:
- Prompt file is read fresh each iteration
- Claude's work persists in files
- Each iteration sees previous attempts
- Builds incrementally toward goal
- Prompt file can be updated between iterations if needed

## Example

### Interactive Bug Fix

First create a prompt file:
```
# tasks/fix-auth.md
Fix the token refresh logic in auth.ts. Output <promise>FIXED</promise> when all tests pass.
```

Then run:
```
/ralph-loop tasks/fix-auth.md --completion-promise "FIXED" --max-iterations 10
```

You'll see Ralph:
- Attempt fixes
- Run tests
- See failures
- Iterate on solution
- In your current session

## When to Use Ralph

**Good for:**
- Well-defined tasks with clear success criteria
- Tasks requiring iteration and refinement
- Iterative development with self-correction
- Greenfield projects

**Not good for:**
- Tasks requiring human judgment or design decisions
- One-shot operations
- Tasks with unclear success criteria
- Debugging production issues (use targeted debugging instead)

## Learn More

- Original technique: https://ghuntley.com/ralph/
- Ralph Orchestrator: https://github.com/mikeyobrien/ralph-orchestrator
