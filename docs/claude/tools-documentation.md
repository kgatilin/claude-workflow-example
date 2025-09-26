# Claude Code Tools Documentation

## Overview
Claude Code has access to a comprehensive suite of tools designed for software engineering tasks, file management, web research, and task organization. This document provides detailed information about each tool, including usage patterns, best practices, and examples.

## Core Development Tools

### 1. **Bash** - Command Execution
Execute shell commands in a persistent shell session with optional timeout and sandbox restrictions.

**Key Features:**
- Persistent shell session across commands
- Timeout control (default 2 minutes, max 10 minutes)
- Sandbox mode for security (enabled by default)
- Background execution capability
- Automatic path quoting for spaces

**Usage Guidelines:**
- Always set `sandbox: true` by default
- Use `/tmp/claude/` for temporary files in sandbox mode
- Quote file paths containing spaces
- Prefer absolute paths over `cd` commands
- Use `;` or `&&` to chain multiple commands
- Avoid using `find`, `grep`, `cat`, `head`, `tail` - use specialized tools instead

**Common Use Cases:**
- Running builds and tests
- Package management (npm, pip, cargo)
- Git operations
- File system operations
- Process management

### 2. **Read** - File Reading
Read any file from the local filesystem, including text files, images, PDFs, and Jupyter notebooks.

**Key Features:**
- Supports all file types (text, binary, images)
- Line number display with cat -n format
- Offset and limit for large files
- Visual rendering for images
- PDF page-by-page processing
- Jupyter notebook cell extraction

**Usage Guidelines:**
- Always use absolute paths
- Default reads up to 2000 lines
- Lines longer than 2000 characters are truncated
- Batch multiple file reads for efficiency
- Must read before editing files

**Common Use Cases:**
- Code review and analysis
- Understanding file structure
- Reading configuration files
- Viewing screenshots and diagrams
- Analyzing Jupyter notebooks

### 3. **Edit** - File Modification
Perform exact string replacements in files with precise matching.

**Key Features:**
- Exact string matching required
- Preserves indentation and formatting
- Replace single or all occurrences
- Requires file read before editing

**Usage Guidelines:**
- Must use Read tool first
- Preserve exact indentation from file
- Provide unique strings or use replace_all
- Never include line numbers in replacements
- Prefer over Write for existing files

**Common Use Cases:**
- Bug fixes
- Code refactoring
- Configuration updates
- Variable renaming

### 4. **MultiEdit** - Batch File Edits
Make multiple sequential edits to a single file in one operation.

**Key Features:**
- Multiple edits in sequence
- Atomic operation (all or nothing)
- Each edit operates on previous result
- More efficient than multiple Edit calls

**Usage Guidelines:**
- Plan edit order carefully
- Ensure edits don't conflict
- All edits must be valid
- Ideal for complex refactoring

**Common Use Cases:**
- Large-scale refactoring
- Multiple related changes
- Complex code updates
- Systematic replacements

### 5. **Write** - File Creation
Create new files or completely overwrite existing ones.

**Key Features:**
- Creates new files
- Overwrites existing files
- Supports any file type
- Directory creation if needed

**Usage Guidelines:**
- Prefer Edit/MultiEdit for existing files
- Never create docs/README unless requested
- Read existing files before overwriting
- Use absolute paths

**Common Use Cases:**
- Creating new components
- Configuration file generation
- Script creation
- Initial project setup

### 6. **NotebookEdit** - Jupyter Notebook Editing
Modify specific cells in Jupyter notebooks with precision.

**Key Features:**
- Cell-level editing
- Support for code and markdown cells
- Insert, replace, or delete cells
- Cell ID-based targeting

**Usage Guidelines:**
- Use absolute notebook paths
- Specify cell type for new cells
- Cell IDs for precise targeting

**Common Use Cases:**
- Data science workflows
- Notebook maintenance
- Cell updates and fixes
- Documentation updates

## Search and Analysis Tools

### 7. **Glob** - File Pattern Matching
Fast file discovery using glob patterns across any codebase size.

**Key Features:**
- Standard glob pattern support
- Recursive matching with `**`
- Sorted by modification time
- Efficient for large codebases

