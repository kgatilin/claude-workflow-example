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

## Testing Strategy Guide

Comprehensive testing is crucial for MCP server reliability. This section covers testing frameworks, patterns, and best practices specific to MCP applications.

### Testing Framework Recommendations (2024)

#### Vitest for New Projects (Recommended)
For new TypeScript MCP projects, **Vitest is the recommended choice**:
- **Zero configuration** TypeScript support out of the box
- **Native ESM support** without complex setup
- **Better performance** than Jest for modern applications
- **Compatible with Jest APIs** for easy migration

#### Jest for Existing Large Codebases
Continue using Jest if you have established large codebases, unless migration benefits outweigh switching costs.

### MCP Testing Architecture

#### Test Structure Overview
```
tests/
├── unit/
│   ├── tools/           # Unit tests for individual tools
│   ├── schemas/         # Zod schema validation tests
│   ├── services/        # Service layer tests
│   └── utils/           # Utility function tests
├── integration/
│   ├── server.test.ts   # Server startup and shutdown tests
│   ├── transport.test.ts # Transport layer tests
│   └── e2e-tools.test.ts # End-to-end tool execution tests
└── fixtures/
    ├── valid-inputs/    # Valid test data
    ├── invalid-inputs/  # Invalid test data for error cases
    └── mocks/           # Mock responses and data
```

### Unit Testing Patterns

#### 1. Testing MCP Tool Logic
```typescript
import { describe, it, expect, vi } from 'vitest';
import { z } from 'zod';
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";
import { registerCalculatorTool } from '../src/tools/calculator.js';

describe('Calculator Tool', () => {
  let mockServer: any;
  let toolHandler: Function;

  beforeEach(() => {
    mockServer = {
      registerTool: vi.fn((name, definition, handler) => {
        toolHandler = handler;
      })
    };
    registerCalculatorTool(mockServer);
  });

  it('should perform addition correctly', async () => {
    const input = { operation: 'add', a: 5, b: 3 };
    const result = await toolHandler(input);

    expect(result).toEqual({
      content: [{
        type: 'text',
        text: '5 add 3 = 8'
      }]
    });
  });

  it('should throw McpError for division by zero', async () => {
    const input = { operation: 'divide', a: 10, b: 0 };

    await expect(toolHandler(input)).rejects.toThrow(McpError);
    await expect(toolHandler(input)).rejects.toThrow('Division by zero is not allowed');
  });

  it('should handle invalid operation gracefully', async () => {
    const input = { operation: 'invalid', a: 5, b: 3 };

    await expect(toolHandler(input)).rejects.toThrow(McpError);
  });
});
```

#### 2. Zod Schema Validation Testing
```typescript
import { describe, it, expect } from 'vitest';
import { z } from 'zod';

const UserSchema = z.object({
  name: z.string().min(2).describe("User full name"),
  age: z.number().positive().describe("User age in years"),
  email: z.string().email().describe("User email address")
});

describe('User Schema Validation', () => {
  describe('Valid inputs', () => {
    it('should parse valid user data', () => {
      const validData = { name: 'John Doe', age: 30, email: 'john@example.com' };
      const result = UserSchema.safeParse(validData);

      expect(result.success).toBe(true);
      if (result.success) {
        expect(result.data).toEqual(validData);
      }
    });
  });

  describe('Invalid inputs', () => {
    it('should fail for invalid email format', () => {
      const invalidData = { name: 'John', age: 30, email: 'invalid-email' };
      const result = UserSchema.safeParse(invalidData);

      expect(result.success).toBe(false);
      if (!result.success) {
        expect(result.error.errors[0].path).toEqual(['email']);
        expect(result.error.errors[0].code).toBe('invalid_string');
      }
    });

    it('should fail for negative age', () => {
      const invalidData = { name: 'John', age: -5, email: 'john@example.com' };

      expect(() => UserSchema.parse(invalidData)).toThrow(z.ZodError);
    });

    it('should provide detailed error messages', () => {
      const invalidData = { name: 'J', age: 30, email: 'john@example.com' };
      const result = UserSchema.safeParse(invalidData);

      expect(result.success).toBe(false);
      if (!result.success) {
        expect(result.error.errors[0].message).toContain('at least 2 characters');
      }
    });
  });
});
```

#### 3. External API Mocking
```typescript
import { describe, it, expect, vi, beforeEach } from 'vitest';
import { registerWeatherTool } from '../src/tools/weather.js';

// Mock fetch globally
global.fetch = vi.fn();

describe('Weather Tool with API', () => {
  let mockServer: any;
  let toolHandler: Function;

  beforeEach(() => {
    mockServer = {
      registerTool: vi.fn((name, definition, handler) => {
        toolHandler = handler;
      })
    };
    registerWeatherTool(mockServer);
    vi.clearAllMocks();
  });

  it('should fetch weather data successfully', async () => {
    const mockResponse = {
      ok: true,
      json: () => Promise.resolve({
        temperature: 22,
        condition: 'sunny',
        location: 'New York'
      })
    };

    (fetch as jest.Mock).mockResolvedValue(mockResponse);

    const result = await toolHandler({ location: 'New York', unit: 'celsius' });

    expect(fetch).toHaveBeenCalledWith(
      expect.stringContaining('New York')
    );
    expect(result.content[0].text).toContain('22');
  });

  it('should handle API errors gracefully', async () => {
    const mockResponse = {
      ok: false,
      status: 404,
      statusText: 'Not Found'
    };

    (fetch as jest.Mock).mockResolvedValue(mockResponse);

    await expect(toolHandler({ location: 'InvalidCity' }))
      .rejects.toThrow('Location not found');
  });
});
```

