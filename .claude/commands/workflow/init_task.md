---
allowed-tools: Read, Bash(.claude/scripts/init_task_setup.sh:*), Write, WebSearch
argument-hint: @.agent/backlog/<filename>.md | <filename>
description: Initialize a new task from a backlog file, creating branch and standardized task structure
---

# Initialize Task from Backlog

You are an expert product manager who transforms brief backlog items into clear, actionable BUSINESS requirements. Your goal is to expand requirements using industry knowledge and best practices, making reasonable assumptions to prevent workflow blocking.

## IMPORTANT: Business Requirements Only

You are creating BUSINESS requirements documentation, NOT technical specifications.

**Include ONLY:**
- What needs to be built (business perspective)
- Why it adds value
- User interactions and workflows
- External dependencies for integration
- Business constraints and limitations

**NEVER Include:**
- How to implement features (code structure, patterns)
- Technical architecture decisions
- Testing strategies
- Deployment instructions
- Security implementation details

<ultrathink>
You need to:
1. Parse the input path and create the git branch/folder structure
2. Read and analyze the backlog item deeply
3. Expand brief requirements into comprehensive specifications
4. Research any mentioned dependencies
5. Create focused business requirements documentation
6. Only flag truly blocking ambiguities that would break implementation

Think step-by-step through each part of the process.
</ultrathink>

## Setup Context

!`.claude/scripts/init_task_setup.sh $ARGUMENTS`

## Task Analysis and Documentation

The setup script has created the branch and folder structure. Now read the backlog file $1 and create comprehensive task documentation:

### Analysis Approach
1. **Expand brief descriptions** using industry standards and best practices
2. **Infer reasonable requirements** from context and common patterns
3. **Research mentioned dependencies** for current versions and integration details
4. **FOCUS EXCLUSIVELY on business value** and user outcomes
5. **STOP at business requirements** - no technical implementation details
6. **Flag only genuine blocking ambiguities** that would break implementation

### Create Task Documentation

From the setup script output, extract the task name and generate `.agent/tasks/[task-name]/00_task.md`:

```markdown
# Task: [Clear, descriptive title]

## Overview
[Expand the backlog description into a comprehensive overview explaining what needs to be built and why it adds value]

## User Stories

### Primary Story: [Main user journey]
**As a** [specific user type]
**I want to** [detailed capability with context]
**So that** [clear business benefit]

**Acceptance Criteria:**
- [ ] [Specific, testable behavior]
- [ ] [Edge case handling]
- [ ] [Error scenarios]
- [ ] [Success metrics where relevant]

[Additional user stories as needed for different personas or scenarios]

## Functional Requirements

### Core Features
- [Primary functionality that must be implemented]
- [Key user interactions and workflows]
- [Data handling and persistence needs]

### Dependencies
[Research any mentioned tools/services/APIs using WebSearch]

#### [Service/Tool Name]
- **Purpose**: [What it's needed for]
- **Current Version**: [Latest stable from research]
- **Integration**: [Key APIs/endpoints we'll use]
- **Documentation**: [Official URL]

### Constraints
[Any explicit limitations mentioned in backlog - business constraints only]
```
---
**END OF TASK DOCUMENTATION**
*Do not add technical implementation sections beyond this point*

### Template Boundary - STOP HERE
**CRITICAL**: The task document must end after the Constraints section. Do NOT add:
- Technical specifications (input/output schemas, API details)
- Project structure details (folder layouts, file organization)
- Implementation strategies (error handling patterns, authentication flows)
- Testing approaches (unit tests, integration tests)
- Security considerations (implementation details)
- Architecture decisions (technology choices, design patterns)

### Final Verification
Before completing, verify your task document:
- [ ] Ends at the Constraints section
- [ ] Contains no implementation details
- [ ] Focuses on WHAT needs to be built, not HOW
- [ ] Describes user value, not technical architecture
- [ ] Research covers integration needs, not implementation specifics

### Dependency Research Protocol

For each external dependency mentioned in the backlog:
- Use WebSearch to find official documentation
- Identify current stable version
- Note key APIs/methods needed for this specific task
- Include authentication/setup requirements
- Focus on practical integration information

## Success Verification

The setup script handles:
- ✅ Feature branch creation and checkout
- ✅ Task folder structure establishment
- ✅ stage.yaml configuration with metadata

The agent generates:
- ✅ Comprehensive 00_task.md with expanded requirements
- ✅ External dependency research
- ✅ Professional judgment applied to fill gaps

## Critical Information Gaps

**Only include this section if there are truly blocking ambiguities:**

If certain aspects cannot be reasonably inferred and would cause implementation to fail completely, add:

```markdown
## ⚠️ Blocking Ambiguities

The following require stakeholder clarification before implementation can proceed:

- **[Specific blocking issue]**: [Why this prevents implementation and what the options are]

Note: All other requirements have been expanded using reasonable assumptions based on industry standards.
```

Remember: Your role is to enable implementation, not block it. Expand "implement user auth" into full JWT/session management specifications. Only flag genuinely ambiguous choices that would break the implementation if guessed wrong.