**Usage Guidelines:**
- Use for file discovery by name
- Patterns like `**/*.js`, `src/**/*.ts`
- Batch multiple searches
- Default uses current directory

**Common Use Cases:**
- Finding all files of a type
- Locating test files
- Discovering configuration files
- Project structure analysis

### 8. **Grep** - Content Search
Powerful content search using ripgrep with full regex support.

**Key Features:**
- Full regex syntax support
- Multiple output modes (content, files, count)
- Context lines (before/after)
- File type filtering
- Multiline pattern support

**Usage Guidelines:**
- Never use bash grep/rg commands
- Use for content searches
- Specify output mode appropriately
- Enable multiline for cross-line patterns

**Common Use Cases:**
- Finding function definitions
- Searching for error patterns
- Locating TODO comments
- Code pattern analysis

## Task Management Tools

### 9. **Task** - Agent Delegation
Launch specialized autonomous agents for complex, multi-step tasks.

**Agent Types:**
- **general-purpose**: Complex research and multi-step tasks
- **statusline-setup**: Configure status line settings
- **output-style-setup**: Create output styles

**Usage Guidelines:**
- Launch multiple agents concurrently when possible
- Provide detailed task descriptions
- Specify expected return information
- Each invocation is stateless
- Use for complex searches and analysis

**Common Use Cases:**
- Complex codebase analysis
- Multi-file searches
- Research tasks
- Configuration setups

### 10. **TodoWrite** - Task Tracking
Create and manage structured task lists for coding sessions.

**Key Features:**
- Three states: pending, in_progress, completed
- Real-time status updates
- Task breakdown capability
- Progress visibility

**Usage Guidelines:**
- Use for tasks with 3+ steps
- One task in_progress at a time
- Update status immediately
- Include both content and activeForm
- Mark complete only when fully done

**Common Use Cases:**
- Feature implementation
- Bug fix tracking
- Multi-step refactoring
- Complex debugging

### 11. **ExitPlanMode** - Planning Completion
Signal completion of planning phase and readiness to code.

**Usage Guidelines:**
- Only for implementation planning
- Not for research tasks
- Include concise plan summary
- Use after planning steps

**Common Use Cases:**
- Feature planning completion
- Architecture design finalization
- Implementation strategy approval

## Web and Research Tools

### 12. **WebFetch** - URL Content Retrieval
Fetch and analyze web content with AI processing.

**Key Features:**
- HTML to markdown conversion
- AI-powered content extraction
- 15-minute cache
- Redirect handling
- HTTPS upgrade

**Usage Guidelines:**
- Prefer MCP tools if available
- Use fully-formed URLs
- Handle redirects with new requests
- Specify extraction prompts clearly

**Common Use Cases:**
- Documentation retrieval
- API reference lookup
- Tutorial analysis
- External resource gathering

### 13. **WebSearch** - Internet Search
Search the web for current information beyond knowledge cutoff.

**Key Features:**
- Current event information
- Domain filtering (allow/block)
- US-based searches
- Formatted search results

**Usage Guidelines:**
- Account for current date in searches
- Use for recent information
- Apply domain filters as needed
- Consider search query optimization

**Common Use Cases:**
- Latest documentation
- Recent updates
- Current best practices
- New technology research

## Shell Management Tools

### 14. **BashOutput** - Background Output Retrieval
Monitor and retrieve output from background shell processes.

**Key Features:**
- New output since last check
- Stdout and stderr capture
- Shell status monitoring
- Regex filtering support

**Usage Guidelines:**
- Use shell IDs from /bashes command
- Returns only new output
- Apply filters carefully
- Monitor long-running processes

**Common Use Cases:**
- Build process monitoring
- Test execution tracking
- Server log monitoring
- Background job management

### 15. **KillShell** - Process Termination
Terminate running background shell processes.

**Key Features:**
- Shell ID-based termination
- Success/failure status
- Clean process shutdown

**Usage Guidelines:**
- Get shell IDs from /bashes
- Use for stuck processes
- Confirm termination need

