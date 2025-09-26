# MCP Application Implementation Guide

## Core MCP Concepts

**Model Context Protocol (MCP)** is an open protocol that enables AI agents to dynamically discover and invoke tools in a standardized way.

### Architecture Components
- **MCP Server**: The bridge you build to expose tools, resources, and prompts
- **MCP Client**: Built into AI applications to consume MCP servers
- **Transport**: Communication layer (stdio for local, HTTP for remote)

## Server Setup Pattern

### Basic Server Initialization
```typescript
#!/usr/bin/env node

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const server = new McpServer({
  name: "my-mcp-server",
  version: "1.0.0"
});

// Global error handling
server.onerror = (error) => {
  console.error("Server error:", error);
  // Log but don't exit - let MCP handle reconnection
};

async function main() {
  try {
    // Register all tools and resources
    await registerTools(server);
    await registerResources(server);

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

## Tool Implementation Patterns

### Basic Tool Registration
```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";
import { z } from "zod";

// Define schema with Zod
const CalculatorSchema = z.object({
  operation: z.enum(["add", "subtract", "multiply", "divide"]),
  a: z.number().describe("First number"),
  b: z.number().describe("Second number")
});

type CalculatorInput = z.infer<typeof CalculatorSchema>;

export function registerCalculatorTool(server: McpServer) {
  server.registerTool(
    "calculator",
    {
      title: "Calculator",
      description: "Perform basic arithmetic operations",
      inputSchema: CalculatorSchema.shape
    },
    async (args: CalculatorInput) => {
      try {
        const { operation, a, b } = CalculatorSchema.parse(args);

        let result: number;

        switch (operation) {
          case "add":
            result = a + b;
            break;
          case "divide":
            if (b === 0) {
              throw new McpError(
                ErrorCode.InvalidParams,
                "Division by zero is not allowed"
              );
            }
            result = a / b;
            break;
          // ... other operations
        }

        return {
          content: [{
            type: "text",
            text: `${a} ${operation} ${b} = ${result}`
          }]
        };

      } catch (error) {
        if (error instanceof McpError) {
          throw error;
        }

        throw new McpError(
          ErrorCode.InternalError,
          `Calculator error: ${error instanceof Error ? error.message : 'Unknown error'}`
        );
      }
    }
  );
}
```

### Tool with External API
```typescript
async function fetchWeatherData(location: string): Promise<WeatherData> {
  try {
    const response = await fetch(
      `https://api.example.com/weather?q=${encodeURIComponent(location)}`
    );

    if (!response.ok) {
      if (response.status === 404) {
        throw new McpError(ErrorCode.InvalidParams, `Location not found: ${location}`);
      }
      throw new McpError(ErrorCode.InternalError, `API error: ${response.statusText}`);
    }

    return await response.json();
  } catch (error) {
    if (error instanceof McpError) {
      throw error;
    }
    throw new McpError(ErrorCode.InternalError, `Failed to fetch data: ${error}`);
  }
}

export function registerWeatherTool(server: McpServer) {
  server.registerTool(
    "get_weather",
    {
      title: "Get Weather",
      description: "Get current weather information",
      inputSchema: WeatherSchema.shape
    },
    async (args: WeatherInput) => {
      const { location, unit } = WeatherSchema.parse(args);
      const weatherData = await fetchWeatherData(location);

      return {
        content: [{
          type: "text",
          text: formatWeatherResponse(weatherData, unit)
        }]
      };
    }
  );
}
```

## Resource Implementation Pattern

```typescript
import { McpServer, ResourceTemplate } from "@modelcontextprotocol/sdk/server/mcp.js";
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";
import { readFile } from "fs/promises";
import { join } from "path";

export function registerLogResources(server: McpServer) {
  server.registerResource(
    "application_logs",
    new ResourceTemplate("logs://application/{type}", { list: undefined }),
    {
      title: "Application Logs",
      description: "Access to application log files",
      mimeType: "text/plain"
    },
    async (uri, { type }) => {
      const logDir = process.env.LOG_DIR || "./logs";
      const validTypes = ["error", "info", "debug"];

      if (!validTypes.includes(type)) {
        throw new McpError(
          ErrorCode.InvalidParams,
          `Invalid log type. Must be one of: ${validTypes.join(", ")}`
        );
      }

      try {
        const logPath = join(logDir, `${type}.log`);
        const content = await readFile(logPath, "utf-8");

        return {
          contents: [{
            uri: uri.href,
            text: content,
            mimeType: "text/plain"
          }]
        };
      } catch (error) {
        throw new McpError(
          ErrorCode.InternalError,
          `Failed to read log file: ${error instanceof Error ? error.message : 'Unknown error'}`
        );
      }
    }
  );
}
```

## Error Handling Patterns

### Error Utility Functions
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

export function createInputValidationError(fieldName: string, issue: string): McpError {
  return new McpError(
    ErrorCode.InvalidParams,
    `Invalid ${fieldName}: ${issue}`
  );
}

export function createResourceNotFoundError(uri: string): McpError {
  return new McpError(
    ErrorCode.InvalidParams,
    `Resource not found: ${uri}`
  );
}
```

## Schema Design Patterns

