# Claude Code Tools Quick Reference

## File Operations
| Tool | Purpose | Key Command |
|------|---------|-------------|
| **Read** | Read any file | `Read(file_path)` |
| **Write** | Create/overwrite file | `Write(file_path, content)` |
| **Edit** | Replace text in file | `Edit(file_path, old_string, new_string)` |
| **MultiEdit** | Multiple edits to one file | `MultiEdit(file_path, edits[])` |
| **NotebookEdit** | Edit Jupyter cells | `NotebookEdit(notebook_path, cell_id, new_source)` |

## Search Tools
| Tool | Purpose | Example Pattern |
|------|---------|-----------------|
| **Glob** | Find files by pattern | `**/*.js`, `src/**/*.ts` |
| **Grep** | Search file contents | `pattern, output_mode: "content"` |

## Command Execution
| Tool | Purpose | Key Options |
|------|---------|-------------|
| **Bash** | Run shell commands | `sandbox: true, timeout, run_in_background` |
| **BashOutput** | Get background output | `bash_id, filter` |
| **KillShell** | Terminate background shell | `shell_id` |
| **SlashCommand** | Execute slash commands | `command: "/command args"` |

## Task Management
| Tool | Purpose | Key Features |
|------|---------|--------------|
| **TodoWrite** | Track tasks | `pending → in_progress → completed` |
| **Task** | Launch agents | `general-purpose, statusline-setup, output-style-setup` |
| **ExitPlanMode** | End planning phase | `plan: "summary"` |

## Web Tools
| Tool | Purpose | Key Features |
|------|---------|--------------|
| **WebSearch** | Search the internet | `query, allowed_domains, blocked_domains` |
| **WebFetch** | Fetch & analyze URLs | `url, prompt` |

## Quick Patterns

### Read-Edit-Test Cycle
```bash
Read → Edit → Bash(test) → Verify
```

### Codebase Search
```bash
Glob("**/*.py") → Grep("pattern") → Read(specific_file)
```

### Multi-File Refactor
```bash
Grep → Read(all) → MultiEdit(each) → Bash(lint/test)
```

### Feature Implementation
```bash
TodoWrite → Read(examples) → Write/Edit → Bash(test) → TodoWrite(complete)
```

## Key Rules
1. **Always Read before Edit**
2. **Sandbox: true by default**
3. **One in_progress todo at a time**
4. **Prefer Edit over Write for existing files**
5. **Use /tmp/claude/ for temp files**
6. **Never use bash for grep/find/cat**
7. **Batch parallel operations**
8. **Quote paths with spaces**

## Common Tool Combinations
- **Refactoring**: Grep + Read + MultiEdit
- **Debugging**: Bash + Grep + Read + Edit
- **Research**: WebSearch + WebFetch + Task
- **Building**: Bash + BashOutput + TodoWrite

## Performance Tips
- Batch multiple reads/greps in parallel
- Use Task for complex multi-step searches
- MultiEdit > multiple Edits
- Glob > bash find
- Grep > bash grep

## Error Prevention
- ✅ Read file first
- ✅ Use absolute paths
- ✅ Unique edit strings
- ✅ Sandbox enabled
- ❌ Interactive commands (-i)
- ❌ Creating unrequested docs
- ❌ Committing without request