**Common Use Cases:**
- Stopping runaway processes
- Cleaning up after tasks
- Terminating test servers
- Process management

### 16. **SlashCommand** - Command Execution
Execute predefined slash commands within the conversation.

**Key Features:**
- Command validation
- Argument support
- Available command listing
- Direct execution

**Usage Guidelines:**
- Only use available commands
- Include required arguments
- Check command status first
- Avoid duplicate execution

**Common Use Cases:**
- PR reviews
- Specialized workflows
- Custom automations
- User-defined commands

## Best Practices

### Tool Selection Strategy
1. **For File Operations:**
   - Read before Edit/Write
   - Prefer Edit over Write for existing files
   - Use MultiEdit for multiple changes
   - Glob for file discovery
   - Grep for content search

2. **For Development Tasks:**
   - Bash for commands and builds
   - TodoWrite for task tracking
   - Task for complex analysis
   - Read-Edit cycle for modifications

3. **For Research:**
   - WebSearch for current info
   - WebFetch for specific pages
   - Grep/Glob for codebase exploration
   - Task for comprehensive searches

### Performance Optimization
- Batch tool calls when possible
- Run independent operations in parallel
- Use appropriate search tools
- Cache web results automatically
- Minimize context with Task delegation

### Security Considerations
- Always use sandbox mode for Bash
- Never commit secrets or keys
- Avoid credential harvesting
- Use /tmp/claude/ for temp files
- Quote paths with spaces

### Common Patterns

#### Pattern 1: Code Modification
```
1. Read file to understand context
2. Plan changes with TodoWrite
3. Use Edit/MultiEdit for changes
4. Run tests with Bash
5. Mark todos complete
```

#### Pattern 2: Codebase Exploration
```
1. Glob to find relevant files
2. Grep to search content
3. Read specific files
4. Task for deep analysis
```

#### Pattern 3: Feature Implementation
```
1. TodoWrite for planning
2. Read existing code patterns
3. Write/Edit for implementation
4. Bash for testing
5. Update todo status
```

#### Pattern 4: Debugging
```
1. Grep for error patterns
2. Read relevant files
3. Bash to reproduce issue
4. Edit to fix
5. Bash to verify fix
```

## Tool Combinations

### Effective Workflows
- **Refactoring**: Grep → Read → MultiEdit → Bash (tests)
- **Bug Fix**: Grep → Read → Edit → Bash (verify)
- **New Feature**: TodoWrite → Read → Write/Edit → Bash
- **Research**: WebSearch → WebFetch → Task → Read
- **Build Issues**: Bash → BashOutput → Read → Edit

### Parallel Execution
Execute multiple independent operations simultaneously:
- Multiple file reads
- Multiple grep searches
- Multiple bash commands
- Multiple agent tasks

## Limitations and Constraints

### File Operations
- Cannot read directories directly
- Line length limit of 2000 characters
- File size considerations for Read
- Exact string matching for Edit

### Command Execution
- No interactive commands (no -i flags)
- Sandbox restrictions by default
- Timeout limits (max 10 minutes)
- Output truncation at 30000 characters

### Web Operations
- US-based searches only
- Cache duration of 15 minutes
- Redirect handling required
- HTTPS preferred

### Task Management
- One in_progress task at a time
- Stateless agent invocations
- No agent communication after launch

## Troubleshooting Guide

### Common Issues
1. **Edit fails**: String not unique or doesn't match exactly
2. **Sandbox violations**: Use /tmp/claude/ or adjust permissions
3. **Command timeout**: Break into smaller operations
4. **File not found**: Verify path with ls first
5. **Agent confusion**: Provide more detailed instructions

### Solutions
- Always verify paths before operations
- Read files before editing
- Use unique strings for edits
- Enable multiline for complex patterns
- Batch operations for efficiency

## Summary
Claude Code's tools provide a comprehensive suite for software development, from basic file operations to complex multi-step tasks. Effective use involves:
- Choosing the right tool for each task
- Combining tools efficiently
- Following security best practices
- Optimizing for performance
- Maintaining clear task tracking

The key to success is understanding each tool's strengths and using them in combination to accomplish complex software engineering tasks efficiently and safely.