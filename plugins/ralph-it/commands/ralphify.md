---
description: "Reformat a prompt to be better suited for Ralph loops"
argument-hint: "--file PROMPT_FILE [--output OUTPUT_FILE] [--promise TEXT]"
allowed-tools: ["Bash(${CLAUDE_PLUGIN_ROOT}/scripts/ralphify.sh:*)"]
hide-from-slash-command-tool: "true"
---

# Ralphify Command

Transform a simple prompt into a structured Ralph-ready prompt with best practices.

Execute the ralphify script to parse arguments and display the original prompt:

```!
"${CLAUDE_PLUGIN_ROOT}/scripts/ralphify.sh" $ARGUMENTS
```

After the script runs, you must reformat the prompt following these Ralph loop best practices:

## Transformation Rules

1. **Add Clear Structure**: Convert vague requests into numbered, actionable steps
2. **Include Verification**: Add "run tests", "verify", "check" steps after each implementation
3. **Add Self-Correction Loop**: Include explicit "if tests fail, debug and fix" instructions
4. **Add Completion Criteria**: List specific conditions that must be true before completion
5. **Add Completion Promise Instructions** (CRITICAL): Include explicit instructions to output the promise
6. **Add Fallback Behavior**: Specify what to do if stuck after many iterations
7. **Be Specific**: Replace vague terms with concrete requirements

## CRITICAL: Completion Promise Instructions

**This is the most important part of ralphifying a prompt!**

The optimized prompt MUST include a section that explicitly tells Claude to output the completion promise.

### Promise Text Selection

Check the `RALPHIFY_COMPLETION_PROMISE` environment variable:
- If set and not empty: Use that EXACT text as the promise
- If empty or not set: Generate an appropriate promise like:
  - "COMPLETE" (generic tasks)
  - "TESTS PASSING" (test-focused tasks)
  - "DEPLOYED" (deployment tasks)
  - "REFACTORED" (refactoring tasks)
  - "FIXED" (bug fixes)

### Required Promise Output Section

The optimized prompt MUST include a "Completion Criteria" section that uses this EXACT format:

```markdown
## Completion Criteria

Output `<promise>PROMISE_TEXT</promise>` ONLY when ALL of these are true:
- ✓ [specific condition 1]
- ✓ [specific condition 2]
- ✓ [specific condition 3]
```

Replace `PROMISE_TEXT` with the actual promise text determined above.

**IMPORTANT**: The prompt must instruct Claude to output the promise tag in this exact format:
```
<promise>PROMISE_TEXT</promise>
```

Do NOT just mention the promise - you must include explicit instructions to OUTPUT it when complete!

## Example Transformation

❌ Original:
```
Build a REST API for todos
```

✅ Ralphified:
```markdown
# Task: Build REST API for Todos

## Requirements
- GET /todos - list all todos
- POST /todos - create new todo
- PUT /todos/:id - update todo
- DELETE /todos/:id - delete todo
- Input validation on all endpoints
- Test coverage > 80%

## Implementation Steps

1. **Set up project structure**
   - Create API directory structure
   - Set up testing framework
   - Configure linter

2. **Implement each endpoint**
   - Write tests FIRST (TDD approach)
   - Implement endpoint to pass tests
   - Run tests: if any fail, debug and fix
   - Move to next endpoint only when current tests pass

3. **Add validation**
   - Implement input validation for all endpoints
   - Add validation tests
   - Run tests: if any fail, debug and fix

4. **Verify completion**
   - Run full test suite
   - Check coverage meets 80% threshold
   - Verify all requirements met

5. **Self-correction loop**
   - After each change, run tests
   - If tests fail: read error, identify issue, fix, retest
   - Repeat until all tests pass

## Completion Criteria

Output `<promise>API COMPLETE</promise>` ONLY when ALL of these are true:
- ✓ All 4 CRUD endpoints implemented
- ✓ Input validation working on all endpoints
- ✓ All tests passing
- ✓ Test coverage > 80%
- ✓ No linter errors

## If Stuck After 15+ Iterations

If not complete after 15 iterations:
- Document what's blocking progress in BLOCKED.md
- List all approaches attempted
- Suggest alternative strategies
- Continue attempting fixes (do not give up)
```

## Your Task

Read the original prompt from the script output. Transform it following the rules above. Then:

1. **Check `RALPHIFY_COMPLETION_PROMISE` env var** to get the promise text
2. **ALWAYS include a "Completion Criteria" section** with explicit instructions to output the promise
3. Display the ralphified prompt in a clear markdown code block
4. If `RALPHIFY_OUTPUT_FILE` env var is set, write the ralphified prompt to that file
5. Provide a brief summary of what improvements were made

## Critical Checklist Before Outputting

Before you output the ralphified prompt, verify:
- ✅ Does it have a "Completion Criteria" section?
- ✅ Does that section explicitly instruct to output `<promise>TEXT</promise>`?
- ✅ Is the promise text correct (from `RALPHIFY_COMPLETION_PROMISE` or auto-generated)?
- ✅ Are there clear conditions that must be true before outputting the promise?

If any of these are missing, FIX IT before outputting!
