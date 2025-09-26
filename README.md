# AI Coding Agent Workflow for MCP Server Development

This project showcases a structured coding agent workflow using Claude to implement a Model Context Protocol (MCP) server for Jira issue retrieval. It demonstrates how to leverage AI agents to streamline development through standardized commands and task management.

## What is an MCP Server?

The **Model Context Protocol (MCP)** is a system that allows AI agents to securely interact with tools and services, giving Claude "hands" to work with your local files, GitHub repositories, databases, and external APIs. An MCP server provides standardized access to specific functionality - in this case, retrieving Jira issue information.

MCP servers enable AI agents to:
- Access real-time data from external services
- Perform actions on behalf of users through standardized interfaces
- Integrate with existing tools and workflows securely
- Provide context-aware assistance based on live data

## How to Install Claude

### Installation

**Claude Code CLI** is the command-line interface that enables AI-powered development workflows.

**Prerequisites:**
- Node.js 18.0.0 or higher
- 4GB RAM minimum
- Active internet connection

**Installation:**
```bash
npm install -g @anthropic-ai/claude-code
```

**Platform Support:**
- **macOS:** Works natively on macOS 10.15+
- **Linux:** Ubuntu 20.04+/Debian 10+ supported
- **Windows:** Requires WSL2 (Windows Subsystem for Linux)

**Windows WSL Setup:**
```powershell
# Enable WSL
wsl --install

# Or use PowerShell installer
irm https://claude.ai/install.ps1 | iex
```

