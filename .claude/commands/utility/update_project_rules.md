---
allowed-tools: Read, MultiEdit
argument-hint: <feedback-or-rules>
description: Update CLAUDE.md with new rules or guidance while maintaining structure
model: claude-opus-4-1
---

# Update CLAUDE.md Project Rules

You are an expert at maintaining and improving CLAUDE.md files - the project instructions that guide Claude Code's behavior in codebases. Your task is to intelligently incorporate new feedback or rules into the existing CLAUDE.md file.

## Your Task

ultrathink. Analyze the provided feedback and update CLAUDE.md following these principles:

### 1. Read and Understand Current Structure
First, read the current CLAUDE.md to understand:
- Existing sections and their purposes
- Current rules and guidelines
- Overall organization and flow
- Writing style and tone

### 2. Analyze the Feedback
Evaluate the new feedback/rules: $ARGUMENTS

Consider:
- What specific guidance is being added
- Where it logically fits in the current structure
- Whether similar guidance already exists
- How to phrase it consistently with existing content

### 3. Intelligent Integration Strategy

Follow these integration principles:
- **Deduplicate**: If similar guidance exists, merge or enhance rather than duplicate
- **Organize**: Place new content in the most appropriate existing section
- **Consolidate**: Combine related points to avoid bloat
- **Clarify**: Ensure new rules are clear and actionable
- **Prioritize**: Place critical instructions prominently
- **Maintain Flow**: Preserve logical progression of information

### 4. CLAUDE.md Best Practices

Maintain these qualities in the updated file:
- **Conciseness**: Every line should add value
- **Clarity**: Instructions must be unambiguous
- **Structure**: Use clear headings and logical organization
- **Actionability**: Rules should be specific and implementable
- **Context**: Include "why" when it helps understanding
- **Override Power**: Critical instructions should explicitly state they override defaults

### 5. Update Process

1. Read the current CLAUDE.md file
2. Identify the optimal location(s) for new content
3. Check for existing similar guidance to merge or update
4. Use MultiEdit to make precise, contextual changes
5. Ensure the updated file remains well-structured and readable

### 6. Common Section Patterns

Typical CLAUDE.md sections to consider:
- Project Overview
- Development Commands
- Code Style and Conventions
- Testing Guidelines
- Important Instructions/Reminders
- Architecture Patterns
- Dependencies and Tools

### Success Criteria

The updated CLAUDE.md should:
✓ Include all valuable feedback provided
✓ Maintain or improve overall structure
✓ Avoid redundancy and bloat
✓ Preserve existing critical instructions
✓ Read as a cohesive, well-organized document
✓ Be more effective than before the update

Remember: CLAUDE.md is the primary source of truth for how Claude Code should behave in this codebase. Every update should make it more effective at guiding Claude toward successful outcomes.