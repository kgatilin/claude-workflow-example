# .agent/ Folder Structure & Workflow

## Directory Layout

```
.agent/
├── backlog/          # Feature ideas waiting to be worked on
│   └── *.md          # One markdown file per idea
│
├── tasks/            # Active tasks in progress
│   └── task-name/    # One folder per task (matches git branch)
│       ├── stage.yaml                         # Current workflow stage tracker
│       ├── 00_task.md                  # Requirements & user stories
│       ├── 01_test_scenarios.md               # BDD test scenarios
│       ├── 02_implementation_plan.md          # Technical approach & architecture
│       ├── 03_implementation_log.md           # What was implemented (per iteration)
│       ├── 04_agentic_review.md               # Automated code review
│       ├── 05_human_feedback.md               # Human review notes
│       ├── 06_documentation_updates.md        # Documentation changes
│       ├── 07_process_improvements.md         # Lessons learned
│       ├── iterations/                        # Multiple iterations (if needed)
│       │   ├── iteration-1/
│       │   │   ├── plan.md            # Iteration-specific plan
│       │   │   ├── implementation.md  # Implementation log for this iteration
│       │   │   └── tests.md           # Test results for this iteration
│       │   └── iteration-2/
│       │       ├── plan.md
│       │       ├── implementation.md
│       │       └── tests.md
│       └── subtasks/                          # Nested subtasks if needed
│
└── templates/        # Reusable templates
    ├── stage.yaml
    └── task_template.md
```

## How It Works

- **backlog/**: Store new ideas as simple markdown files
- **tasks/**: Each active task gets its own directory with numbered stage files
- **iterations/**: For complex tasks requiring multiple iterations
- **templates/**: Boilerplate for new tasks

## Workflow Stages

### Single Iteration (Simple Tasks)
**Stage Flow**: `task_created` → `planning` → `implement` → `review` → `done`

1. **task_created**: Task initialized from backlog
2. **planning**: Create implementation plan (sets next_stage: implement)
3. **implement**: Execute the single iteration
4. **review**: Code review and testing
5. **done**: Task completed

### Multiple Iterations (Complex Tasks)
**Stage Flow**: `task_created` → `planning` → `decompose` → `implementation_iteration` (repeated) → `review` → `done`

1. **task_created**: Task initialized from backlog
2. **planning**: Create implementation plan (sets next_stage: decompose)
3. **decompose**: Break into iterations, create iteration plans
4. **implementation_iteration**: Execute one iteration (can repeat)
5. **review**: Code review and testing after all iterations
6. **done**: Task completed

## File Purpose

- **stage.yaml**: Tracks which step the task is on and manages iteration state
- **00-07 files**: Document each stage of development - from initial requirements through implementation to lessons learned
- **iterations/**: Contains iteration-specific plans and logs for complex tasks
- **subtasks/**: Break complex tasks into smaller pieces with same structure

## Stage.yaml Fields

- **stage**: Current workflow stage
- **next_stage**: What stage comes next (set by planning command)
  - `implement`: Single iteration approach
  - `decompose`: Multiple iterations needed
- **round**: Current iteration number
- **iterations.planned**: List of planned iterations
- **iterations.done**: List of completed iterations