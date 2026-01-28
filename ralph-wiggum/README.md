# Ralph Wiggum Plugin

Implementation of the Ralph Wiggum technique for iterative, self-referential AI development loops in Claude Code.

## What is Ralph?

Ralph is a development methodology based on continuous AI agent loops. As Geoffrey Huntley describes it: **"Ralph is a Bash loop"** - a simple `while true` that repeatedly feeds an AI agent the same prompt file, allowing it to iteratively improve its work until completion.

The technique is named after Ralph Wiggum from The Simpsons, embodying the philosophy of persistent iteration despite setbacks.

### Core Concept

This plugin implements Ralph using a **Stop hook** that intercepts Claude's exit attempts:

```bash
# You run ONCE:
/ralph-loop prompt.md --completion-promise "DONE"

# Then Claude Code automatically:
# 1. Works on the task
# 2. Tries to exit
# 3. Stop hook blocks exit
# 4. Stop hook feeds the prompt from the file back
# 5. Repeat until completion
```

The loop happens **inside your current session** - you don't need external bash loops. The Stop hook in `hooks/stop-hook.sh` creates the self-referential feedback loop by blocking normal session exit.

This creates a **self-referential feedback loop** where:
- The prompt file content is read fresh each iteration
- Claude's previous work persists in files
- Each iteration sees modified files and git history
- Claude autonomously improves by reading its own past work in files
- The prompt file can be updated between iterations if needed

## Quick Start

### Option 1: Use /ralphify to optimize your prompt

```bash
# Let Claude optimize your prompt
/ralphify "Build a REST API for todos with CRUD operations" --output prompt.md --promise "COMPLETE"

# Then start the loop
/ralph-loop prompt.md --completion-promise "COMPLETE" --max-iterations 50
```

### Option 2: Write your own prompt file

```bash
# prompt.md
Build a REST API for todos. Requirements: CRUD operations, input validation, tests. Output <promise>COMPLETE</promise> when done.
```

Then run:

```bash
/ralph-loop prompt.md --completion-promise "COMPLETE" --max-iterations 50
```

Claude will:
- Implement the API iteratively
- Run tests and see failures
- Fix bugs based on test output
- Iterate until all requirements met
- Output the completion promise when done

## Commands

### /ralph-loop

Start a Ralph loop in your current session.

**Usage:**
```bash
/ralph-loop PROMPT_FILE --max-iterations <n> --completion-promise "<text>"
```

**Arguments:**
- `PROMPT_FILE` - Path to file containing the prompt for the loop

**Options:**
- `--max-iterations <n>` - Stop after N iterations (default: unlimited)
- `--completion-promise <text>` - Phrase that signals completion

### /ralphify

Transform a simple prompt into a structured Ralph-optimized prompt.

**Usage:**
```bash
/ralphify "Your prompt text"
/ralphify --file prompt.txt --output optimized-prompt.md
/ralphify --file rough.txt --promise "COMPLETE" --output final.md
```

**Arguments:**
- `PROMPT_TEXT` - Direct prompt text (if not using --file)

**Options:**
- `--file <path>` - Read prompt from file
- `--output <path>` - Save optimized prompt to file (default: display only)
- `--promise <text>` - Suggested completion promise (default: auto-generated)

**What it does:**
- Adds clear structure with numbered steps
- Includes verification and testing steps
- Adds self-correction loops
- Adds explicit completion criteria
- Adds completion promise tags
- Adds fallback behavior for when stuck

### /cancel-ralph

Cancel the active Ralph loop.

**Usage:**
```bash
/cancel-ralph
```

## Prompt Writing Best Practices

**TIP:** Use `/ralphify` to automatically optimize your prompts according to these best practices!

```bash
/ralphify "Your rough idea" --output optimized-prompt.md
```

### 1. Clear Completion Criteria

❌ Bad (bad-prompt.md):
```markdown
Build a todo API and make it good.
```

✅ Good (good-prompt.md):
```markdown
Build a REST API for todos.

When complete:
- All CRUD endpoints working
- Input validation in place
- Tests passing (coverage > 80%)
- README with API docs
- Output: <promise>COMPLETE</promise>
```

### 2. Incremental Goals

❌ Bad (bad-prompt.md):
```markdown
Create a complete e-commerce platform.
```

✅ Good (good-prompt.md):
```markdown
Phase 1: User authentication (JWT, tests)
Phase 2: Product catalog (list/search, tests)
Phase 3: Shopping cart (add/remove, tests)

Output <promise>COMPLETE</promise> when all phases done.
```

### 3. Self-Correction

❌ Bad (bad-prompt.md):
```markdown
Write code for feature X.
```

