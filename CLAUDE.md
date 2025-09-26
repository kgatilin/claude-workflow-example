# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a **fresh MCP (Model Context Protocol) Jira Server** project designed to provide AI agents with standardized access to Jira functionality. The project is set up with modern TypeScript tooling and follows MCP best practices from `@docs/mcp_app_guide.md`.

## Development Commands

### Build and Development
- `npm run build` - Compile TypeScript source from `src/` to `dist/`
- `npm run lint` - Run ESLint on TypeScript source files
- `npm run test` - Run Vitest in watch mode
- `npm run test:run` - Run all tests once and exit
- `npm run test:watch` - Run tests in watch mode (same as `npm run test`)

### Local Installation
- `npm run link` - Create global symlink to test the MCP server locally

## Expected Project Structure

This fresh project should follow the MCP patterns outlined in `@docs/mcp_app_guide.md`:

```
src/
├── index.ts                 # Main MCP server entry point
├── config.ts               # Environment configuration with Zod validation
├── tools/
│   ├── index.ts            # Centralized tool registration
│   └── jira.ts             # Jira tool registration functions
├── services/
│   └── jira-api.ts         # Jira API client
└── utils/
    └── errors.ts           # MCP error handling utilities

tests/
└── **/*.test.ts            # Vitest tests (10s timeout configured)
```

## MCP Implementation Patterns

Based on `@docs/mcp_app_guide.md`, implement these core patterns:

### 1. Server Entry Point (`src/index.ts`)
```typescript
#!/usr/bin/env node

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new McpServer({
  name: "mcp-server-jira",
  version: "1.0.0"
});

// Global error handling
server.onerror = (error) => {
  console.error("Server error:", error);
  // Log but don't exit - let MCP handle reconnection
};

async function main() {
  try {
    // Register all tools before connecting transport
    await registerTools(server);

    // Setup transport
    const transport = new StdioServerTransport();

    // Connect server
    await server.connect(transport);

    console.error("MCP server running on stdio");
  } catch (error) {
    console.error("Failed to start server:", error);
    process.exit(1);
  }
}

// Graceful shutdown
process.on('SIGINT', async () => {
  console.error("Shutting down server...");
  await server.close();
  process.exit(0);
});

main().catch(console.error);
```

### 2. Tool Registration Pattern (`src/tools/jira.ts`)
```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";
import { z } from "zod";

// Define schema with Zod
const JiraIssueSchema = z.object({
  issueKey: z.string().describe("Jira issue key (e.g., PROJ-123)")
});

type JiraIssueInput = z.infer<typeof JiraIssueSchema>;

export function registerJiraTools(server: McpServer) {
  server.registerTool(
    "get_jira_issue",
    {
      title: "Get Jira Issue",
      description: "Retrieve details of a Jira issue by its key",
      inputSchema: JiraIssueSchema.shape
    },
    async (args: JiraIssueInput) => {
      try {
        const { issueKey } = JiraIssueSchema.parse(args);

        // API call logic here
        const issue = await jiraClient.getIssue(issueKey);

        return {
          content: [{
            type: "text",
            text: JSON.stringify(issue, null, 2)
          }]
        };
      } catch (error) {
        if (error instanceof McpError) {
          throw error;
        }

        throw new McpError(
          ErrorCode.InternalError,
          `Failed to get Jira issue: ${error instanceof Error ? error.message : 'Unknown error'}`
        );
      }
    }
  );
}
```

### 3. Centralized Tool Registration (`src/tools/index.ts`)
```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { registerJiraTools } from "./jira.js";

export async function registerTools(server: McpServer) {
  // Register all tools before connecting transport
  registerJiraTools(server);

  // Can conditionally register based on config
  if (process.env.ENABLE_EXPERIMENTAL) {
    // Register experimental tools
  }
}
```

### 4. Configuration (`src/config.ts`)
```typescript
import { z } from 'zod';
import * as dotenv from 'dotenv';
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";

const JiraConfigSchema = z.object({
  baseUrl: z.string().url('JIRA_BASE_URL must be a valid URL'),
  email: z.string().email('JIRA_EMAIL must be a valid email'),
  apiToken: z.string().min(1, 'JIRA_API_TOKEN is required')
});

export function loadConfig(envPath?: string) {
  if (envPath) {
    dotenv.config({ path: envPath });
  }

  const envVars = {
    baseUrl: process.env.JIRA_BASE_URL,
    email: process.env.JIRA_EMAIL,
    apiToken: process.env.JIRA_API_TOKEN
  };

  const result = JiraConfigSchema.safeParse(envVars);
  if (!result.success) {
    const firstError = result.error.errors[0];
    throw new McpError(
      ErrorCode.InvalidParams,
      firstError?.message || 'Configuration validation failed'
    );
  }

  return result.data;
}
```

### 5. Error Handling (`src/utils/errors.ts`)
```typescript
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";
import { ZodError } from "zod";

export function handleToolError(error: unknown, toolName: string): never {
  if (error instanceof McpError) {
    throw error;
  }

  if (error instanceof ZodError) {
    const validationErrors = error.errors
      .map(e => `${e.path.join('.')}: ${e.message}`)
      .join(', ');
    throw new McpError(
      ErrorCode.InvalidParams,
      `Validation error in ${toolName}: ${validationErrors}`
    );
  }

  if (error instanceof Error) {
    throw new McpError(
      ErrorCode.InternalError,
      `${toolName} error: ${error.message}`
    );
  }

  throw new McpError(
    ErrorCode.InternalError,
    `Unknown error in ${toolName}: ${String(error)}`
  );
}
```

## Core Dependencies

From `package.json`:
- `@modelcontextprotocol/sdk` - MCP protocol implementation
- `zod` - Runtime validation and type generation
- `dotenv` - Environment variable loading

## Development Tooling

### TypeScript Configuration
- **Target**: ESNext with Node.js ESM modules
- **Output**: `dist/` directory with source maps and declarations
- **Strict mode**: Enabled with `noUncheckedIndexedAccess`
- **Module detection**: Forced for proper ESM handling

### Testing (Vitest)
- **Environment**: Node.js
- **Test location**: `tests/**/*.test.ts`
- **Timeout**: 10 seconds
- **Coverage**: Text and HTML reporters
- **Globals**: Enabled for describe/it/expect

### Linting (ESLint)
- TypeScript-ESLint recommended configuration
- Targets `**/*.{js,mjs,cjs,ts,mts,cts}` files

## MCP Development Guidelines

### Critical MCP Patterns
1. **Server Class**: Use `McpServer` from `@modelcontextprotocol/sdk/server/mcp.js` (NOT `Server`)
2. **Tool Registration**: Use `server.registerTool(name, definition, handler)` directly
3. **Input Schema**: Use `ZodSchema.shape` in tool definition (NOT the schema itself)
4. **Error Handling**: Throw `McpError` with proper `ErrorCode` values
5. **Transport**: `StdioServerTransport` - stdout for protocol, stderr for logging
6. **Tool Naming**: snake_case (e.g., `get_jira_issue`)
7. **Response Format**: Always return `{ content: [{ type: "text", text: string }] }`
8. **Schema Design**: Use Zod with `.describe()` for AI understanding
9. **Server Lifecycle**: Register tools → Connect transport → Handle shutdown with `server.close()`

Refer to `@docs/mcp_app_guide.md` for detailed implementation patterns and best practices.