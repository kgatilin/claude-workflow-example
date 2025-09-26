---
allowed-tools: Read, MultiEdit, Edit, Bash(ls:*), Bash(find:*), Glob
argument-hint: <command-name> <feedback>
description: Improve existing slash commands based on feedback while following best practices
model: claude-opus-4-1
---

# Improve Existing Slash Command

You are an expert at improving and refining custom slash commands for Claude Code. Your task is to enhance the command `$1` based on this feedback: $2

Read:
- @docs/claude/slash_commands.md for slash commands description
- @docs/claude/prompts_best_practices.md for prompt engineering best practices

## Your Process

ultrathink. Use thinking throughout this process to analyze, improve, and verify the command.

### Step 1: Locate and Read the Existing Command

First, find the command file for `$1`:
- Check project commands: `.claude/commands/`
- Check personal commands: `~/.claude/commands/`
- Consider namespace subdirectories

Read the entire command file to understand:
- Current frontmatter configuration
- Existing prompt structure
- Tools and permissions used
- Argument handling pattern

### Step 2: Analyze Current Implementation

think hard. Evaluate the existing command against best practices:

**Frontmatter Analysis:**
- Are the allowed-tools minimal but sufficient?
- Is the argument-hint clear and descriptive?
- Is the model appropriate for the task?
- Is the description concise and accurate?

**Prompt Quality:**
- Does it follow Claude 4 best practices from @docs/claude/prompts_best_practices.md?
- Is it explicit with instructions?
- Does it provide context for why behaviors matter?
- Does it use positive framing (what TO do vs what NOT to do)?
- Are thinking keywords used appropriately for complex tasks?

**Structure and Organization:**
- Is the role clearly defined?
- Are bash commands and file references used effectively?
- Is the task broken down into clear steps?
- Are success criteria defined?

### Step 3: Incorporate Feedback

think. Based on the feedback "$2", determine what improvements are needed:

**Categories of improvements:**
1. **Functionality changes**: New features, different behavior
2. **Performance optimizations**: Better tool usage, parallel execution
3. **Clarity improvements**: Better instructions, clearer structure
4. **Best practice alignment**: Following Claude 4 principles more closely
5. **Tool permission updates**: Adding/removing tool access as needed

**Apply these principles while incorporating feedback:**
- **Be explicit**: Enhance instructions to be more specific about desired outputs
- **Add context**: Explain why changes improve the command's effectiveness
- **Use positive framing**: Rewrite negative instructions as positive ones
- **Match style**: Ensure prompt style aligns with expected output
- **Enable thinking**: Add thinking keywords where complex reasoning is needed
  - `think` - for general improvements
  - `think hard` - for challenging refactoring
  - `think harder` - for complex architectural changes
  - `ultrathink` - for complete redesigns
- **Optimize execution**: Enable parallel tool use where beneficial

### Step 4: Implement Improvements

Using MultiEdit or Edit, update the command file with:
1. **Updated frontmatter** (if needed):
   - Refined allowed-tools
   - Clearer argument-hint
   - Updated description
   - Appropriate model selection

2. **Enhanced prompt body**:
   - Improved role definition
   - Better structured instructions
   - Incorporated feedback changes
   - Added/updated thinking sections
   - Refined success criteria

### Step 5: Verify the Improvements

After updating, verify:
1. The feedback has been fully addressed
2. No functionality was broken by changes
3. The command still follows best practices
4. Arguments are properly referenced
5. Tool permissions remain minimal but sufficient
6. The prompt is clearer and more effective

### Step 6: Document Changes

Provide a summary of:
- What was changed and why
- How the feedback was incorporated
- Best practices that were applied
- Any trade-offs or decisions made

## Output Format

After analysis and improvement:
1. Show the key changes made to the command
2. Explain how each change addresses the feedback
3. Highlight best practices applied
4. Note any additional improvements discovered during analysis

Remember: Good command improvement preserves what works while enhancing based on feedback and best practices. The goal is a more effective, maintainable, and user-friendly command.