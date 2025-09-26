# Claude Code Tools - Practical Examples

## File Operations Examples

### Read Tool
```python
# Read entire file
Read(file_path="/src/components/Button.tsx")

# Read with offset and limit for large files
Read(file_path="/logs/application.log", offset=1000, limit=500)

# Read image for visual analysis
Read(file_path="/designs/mockup.png")

# Read PDF document
Read(file_path="/docs/specification.pdf")
```

### Write Tool
```python
# Create new configuration file
Write(
    file_path="/config/settings.json",
    content='{\n  "api_key": "",\n  "timeout": 30\n}'
)

# Create new component
Write(
    file_path="/src/components/NewFeature.tsx",
    content="import React from 'react';\n\nexport const NewFeature = () => {\n  return <div>New Feature</div>;\n};"
)
```

### Edit Tool
```python
# Fix a typo
Edit(
    file_path="/src/utils/helpers.js",
    old_string="cosnt API_URL",
    new_string="const API_URL"
)

# Update function signature
Edit(
    file_path="/src/api/client.ts",
    old_string="function fetchData(id: number)",
    new_string="function fetchData(id: string)"
)

# Replace all occurrences
Edit(
    file_path="/src/config.js",
    old_string="localhost:3000",
    new_string="api.production.com",
    replace_all=True
)
```

### MultiEdit Tool
```python
# Refactor multiple parts of a file
MultiEdit(
    file_path="/src/components/Form.tsx",
    edits=[
        {
            "old_string": "useState(false)",
            "new_string": "useState<boolean>(false)"
        },
        {
            "old_string": "handleSubmit = (e) =>",
            "new_string": "handleSubmit = (e: FormEvent) =>"
        },
        {
            "old_string": "console.log('debug')",
            "new_string": "",
            "replace_all": True
        }
    ]
)
```

## Search Examples

### Glob Tool
```python
# Find all TypeScript files
Glob(pattern="**/*.ts")

# Find test files
Glob(pattern="**/*.test.js")

# Find files in specific directory
Glob(path="/src/components", pattern="*.tsx")

# Find configuration files
Glob(pattern="**/*.{json,yaml,yml}")
```

### Grep Tool
```python
# Find function definitions
Grep(
    pattern="function\\s+\\w+",
    output_mode="content",
    type="js"
)

# Search for TODO comments with context
Grep(
    pattern="TODO|FIXME",
    output_mode="content",
    -C=2,
    -n=True
)

# Find all imports of a specific module
Grep(
    pattern="import.*from ['\"']react",
    output_mode="files_with_matches",
    glob="**/*.{js,jsx,ts,tsx}"
)

# Count error occurrences
Grep(
    pattern="throw new Error",
    output_mode="count"
)

# Multiline pattern search
Grep(
    pattern="class\\s+\\w+\\s*\\{[\\s\\S]*?constructor",
    multiline=True,
    output_mode="content"
)
```

## Command Execution Examples

### Bash Tool
```python
# Run tests
Bash(
    command="npm test",
    description="Run test suite",
    sandbox=True
)

# Build project with timeout
Bash(
    command="npm run build",
    description="Build production bundle",
    timeout=300000,
    sandbox=True
)

# Run server in background
Bash(
    command="npm run dev",
    description="Start development server",
    run_in_background=True,
    sandbox=True
)

# Chain multiple commands
Bash(
    command="npm install && npm run lint && npm test",
    description="Install, lint, and test",
    sandbox=True
)

# Work with paths containing spaces
Bash(
    command='cd "/Users/name/My Projects" && ls',
    description="List files in directory with spaces",
    sandbox=True
)
```

### Background Shell Management
```python
# Monitor background process
BashOutput(
    bash_id="shell_123",
    filter="ERROR|WARNING"
)

# Terminate background process
KillShell(shell_id="shell_123")
```

## Task Management Examples

