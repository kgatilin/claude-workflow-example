---
allowed-tools: Write, Read, MultiEdit, Bash(mkdir:*), Bash(ls:*), Bash(cat:*)
argument-hint: <command-name> <purpose>
description: Create and verify new custom slash commands with best practices
model: claude-opus-4-1
---

# Create New Custom Slash Command

You are an expert at creating effective custom slash commands for Claude Code. Your task is to help create a new slash command named `$1` with the purpose: $2

Read:
- @docs/claude/slash_commands.md for slash commands description
- @docs/claude/prompts_best_practices.md for prompt engineering best practices

## Your Process

ultrathink. Use thinking throughout this process to reason step-by-step.

### Step 1: Analyze Requirements
Based on the purpose "$2", determine:
- What specific task this command should accomplish
- Whether it needs arguments (and design the argument pattern)
- Which tools it requires access to
- Whether it needs bash command execution or file references
- The appropriate model to use (default to current unless specific needs)
- See if it is a part of the task workflow (@.claude/snippets/agents-workflow.md) - store in `.claude/commands/workflow/` folder if so

### Step 2: Apply Best Practices
Following Claude 4 prompt engineering principles (@.claude/snippets/prompt-best-practices.md):
- **Be explicit**: Write clear, specific instructions about the desired output
- **Add context**: Explain why behaviors are important to improve understanding
- **Use positive framing**: Tell Claude what TO do, not what NOT to do
- **Match style**: Keep prompt style consistent with desired output format
- **Enable thinking**: Include thinking keywords and step-by-step reasoning when appropriate
  - `think` - for general reflection
  - `think hard` - for more challenging problems
  - `think harder` - for complex problems
  - `ultrathink` - for very complex multi-step reasoning
- **Optimize for parallel execution**: Encourage simultaneous tool use when beneficial

### Step 3: Design the Command Structure

Create a command with this structure:
1. **Frontmatter**: Include appropriate metadata
   - `allowed-tools`: List specific tools and commands needed
   - `argument-hint`: Clear pattern like `[file] [options]` if arguments needed
   - `description`: Concise one-line description
   - `model`: Always specify the model explicitly (`claude-sonnet-4-0` by default, `claude-opus-4-1` for planning, review, analysis etc.)

2. **Command Body**:
   - Start with a clear role definition
   - Include context sections with bash commands (!) or file references (@) if needed
   - Provide explicit task instructions
   - Include success criteria or verification steps

### Step 4: Create the Command File

- Project command (`.claude/commands/`)
- Namespace with subdirectory if part of a command group

Write the command to the appropriate location with filename: `$1.md`

### Step 5: Verify the Command

After creating, verify:
1. The frontmatter is valid and complete
2. Arguments are properly referenced ($ARGUMENTS or $1, $2, etc.)
3. The prompt follows best practices (explicit, contextual, positive)
4. Tool permissions are minimal but sufficient

Remember: A good slash command is focused, reusable, and follows Claude 4 prompt engineering best practices for optimal results.