### Effective Zod Schemas for MCP
```typescript
import { z } from "zod";

// Good practices for MCP schemas
export const FileSearchSchema = z.object({
  // Use descriptive names with .describe() for AI understanding
  pattern: z.string().min(1).describe("Search pattern"),

  // Optional fields with defaults
  path: z.string().optional().describe("Directory path to search"),

  // Boolean flags with defaults
  includeHidden: z.boolean().default(false),

  // Enums for constrained values
  sortBy: z.enum(["name", "date", "size"]).default("name"),

  // Validation constraints
  maxResults: z.number().min(1).max(1000).default(100)
});

// Complex nested schema
export const DatabaseQuerySchema = z.object({
  query: z.string().min(1).describe("SQL query to execute"),

  parameters: z.array(z.union([
    z.string(),
    z.number(),
    z.boolean(),
    z.null()
  ])).optional().describe("Query parameters"),

  options: z.object({
    timeout: z.number().min(0).default(30000),
    maxRows: z.number().min(1).default(1000),
    format: z.enum(["json", "csv", "table"]).default("json")
  }).optional()
});
```

## Tool Registration Management

```typescript
// Centralized tool registration
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { registerCalculatorTool } from "./calculator.js";
import { registerWeatherTool } from "./weather.js";
import { registerDatabaseTool } from "./database.js";

export async function registerTools(server: McpServer) {
  // Register all tools before connecting transport
  registerCalculatorTool(server);
  registerWeatherTool(server);
  registerDatabaseTool(server);

  // Can also conditionally register based on config
  if (process.env.ENABLE_EXPERIMENTAL) {
    registerExperimentalTools(server);
  }
}
```

## Transport Options

### STDIO Transport (Local)
```typescript
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

const transport = new StdioServerTransport();
await server.connect(transport);
```

### HTTP Transport (Remote)
```typescript
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamable.js";
import express from "express";

const app = express();
const server = new McpServer({ name: "remote-server", version: "1.0.0" });

app.post("/mcp", async (req, res) => {
  const transport = new StreamableHTTPServerTransport();
  await server.connect(transport);
  await transport.handleRequest(req, res, req.body);
});

app.listen(3000);
```

## MCP-Specific Best Practices

### 1. Error Handling Strategy
- **Logic throws, handlers catch**: Core logic throws `McpError`, handlers format responses
- Use specific `ErrorCode` values:
  - `ErrorCode.InvalidParams` - Invalid input parameters
  - `ErrorCode.InternalError` - Server-side errors
  - `ErrorCode.MethodNotFound` - Unknown tool/resource
- Include helpful error messages for debugging
- Never let unhandled exceptions crash the server

### 2. Schema Best Practices
- Use `.describe()` on all fields for AI understanding
- Set sensible defaults with `.default()`
- Use enums for constrained values
- Add validation constraints (`.min()`, `.max()`, `.regex()`)
- Keep schemas focused and single-purpose

### 3. Tool Design Principles
- One tool = one clear purpose
- Use descriptive tool names (snake_case)
- Return structured text responses
- Handle all error cases explicitly
- Validate inputs even with schema validation

### 4. Logging Considerations
```typescript
// Use console.error for server logs (stdio uses stdout for protocol)
console.error("Tool executed:", toolName, args);

// Never use console.log in stdio transport mode
// stdout is reserved for MCP protocol communication
```

### 5. Response Format
```typescript
// Always return in MCP response format
return {
  content: [{
    type: "text",
    text: "Your response here"
  }]
};

// For multiple content items
return {
  content: [
    { type: "text", text: "First part" },
    { type: "text", text: "Second part" }
  ]
};
```

## Environment Configuration Pattern

```typescript
import { z } from "zod";

const EnvSchema = z.object({
  API_KEY: z.string().min(1),
  LOG_DIR: z.string().default("./logs"),
  NODE_ENV: z.enum(["development", "production"]).default("development"),
  MAX_TIMEOUT: z.string().transform(Number).default("30000")
});

export const config = EnvSchema.parse(process.env);

// Use in tools
async function apiCall() {
  const response = await fetch(url, {
    headers: { "Authorization": `Bearer ${config.API_KEY}` }
  });
}
```

## Common MCP Types

```typescript
import {
  McpServer,
  McpError,
  ErrorCode,
  ResourceTemplate
} from "@modelcontextprotocol/sdk/server/mcp.js";

import {
  StdioServerTransport
} from "@modelcontextprotocol/sdk/server/stdio.js";

// Tool response type
interface ToolResponse {
  content: Array<{
    type: "text";
    text: string;
  }>;
}

// Resource response type
interface ResourceResponse {
  contents: Array<{
    uri: string;
    text: string;
    mimeType: string;
  }>;
}
```

## Development Tips

### MCP Inspector Usage
The MCP Inspector allows interactive testing of your tools:
```bash
npx @modelcontextprotocol/inspector build/index.js
```

### Validation Testing
```typescript
// Test schemas independently
const result = MySchema.safeParse(input);
if (!result.success) {
  console.error("Validation failed:", result.error.format());
}
```

This guide focuses on the core patterns and best practices for implementing MCP servers, without project setup details. Use these patterns as a reference when building MCP tools and resources.