### TodoWrite Tool
```python
# Create initial task list
TodoWrite(
    todos=[
        {
            "content": "Analyze existing authentication code",
            "activeForm": "Analyzing existing authentication code",
            "status": "pending"
        },
        {
            "content": "Implement JWT token validation",
            "activeForm": "Implementing JWT token validation",
            "status": "pending"
        },
        {
            "content": "Add refresh token mechanism",
            "activeForm": "Adding refresh token mechanism",
            "status": "pending"
        },
        {
            "content": "Write authentication tests",
            "activeForm": "Writing authentication tests",
            "status": "pending"
        }
    ]
)

# Update task progress
TodoWrite(
    todos=[
        {
            "content": "Analyze existing authentication code",
            "activeForm": "Analyzing existing authentication code",
            "status": "completed"
        },
        {
            "content": "Implement JWT token validation",
            "activeForm": "Implementing JWT token validation",
            "status": "in_progress"
        },
        # ... other todos
    ]
)
```

### Task Agent Tool
```python
# Complex search task
Task(
    description="Find auth implementation",
    prompt="Search the codebase for all authentication and authorization implementations. Look for JWT tokens, OAuth, session management, and middleware. Provide a summary of the auth strategy used.",
    subagent_type="general-purpose"
)

# Multiple parallel agents
# Send both in one message for parallel execution
Task(
    description="Analyze API structure",
    prompt="Examine all API endpoints and create a summary of the REST API structure",
    subagent_type="general-purpose"
)
Task(
    description="Review database schema",
    prompt="Find and analyze all database models and migrations",
    subagent_type="general-purpose"
)
```

## Web Tools Examples

### WebSearch Tool
```python
# Search for latest documentation
WebSearch(
    query="React 18 concurrent features 2025"
)

# Search with domain filtering
WebSearch(
    query="typescript decorators",
    allowed_domains=["typescriptlang.org", "github.com"]
)

# Exclude certain domains
WebSearch(
    query="python async await tutorial",
    blocked_domains=["w3schools.com"]
)
```

### WebFetch Tool
```python
# Fetch and analyze documentation
WebFetch(
    url="https://docs.python.org/3/library/asyncio.html",
    prompt="Extract the main concepts and provide examples of async/await usage"
)

# Analyze API documentation
WebFetch(
    url="https://api.example.com/docs",
    prompt="List all available endpoints with their methods and parameters"
)
```

## Complex Workflow Examples

### Complete Feature Implementation
```python
# 1. Plan the task
TodoWrite(todos=[...])

# 2. Search for similar implementations
Grep(pattern="Modal|Dialog", output_mode="files_with_matches")

# 3. Read example files (parallel)
Read(file_path="/src/components/Modal.tsx")
Read(file_path="/src/components/Dialog.tsx")

# 4. Create new component
Write(file_path="/src/components/Popup.tsx", content="...")

# 5. Add styles
Write(file_path="/src/styles/Popup.css", content="...")

# 6. Run tests
Bash(command="npm test Popup", sandbox=True)

# 7. Update todo status
TodoWrite(todos=[{"status": "completed", ...}])
```

### Debugging Workflow
```python
# 1. Search for error patterns
Grep(pattern="Error:|Exception:", output_mode="content", -C=5)

# 2. Read problematic file
Read(file_path="/src/api/handler.js")

# 3. Check recent changes
Bash(command="git diff HEAD~1 /src/api/handler.js", sandbox=True)

# 4. Fix the issue
Edit(
    file_path="/src/api/handler.js",
    old_string="response.send(data)",
    new_string="response.json(data)"
)

# 5. Verify fix
Bash(command="npm test -- handler.test.js", sandbox=True)
```

### Refactoring Workflow
```python
# 1. Find all occurrences
Grep(pattern="oldFunctionName", output_mode="files_with_matches")

# 2. Read affected files (parallel batch)
Read(file_path="/src/utils.js")
Read(file_path="/src/api.js")
Read(file_path="/tests/utils.test.js")

# 3. Perform refactoring (parallel batch)
Edit(file_path="/src/utils.js", old_string="oldFunctionName", new_string="newFunctionName", replace_all=True)
Edit(file_path="/src/api.js", old_string="oldFunctionName", new_string="newFunctionName", replace_all=True)
Edit(file_path="/tests/utils.test.js", old_string="oldFunctionName", new_string="newFunctionName", replace_all=True)

# 4. Run tests and lint
Bash(command="npm run lint && npm test", sandbox=True)
```

