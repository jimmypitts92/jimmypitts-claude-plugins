---
description: "Cancel active Ralph Wiggum loop"
allowed-tools: ["Bash(test -f .claude/ralph-it.local.md:*)", "Bash(rm .claude/ralph-it.local.md)", "Read(.claude/ralph-it.local.md)"]
hide-from-slash-command-tool: "true"
---

# Cancel Ralph

To cancel the Ralph loop:

1. Check if `.claude/ralph-it.local.md` exists using Bash: `test -f .claude/ralph-it.local.md && echo "EXISTS" || echo "NOT_FOUND"`

2. **If NOT_FOUND**: Say "No active Ralph loop found."

3. **If EXISTS**:
   - Read `.claude/ralph-it.local.md` to get the current iteration number from the `iteration:` field
   - Remove the file using Bash: `rm .claude/ralph-it.local.md`
   - Report: "Cancelled Ralph loop (was at iteration N)" where N is the iteration value