### Integration Testing Patterns

#### 1. Server Lifecycle Testing
```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";

describe('MCP Server Integration', () => {
  let server: McpServer;

  beforeEach(() => {
    server = new McpServer({
      name: "test-server",
      version: "1.0.0"
    });
  });

  afterEach(async () => {
    if (server) {
      await server.close();
    }
  });

  it('should start and register tools successfully', async () => {
    // Register a simple test tool
    server.registerTool(
      'test_tool',
      {
        title: 'Test Tool',
        description: 'A simple test tool',
        inputSchema: {}
      },
      async () => ({ content: [{ type: 'text', text: 'test' }] })
    );

    // Verify server can start
    expect(() => server).not.toThrow();
  });

  it('should handle tool registration errors', () => {
    expect(() => {
      server.registerTool(
        'invalid_tool',
        null as any, // Invalid definition
        async () => ({})
      );
    }).toThrow();
  });
});
```

#### 2. End-to-End Tool Testing
```typescript
import { describe, it, expect } from 'vitest';
import { execSync } from 'child_process';
import { join } from 'path';

describe('E2E MCP Server Tests', () => {
  const serverPath = join(__dirname, '../dist/index.js');

  it('should respond to MCP Inspector requests', () => {
    // This test requires the server to be built
    const command = `npx @modelcontextprotocol/inspector ${serverPath} --list-tools`;

    expect(() => {
      const result = execSync(command, { encoding: 'utf-8', timeout: 5000 });
      expect(result).toContain('test_tool');
    }).not.toThrow();
  }, 10000);
});
```

### Mocking Best Practices

#### 1. Keep Mocks Close to Tests
```typescript
// ✅ Good: Mock defined in test setup
describe('Weather API Tool', () => {
  beforeEach(() => {
    vi.mocked(fetch).mockImplementation(async (url) => {
      if (url.includes('weather')) {
        return mockWeatherResponse;
      }
      throw new Error('Unexpected API call');
    });
  });

  // Tests here...
});
```

#### 2. Type-Safe Mocking
```typescript
import { vi } from 'vitest';
import type { WeatherAPI } from '../src/services/weather.js';

// ✅ Type-safe mock
const mockWeatherAPI: WeatherAPI = {
  getCurrentWeather: vi.fn(),
  getForecast: vi.fn()
};

// Usage in tests
vi.mocked(mockWeatherAPI.getCurrentWeather).mockResolvedValue({
  temperature: 25,
  condition: 'sunny'
});
```

#### 3. Module-based Mocking for ESM
```typescript
// For ESM projects, use module-based mocking
vi.mock('../src/services/external-api.js', () => ({
  ExternalAPI: vi.fn().mockImplementation(() => ({
    fetchData: vi.fn().mockResolvedValue({ success: true })
  }))
}));
```

### Testing Best Practices Summary

#### 1. Test Structure
- **Unit tests**: Test individual tool logic and schema validation
- **Integration tests**: Test server lifecycle and tool registration
- **E2E tests**: Test complete MCP protocol interactions

#### 2. Coverage Priorities
- All tool handlers with valid and invalid inputs
- Schema validation for all possible input combinations
- Error handling paths and McpError throwing
- External API failure scenarios

#### 3. Common Pitfalls to Avoid
- **Don't test implementation details**: Focus on behavior, not internal structure
- **Avoid auto-magic mocks**: Keep mocks explicit and close to tests
- **Don't ignore error paths**: Test all error conditions thoroughly
- **Avoid flaky tests**: Use deterministic data and proper async handling

#### 4. Performance Testing
```typescript
describe('Tool Performance', () => {
  it('should handle large datasets efficiently', async () => {
    const startTime = Date.now();
    const largeInput = generateLargeTestData(10000);

    await toolHandler(largeInput);

    const duration = Date.now() - startTime;
    expect(duration).toBeLessThan(5000); // 5 second timeout
  });
});
```

#### 5. Using MCP Inspector for Development
```bash
# Interactive testing during development
npx @modelcontextprotocol/inspector dist/index.js

# Automated tool validation
npx @modelcontextprotocol/inspector dist/index.js --validate

# List all available tools
npx @modelcontextprotocol/inspector dist/index.js --list-tools
```

This comprehensive testing strategy ensures your MCP server is reliable, maintainable, and ready for production deployment.

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