### Git Workflow
```python
# 1. Check status (parallel batch)
Bash(command="git status", sandbox=True)
Bash(command="git diff", sandbox=True)
Bash(command="git log --oneline -10", sandbox=True)

# 2. Stage changes
Bash(command="git add -A", sandbox=True)

# 3. Commit with heredoc
Bash(
    command='''git commit -m "$(cat <<'EOF'
Fix authentication bug in user login

- Corrected JWT token expiration handling
- Added proper error messages
- Updated test cases

🤖 Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"''',
    sandbox=True
)

# 4. Create pull request
Bash(
    command='''gh pr create --title "Fix authentication bug" --body "$(cat <<'EOF'
## Summary
- Fixed JWT token expiration issue
- Improved error handling
- Added comprehensive tests

## Test plan
- [x] Unit tests pass
- [x] Integration tests pass
- [x] Manual testing completed

🤖 Generated with Claude Code
EOF
)"''',
    sandbox=True
)
```

## Performance Optimization Patterns

### Parallel File Operations
```python
# Read multiple files in parallel (single message)
Read(file_path="/src/index.js")
Read(file_path="/src/app.js")
Read(file_path="/package.json")
Read(file_path="/tsconfig.json")
```

### Parallel Search Operations
```python
# Execute multiple searches in parallel (single message)
Grep(pattern="TODO", output_mode="content")
Grep(pattern="FIXME", output_mode="content")
Glob(pattern="**/*.test.js")
Glob(pattern="**/*.spec.js")
```

### Parallel Command Execution
```python
# Run multiple commands in parallel (single message)
Bash(command="npm run lint", sandbox=True)
Bash(command="npm run typecheck", sandbox=True)
Bash(command="npm test", sandbox=True)
```

## Error Handling Examples

### Safe File Editing
```python
# 1. Always read first
content = Read(file_path="/config.json")

# 2. Make backup if critical
Bash(command="cp /config.json /config.json.backup", sandbox=True)

# 3. Perform edit with unique string
Edit(
    file_path="/config.json",
    old_string='"version": "1.0.0"',  # Include enough context
    new_string='"version": "1.1.0"'
)

# 4. Validate changes
Read(file_path="/config.json")
```

### Handling Edit Failures
```python
# If edit fails due to non-unique string:
# Option 1: Add more context
Edit(
    file_path="/src/app.js",
    old_string="  const data = {\n    id: 1,\n    name: 'test'\n  }",
    new_string="  const data = {\n    id: 1,\n    name: 'production'\n  }"
)

# Option 2: Use replace_all if appropriate
Edit(
    file_path="/src/app.js",
    old_string="'test'",
    new_string="'production'",
    replace_all=True
)
```

## Best Practice Examples

### Creating a New Feature
```python
# 1. Check existing patterns
examples = Glob(pattern="src/features/**/index.ts")
Read(file_path=examples[0])  # Read one example

# 2. Create feature structure
Bash(command="mkdir -p src/features/newFeature", sandbox=True)

# 3. Create files following conventions
Write(file_path="/src/features/newFeature/index.ts", content="...")
Write(file_path="/src/features/newFeature/types.ts", content="...")
Write(file_path="/src/features/newFeature/newFeature.test.ts", content="...")

# 4. Run validation
Bash(command="npm run typecheck && npm test", sandbox=True)
```

### Safe Refactoring
```python
# 1. Create todo list for tracking
TodoWrite(todos=[{"content": "Refactor user service", ...}])

# 2. Understand current implementation
Read(file_path="/src/services/userService.js")
Grep(pattern="userService", output_mode="files_with_matches")

# 3. Check for tests
test_files = Glob(pattern="**/*userService*.test.js")

# 4. Make changes
MultiEdit(file_path="/src/services/userService.js", edits=[...])

# 5. Run tests immediately
Bash(command="npm test -- userService", sandbox=True)

# 6. Update all imports if needed
affected_files = Grep(pattern="from.*userService", output_mode="files_with_matches")
# Edit each affected file...

# 7. Final validation
Bash(command="npm run build && npm test", sandbox=True)
```