**Official Documentation:** [Claude Code Setup Guide](https://docs.claude.com/en/docs/claude-code/setup)

### Authentication Options

After installing Claude Code CLI, you need to choose how to authenticate and access Claude models:

#### Option 1: Subscription (Recommended for Regular Use)
- Fixed monthly cost with higher usage limits
- Most economical for frequent Claude Code usage (Pro or Max plans)
- Automatic authentication through Anthropic account
- **Setup:** Sign up at [claude.ai](https://claude.ai) and run `claude` to authenticate

#### Option 2: Direct API Access (Pay-per-Use)
- Pay only for what you use
- Good for occasional usage or testing
- **Setup:**
  1. Visit [Anthropic Console](https://www.anthropic.com/api)
  2. Sign up/login to your account
  3. Navigate to Settings → API Keys
  4. Click "Create Key" and claim free credits ($5 for 14 days)
  5. Configure your environment:
     ```bash
     export ANTHROPIC_API_KEY="your-api-key"
     ```
- **Pricing:**
  - Input: $3-15 per million tokens (depending on model)
  - Output: $15-75 per million tokens

#### Option 3: Enterprise Cloud Backends

**Amazon Bedrock:**
- Enterprise deployment with AWS infrastructure
- Claude Opus 4 and Sonnet 4 available
- Regions: US East/West, APAC, Europe
- **Setup:**
  ```bash
  export CLAUDE_CODE_USE_BEDROCK=1
  export AWS_REGION=us-east-1
  ```
- **Documentation:** [Claude on Amazon Bedrock](https://docs.claude.com/en/docs/claude-code/amazon-bedrock)

**Google Cloud Vertex AI:**
- Enterprise deployment with GCP infrastructure
- Available through Vertex AI Model Garden
- **Setup:**
  ```bash
  gcloud config set project YOUR-PROJECT-ID
  gcloud services enable aiplatform.googleapis.com
  export CLAUDE_CODE_USE_VERTEX=1
  ```
- **Setup Guide:** [Claude on Google Vertex AI](https://docs.claude.com/en/docs/claude-code/google-vertex-ai)
- **Official GCP Documentation:** [Anthropic Claude models on Vertex AI](https://cloud.google.com/vertex-ai/generative-ai/docs/partner-models/claude)
- **Required IAM role:** `roles/aiplatform.user`

### Getting Started

**First-time Setup:**
On first run, Claude Code will prompt for authentication:
```bash
claude
# Follow browser authentication flow for subscription/API
# Or ensure environment variables are set for cloud backends
```

**Using Claude Code:**
Navigate to your project directory and launch Claude:
```bash
cd your-project-directory
claude
```

Claude Code provides an interactive terminal interface where you can:
- Ask questions about your codebase in natural language
- Request features to be built from descriptions
- Debug and fix issues by describing problems
- Navigate and understand complex codebases

**Official Getting Started Guide:** [Claude Code Overview](https://docs.claude.com/en/docs/claude-code/overview)

## How to Use the Workflow

This project implements a structured workflow with five main commands that guide you through implementing an MCP server from requirements to completion.

### Command Sequence

**This is a collaborative human-AI workflow, not automation.** Each command must be manually invoked by you after reviewing the previous stage's output. The AI assistant accelerates development by 10x while you maintain complete control over when and how to proceed.

**First, launch Claude Code in your project directory:**
```bash
cd your-project-directory
claude
```

**Then execute the workflow with human oversight at each stage:**

```bash
# 1. Initialize task from backlog
/workflow:init_task @.agent/backlog/jira-get-issue-mcp.md
```
📋 **Review & Decide:** Examine the generated business requirements in `00_task.md`. Validate acceptance criteria, modify requirements if needed. When satisfied, run the next command.

```bash
# 2. Create implementation plan
/workflow:plan
```
🏗️ **Review & Decide:** Examine the technical plan in `01_implementation_plan.md`. Verify architecture decisions, assess complexity, adjust approach if needed. When the strategy looks good, proceed to implementation.

```bash
# 3. Implement the feature with TDD
/workflow:implement
```
⚡ **Review & Decide:** Test the implementation, run the code, verify functionality matches requirements. The AI builds fast, but you ensure it builds right. When ready, run the review.

```bash
# 4. Review implementation against requirements
/workflow:review [additional-focus-areas]
```
🔍 **Review & Decide:** Evaluate the comprehensive review findings in `03_review.md`. If fixes are needed, run the fix command. If satisfied, you're done.

```bash
# 5. Fix any issues found in review (if needed)
/workflow:review_fix
```
✅ **Review & Decide:** Validate that fixes address the identified issues without introducing new problems. Repeat review cycle as needed.

**Key Principles:**
- **Human judgment drives decisions** - AI provides options, you choose the path
- **Review every output** - Fast generation requires careful validation
- **Iterative improvement** - Use feedback to refine results at each stage
- **Quality gate enforcement** - Don't proceed until each stage meets your standards

### Command Descriptions

#### 1. `/workflow:init_task` - Task Initialization
**Purpose:** Transform brief backlog items into comprehensive business requirements

**What it does:**
- Creates a feature branch for the task
- Sets up standardized task folder structure (`/.agent/tasks/[task-name]/`)
- Expands brief requirements into detailed user stories
- Researches external dependencies and current versions
- Creates comprehensive acceptance criteria
- Focuses exclusively on **business requirements** (what to build, not how)

**Output:** `00_task.md` with complete business requirements

**Supporting Scripts:**
- `.claude/scripts/init_task_setup.sh` - Creates feature branches, task directories, and stage tracking

#### 2. `/workflow:plan` - Implementation Planning
**Purpose:** Create detailed technical implementation plan with systems architecture approach

**What it does:**
- Analyzes task complexity (simple vs. complex)
- Designs system architecture with component relationships
- Creates mermaid diagrams for data/control flow
- Maps acceptance criteria to specific tests
- Defines implementation tasks in executable order
- Determines iteration strategy (single vs. multiple iterations)

**Output:** `01_implementation_plan.md` with detailed technical plan

#### 3. `/workflow:implement` - TDD Implementation
**Purpose:** Implement features using Test-Driven Development with minimal essential tests

**What it does:**
- Follows pragmatic TDD: test behavior, not implementation
- Writes one focused test per acceptance criteria
- Implements simplest code to pass tests
- Tracks progress with TodoWrite tool
- Creates working software incrementally
- Avoids over-engineering (YAGNI principle)

**Output:** Complete implementation with test coverage and `02_implementation_log.md`

**Supporting Scripts:**
- `.claude/scripts/get_current_task_context.sh` - Extracts current task info from git branch and folder structure

#### 4. `/workflow:review [additional-review-focus]` - Quality Review
**Purpose:** Review implementation against task requirements and planned architecture

**Arguments:**
- `additional-review-focus` (optional): Specific areas to focus on during review (e.g., "security", "performance", "error handling")

**What it does:**
- Launches 5 parallel specialized review agents:
  - Code Quality: maintainability, readability, idiomaticity
  - Test Quality: coverage, clarity, behavior focus
  - Architecture Alignment: compliance with planned design
  - Acceptance Criteria: requirement fulfillment verification
  - Security & Performance: vulnerability and bottleneck analysis
- Synthesizes findings into binary classification (Must Fix vs. Future Improvement)
- Verifies all acceptance criteria are met with corresponding tests
- Makes APPROVED/REQUIRES FIXES decision

**Output:** `03_review.md` with comprehensive assessment and decision

**Supporting Scripts:**
- `.claude/scripts/find_review_comments.sh` - Identifies unresolved review comments across the codebase
- `.claude/scripts/get_current_task_context.sh` - Provides task context for review scope

#### 5. `/workflow:review_fix` - Issue Resolution
**Purpose:** Address blocking issues identified in review before proceeding

**What it does:**
- Focuses only on "Must Fix" issues that block requirements
- Implements targeted fixes without scope creep
- Re-runs verification tests
- Updates implementation log with fixes applied

**Output:** Updated code and `04_fixes_applied.md`

#### Supporting Utility Commands

In addition to the main workflow commands, several utility commands are available:

**`/utility:new_command`** - Create new custom slash commands
- Takes command name and purpose as arguments
- Follows Claude 4 prompt engineering best practices
- Automatically determines required tools and structure

**`/utility:improve_command`** - Enhance existing slash commands
- Accepts feedback to improve command functionality
- Maintains consistency with established patterns

**`/utility:update_project_rules`** - Update CLAUDE.md project guidelines
- Adds new rules or guidance while maintaining structure
- Ensures project-specific instructions are preserved

## Slash Command Syntax

Slash commands use a frontmatter-based syntax with specific structure:

### Frontmatter Format
```yaml
---
allowed-tools: Read, Write, Bash, WebSearch
argument-hint: <command-name> <purpose>
description: Brief description of command purpose
model: claude-sonnet-4-0  # Specify model explicitly
---
```

### Bash Command Integration
Commands can execute bash scripts using the `!` prefix:
```markdown
## Setup Context
!`.claude/scripts/init_task_setup.sh $ARGUMENTS`
```

### File References
Reference documentation using the `@` prefix:
```markdown
Read @docs/mcp_app_guide.md for implementation patterns
Based on @.claude/snippets/agents-workflow.md
```

### Argument Handling
Commands access arguments through variables:
```markdown
- `$ARGUMENTS` - All arguments as single string
- `$1`, `$2`, etc. - Individual positional arguments
```

### Command Organization
```
.claude/commands/
├── workflow/          # Task workflow commands
│   ├── init_task.md
│   ├── plan.md
│   ├── implement.md
│   ├── review.md
│   └── review_fix.md
└── utility/           # General utility commands
    ├── new_command.md
    ├── improve_command.md
    └── update_project_rules.md
```

## Testing the MCP Server

### Prerequisites

1. **Environment Configuration**
   Create a `.env` file in your project root:
   ```env
   JIRA_BASE_URL=https://your-domain.atlassian.net
   JIRA_EMAIL=your-email@company.com
   JIRA_API_TOKEN=your-api-token
   ```

2. **Jira API Token Setup**
   - Go to [Atlassian Account Settings](https://id.atlassian.com/manage-profile/security/api-tokens)
   - Click "Create API token"
   - Copy the token to your `.env` file

### Testing Methods

#### Method 1: MCP Inspector (Recommended)

The MCP Inspector provides a visual testing interface for MCP servers:

1. **Build your MCP server:**
   ```bash
   npm run build
   ```

2. **Start MCP Inspector:**
   ```bash
   npx @modelcontextprotocol/inspector node dist/index.js .env
   ```

3. **Test in browser:**
   - Inspector runs on `http://localhost:6274` (client) and `http://localhost:6277` (proxy)
   - Click "▶︎Connect" to connect to your MCP server
   - Use the **Tools** tab to test `get_jira_issue` with valid issue keys (e.g., "PROJ-123")
   - Verify responses contain summary, description, status, and assignee fields
   - Test error handling with invalid issue keys

**Features:**
- Interactive testing of Resources, Prompts, and Tools
- Real-time connection status
- Visual schema validation
- Session tokens for security

#### Method 2: Claude Code MCP Configuration

Configure Claude Code to use your MCP server locally:

1. **Build your MCP server:**
   ```bash
   npm run build
   ```

2. **Add MCP server to Claude Code:**
   ```bash
   # Using CLI command (recommended)
   claude mcp add jira-server --scope local -- node dist/index.js .env

   # Or create .claude.json manually:
   {
     "mcpServers": {
       "jira": {
         "command": "node",
         "args": ["dist/index.js", ".env"]
       }
     }
   }
   ```

3. **Restart Claude Code and test:**
   ```bash
   claude
   # In conversation: "Get me details for Jira issue PROJ-123"
   ```

**Configuration file locations:**
- Primary: `.claude.json` in project directory (local scope)
- Alternative: `~/.claude.json` (global scope)

#### Method 3: VS Code MCP Configuration

Configure VS Code with GitHub Copilot Chat extension:

1. **Install GitHub Copilot Chat extension** from VS Code marketplace

2. **Add MCP server configuration:**
   ```bash
   # Use Command Palette: "MCP: Add Server"
   # Or create .vscode/mcp.json manually:
   {
     "mcpServers": {
       "jira": {
         "command": "node",
         "args": ["dist/index.js", ".env"]
       }
     }
   }
   ```

3. **Enable MCP in settings:**
   - Open VS Code settings
   - Enable `Chat > Mcp > Discovery`
   - Enable `Chat > Mcp`

4. **Test in VS Code:**
   - Open Copilot Chat panel
   - Ask: "@jira get details for issue PROJ-123"

**Configuration locations:**
- Workspace: `.vscode/mcp.json` (project-specific)
- Global: Use "MCP: Open User Configuration" command

### Required Environment Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `JIRA_BASE_URL` | Your Jira instance URL | `https://company.atlassian.net` |
| `JIRA_EMAIL` | Email associated with Jira account | `developer@company.com` |
| `JIRA_API_TOKEN` | Jira API token for authentication | `ATATT3xFfGF0...` |

### Verification Steps

1. **Server starts successfully:**
   ```bash
   node dist/index.js .env
   # Should output: "MCP server running on stdio"
   ```

   **Note:** The .env file path is required as the first argument.

2. **Tool responds to valid input:**
   - Issue key format: `PROJ-123` (project key + hyphen + number)
   - Returns JSON with summary, description, status, assignee fields

3. **Error handling works:**
   - Invalid issue keys return appropriate error messages
   - Authentication failures provide clear feedback
   - Network issues are handled gracefully

4. **Response time acceptable:**
   - Requests complete within 5 seconds
   - No timeout errors under normal conditions

## Project Structure

```
├── .agent/                             # Agent workflow system
│   ├── backlog/                        # Task backlog items (submitted)
│   ├── tasks/                          # Task execution logs (not submitted)
│   │   └── jira-get-issue-mcp/         # Example task documentation
│   │       ├── 00_task.md              # Business requirements
│   │       ├── 01_implementation_plan.md # Technical plan
│   │       ├── 02_implementation_log.md # Implementation details
│   │       ├── 03_review.md            # Quality review results
│   │       └── stage.yaml              # Workflow stage tracking
│   └── templates/                      # Task templates (submitted)
├── .claude/                            # Claude Code configuration
│   ├── commands/                       # Slash command definitions
│   │   ├── workflow/                   # Main workflow commands
│   │   └── utility/                    # Helper commands
│   ├── scripts/                        # Supporting bash scripts
│   ├── snippets/                       # Reusable code snippets
│   └── prompts/                        # Prompt templates
├── docs/                               # Documentation
├── CLAUDE.md                           # Claude Code instructions
├── package.json                        # Node.js dependencies
├── tsconfig.json                       # TypeScript configuration
├── .env                                # Environment variables (local)
└── README.md                           # This file
```

**Note:** This project showcases the workflow structure and commands. What gets submitted to the repository:
- `.agent/backlog/` - Task definitions
- `.claude/commands/` - Workflow commands
- `.claude/scripts/` - Supporting scripts
- Documentation and configuration

What is generated during workflow execution (not submitted):
- `.agent/tasks/` - Task execution logs
- `src/` and `tests/` - Actual implementation code

## Getting Started

1. **Clone this repository** to see the complete workflow example
2. **Install Claude** using one of the methods above
3. **Run the workflow** on your own backlog item:
   ```bash
   # Create your backlog file
   echo "Build an MCP server for [your use case]" > .agent/backlog/my-task.md

   # Start the workflow
   /workflow:init_task @.agent/backlog/my-task.md
   ```
4. **Follow the command sequence** to implement your own MCP server
5. **Test with MCP Inspector** to verify functionality

This workflow demonstrates how AI coding agents can streamline development through structured processes, comprehensive planning, and quality assurance - all while maintaining focus on user requirements and business value.