✅ Good (good-prompt.md):
```markdown
Implement feature X following TDD:
1. Write failing tests
2. Implement feature
3. Run tests
4. If any fail, debug and fix
5. Refactor if needed
6. Repeat until all green
7. Output: <promise>COMPLETE</promise>
```

### 4. Escape Hatches

Always use `--max-iterations` as a safety net to prevent infinite loops on impossible tasks:

```bash
# Recommended: Always set a reasonable iteration limit
/ralph-loop prompt.md --max-iterations 20
```

In your prompt file, include what to do if stuck:
```markdown
# prompt.md
Try to implement feature X.

After 15 iterations, if not complete:
- Document what's blocking progress
- List what was attempted
- Suggest alternative approaches
```

**Note**: The `--completion-promise` uses exact string matching, so you cannot use it for multiple completion conditions (like "SUCCESS" vs "BLOCKED"). Always rely on `--max-iterations` as your primary safety mechanism.

## Ralphify Examples

### Example 1: Simple Task

**Before ralphify:**
```
Build a todo API
```

**After `/ralphify "Build a todo API" --promise "COMPLETE"`:**
```markdown
# Task: Build Todo API

## Requirements
- GET /todos - list all todos
- POST /todos - create todo
- PUT /todos/:id - update todo
- DELETE /todos/:id - delete todo
- Basic validation
- Tests for each endpoint

## Implementation Steps

1. **Set up project**
   - Initialize Node.js/Python/etc project
   - Install dependencies
   - Set up testing framework

2. **Implement CRUD endpoints (TDD approach)**
   - Write test for GET /todos
   - Implement endpoint to pass test
   - Run test: if fails, debug and fix
   - Repeat for POST, PUT, DELETE

3. **Add validation**
   - Add input validation
   - Add validation tests
   - Run tests: if any fail, fix

4. **Verify completion**
   - Run full test suite
   - All tests must pass

## Completion Criteria

Output `<promise>COMPLETE</promise>` when:
- ✓ All 4 CRUD endpoints working
- ✓ Validation in place
- ✓ All tests passing

## If Stuck After 15 Iterations

- Document blockers
- List approaches tried
- Continue attempting fixes
```

### Example 2: Bug Fix

**Before ralphify:**
```
Fix the memory leak in the cache module
```

**After `/ralphify "Fix the memory leak in the cache module" --promise "FIXED"`:**
```markdown
# Task: Fix Memory Leak in Cache Module

## Investigation Steps

1. **Reproduce the issue**
   - Run the application
   - Monitor memory usage
   - Identify leak pattern
   - Document findings

2. **Analyze the code**
   - Review cache module implementation
   - Look for: unclosed connections, event listeners, circular references
   - Identify likely causes

3. **Implement fix**
   - Write test that exposes the leak
   - Implement fix
   - Run test: if fails, iterate
   - Verify memory usage stable

4. **Verify resolution**
   - Run extended memory profiling
   - Check for regression in other areas
   - All tests must pass

## Completion Criteria

Output `<promise>FIXED</promise>` when:
- ✓ Memory leak no longer occurs
- ✓ Memory usage stable over time
- ✓ All existing tests still pass
- ✓ New test added to prevent regression

## If Stuck After 10 Iterations

- Document suspected causes
- List all approaches tried
- Suggest alternative debugging strategies
```

## Philosophy

Ralph embodies several key principles:

### 1. Iteration > Perfection
Don't aim for perfect on first try. Let the loop refine the work.

### 2. Failures Are Data
"Deterministically bad" means failures are predictable and informative. Use them to tune prompts.

### 3. Operator Skill Matters
Success depends on writing good prompts, not just having a good model. Use `/ralphify` to learn and apply prompt best practices.

### 4. Persistence Wins
Keep trying until success. The loop handles retry logic automatically.

## When to Use Ralph

**Good for:**
- Well-defined tasks with clear success criteria
- Tasks requiring iteration and refinement (e.g., getting tests to pass)
- Greenfield projects where you can walk away
- Tasks with automatic verification (tests, linters)

**Not good for:**
- Tasks requiring human judgment or design decisions
- One-shot operations
- Tasks with unclear success criteria
- Production debugging (use targeted debugging instead)

## Real-World Results

- Successfully generated 6 repositories overnight in Y Combinator hackathon testing
- One $50k contract completed for $297 in API costs
- Created entire programming language ("cursed") over 3 months using this approach

## Learn More

- Original technique: https://ghuntley.com/ralph/
- Ralph Orchestrator: https://github.com/mikeyobrien/ralph-orchestrator

## For Help

Run `/help` in Claude Code for detailed command reference and examples.
