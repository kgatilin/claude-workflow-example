# Building MCP Servers with TypeScript and Zod: A Practical Guide

## What is MCP?

Model Context Protocol (MCP) is an open protocol created by Anthropic that enables AI agents to dynamically discover and invoke tools in a standardized way. Think of it as USB-C for AI tools - one interface that allows AI applications like Claude, Cursor, or custom clients to connect to various data sources and services.

**Core Architecture:**
- **MCP Server**: The bridge you build to expose tools, resources, and prompts
- **MCP Client**: Built into AI applications to consume MCP servers
- **Transport**: Communication layer (stdio for local, HTTP for remote)

## Project Setup

### 1. Initialize Project Structure

```

## Code Quality and Linting

### 1. ESLint Configuration Best Practices

The ESLint configuration includes MCP-specific rules:

**Key Rules for MCP Development:**
- `no-console`: Allows `console.error` and `console.warn` (needed for MCP logging via stderr)
- `@typescript-eslint/explicit-function-return-type`: Ensures clear return types for tool handlers
- `@typescript-eslint/no-explicit-any`: Warns against `any` usage (relaxed in tests)
- `prefer-const`: Enforces immutability where possible

**Pre-commit Integration with Husky:**
```bash
npm install -D husky lint-staged

# package.json
{
  "lint-staged": {
    "src/**/*.ts": [
      "eslint --fix",
      "prettier --write",
      "vitest related --run"
    ]
  },
  "husky": {
    "hooks": {
      "pre-commit": "lint-staged",
      "pre-push": "npm run test:ci"
    }
  }
}
```

### 2. Custom ESLint Rules for MCP

**MCP-specific linting rules:**
```javascript
// Custom rule for tool naming convention
'mcp/tool-naming': ['error', { pattern: '^[a-z][a-z0-9_]*bash
mkdir my-mcp-server
cd my-mcp-server
npm init -y
```

### 2. Essential Dependencies

```bash
# Core MCP and validation
npm install @modelcontextprotocol/sdk zod

# Development dependencies
npm install -D typescript @types/node

# Testing and linting
npm install -D vitest @vitest/ui eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin eslint-config-prettier prettier
```

### 3. Project Configuration

**package.json**
```json
{
  "name": "my-mcp-server",
  "version": "1.0.0",
  "type": "module",
  "bin": {
    "my-mcp-server": "./build/index.js"
  },
  "files": ["build"],
  "scripts": {
    "build": "tsc && chmod +x build/index.js",
    "watch": "tsc --watch",
    "inspector": "npx @modelcontextprotocol/inspector build/index.js",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage",
    "lint": "eslint src/**/*.ts",
    "lint:fix": "eslint src/**/*.ts --fix",
    "format": "prettier --write src/**/*.ts",
    "format:check": "prettier --check src/**/*.ts"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.6.0",
    "zod": "^3.22.0"
  },
  "devDependencies": {
    "@types/node": "^20.11.24",
    "typescript": "^5.3.3"
  }
}
```

**vitest.config.ts**
```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['tests/**/*.test.ts'],
    exclude: ['node_modules', 'build'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['tests/**', 'build/**', 'node_modules/**']
    }
  }
});
```

**eslint.config.js**
```javascript
import js from '@eslint/js';
import tseslint from '@typescript-eslint/eslint-plugin';
import tsparser from '@typescript-eslint/parser';
import prettier from 'eslint-config-prettier';

export default [
  js.configs.recommended,
  {
    files: ['src/**/*.ts'],
    languageOptions: {
      parser: tsparser,
      parserOptions: {
        ecmaVersion: 2022,
        sourceType: 'module',
        project: './tsconfig.json'
      }
    },
    plugins: {
      '@typescript-eslint': tseslint
    },
    rules: {
      ...tseslint.configs.recommended.rules,
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/explicit-function-return-type': 'warn',
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/prefer-const': 'error',
      'prefer-const': 'off', // Use TypeScript version
      'no-var': 'error',
      'no-console': ['warn', { allow: ['error', 'warn'] }], // Allow console.error for MCP logging
      'eqeqeq': 'error',
      'curly': 'error'
    }
  },
  {
    files: ['tests/**/*.ts'],
    rules: {
      '@typescript-eslint/no-explicit-any': 'off', // Allow any in tests
      'no-console': 'off' // Allow console in tests
    }
  },
  prettier
];
```

**prettier.config.js**
```javascript
export default {
  semi: true,
  trailingComma: 'es5',
  singleQuote: true,
  printWidth: 100,
  tabWidth: 2,
  useTabs: false
};
```

**tsconfig.json**
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "outDir": "./build",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "build"]
}
```

### 4. Recommended Project Structure

```
src/
├── index.ts              # Server entry point
├── tools/                # Tool definitions
│   ├── calculator.ts
│   └── weather.ts
├── resources/            # Resource handlers
│   └── logs.ts
├── schemas/              # Zod validation schemas
│   └── tool-schemas.ts
├── utils/                # Shared utilities
│   ├── errors.ts
│   └── validation.ts
└── types/                # TypeScript type definitions
    └── index.ts

tests/
├── setup.ts              # Test setup and utilities
├── tools/                # Tool-specific tests
│   ├── calculator.test.ts
│   └── weather.test.ts
├── resources/            # Resource tests
│   └── logs.test.ts
├── integration/          # End-to-end tests
│   └── server.test.ts
└── fixtures/             # Test data and mocks
    ├── weather-api.json
    └── log-samples.txt
```

## Core Implementation Patterns

### 1. Server Setup with Error Handling

**src/index.ts**
```typescript
#!/usr/bin/env node

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";
import { registerTools } from "./tools/index.js";
import { registerResources } from "./resources/index.js";

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

### 2. Tool Definition with Zod Validation

**src/schemas/tool-schemas.ts**
```typescript
import { z } from "zod";

export const CalculatorSchema = z.object({
  operation: z.enum(["add", "subtract", "multiply", "divide"]),
  a: z.number().describe("First number"),
  b: z.number().describe("Second number")
});

export const WeatherSchema = z.object({
  location: z.string().min(1).describe("City name or coordinates"),
  unit: z.enum(["celsius", "fahrenheit"]).default("celsius"),
  includeHourly: z.boolean().default(false).describe("Include hourly forecast")
});

export const FileSearchSchema = z.object({
  pattern: z.string().min(1).describe("Search pattern"),
  path: z.string().optional().describe("Directory path to search"),
  includeHidden: z.boolean().default(false)
});
```

**src/tools/calculator.ts**
```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";
import { z } from "zod";
import { CalculatorSchema } from "../schemas/tool-schemas.js";

type CalculatorInput = z.infer<typeof CalculatorSchema>;

export function registerCalculatorTool(server: McpServer) {
  server.registerTool(
    "calculator",
    {
      title: "Calculator",
      description: "Perform basic arithmetic operations with proper error handling",
      inputSchema: CalculatorSchema.shape
    },
    async (args: CalculatorInput) => {
      try {
        // Validate input (redundant but good practice)
        const { operation, a, b } = CalculatorSchema.parse(args);
        
        let result: number;
        
        switch (operation) {
          case "add":
            result = a + b;
            break;
          case "subtract":
            result = a - b;
            break;
          case "multiply":
            result = a * b;
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
          default:
            throw new McpError(
              ErrorCode.InvalidParams,
              `Unsupported operation: ${operation}`
            );
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

### 3. Advanced Tool with External API

**src/tools/weather.ts**
```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";
import { z } from "zod";
import { WeatherSchema } from "../schemas/tool-schemas.js";

type WeatherInput = z.infer<typeof WeatherSchema>;

interface WeatherData {
  temperature: number;
  description: string;
  humidity: number;
  windSpeed: number;
}

async function fetchWeatherData(location: string): Promise<WeatherData> {
  try {
    // Example using a weather API (replace with actual API)
    const response = await fetch(
      `https://api.openweathermap.org/data/2.5/weather?q=${encodeURIComponent(location)}&appid=${process.env.WEATHER_API_KEY}&units=metric`
    );
    
    if (!response.ok) {
      if (response.status === 404) {
        throw new McpError(ErrorCode.InvalidParams, `Location not found: ${location}`);
      }
      throw new McpError(ErrorCode.InternalError, `Weather API error: ${response.statusText}`);
    }
    
    const data = await response.json();
    
    return {
      temperature: data.main.temp,
      description: data.weather[0].description,
      humidity: data.main.humidity,
      windSpeed: data.wind.speed
    };
  } catch (error) {
    if (error instanceof McpError) {
      throw error;
    }
    throw new McpError(ErrorCode.InternalError, `Failed to fetch weather data: ${error}`);
  }
}

export function registerWeatherTool(server: McpServer) {
  server.registerTool(
    "get_weather",
    {
      title: "Get Weather",
      description: "Get current weather information for a specified location",
      inputSchema: WeatherSchema.shape
    },
    async (args: WeatherInput) => {
      const { location, unit, includeHourly } = WeatherSchema.parse(args);
      
      const weatherData = await fetchWeatherData(location);
      
      // Convert temperature if needed
      const temperature = unit === "fahrenheit" 
        ? (weatherData.temperature * 9/5) + 32 
        : weatherData.temperature;
      
      const tempUnit = unit === "fahrenheit" ? "°F" : "°C";
      
      let weatherText = `Weather in ${location}:
Temperature: ${temperature.toFixed(1)}${tempUnit}
Conditions: ${weatherData.description}
Humidity: ${weatherData.humidity}%
Wind Speed: ${weatherData.windSpeed} m/s`;

      if (includeHourly) {
        weatherText += "\n\n(Note: Hourly forecast would be implemented here)";
      }
      
      return {
        content: [{
          type: "text",
          text: weatherText
        }]
      };
    }
  );
}
```

### 4. Resource Implementation

**src/resources/logs.ts**
```typescript
import { McpServer, ResourceTemplate } from "@modelcontextprotocol/sdk/server/mcp.js";
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";
import { readFile } from "fs/promises";
import { join } from "path";

export function registerLogResources(server: McpServer) {
  // Static resource
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

### 5. Comprehensive Error Handling Utility

**src/utils/errors.ts**
```typescript
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";
import { ZodError } from "zod";

export function handleToolError(error: unknown, toolName: string): never {
  if (error instanceof McpError) {
    throw error;
  }
  
  if (error instanceof ZodError) {
    const validationErrors = error.errors.map(e => `${e.path.join('.')}: ${e.message}`).join(', ');
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

## Best Practices

### 1. Schema Design
- Use descriptive field names and include `.describe()` for AI understanding
- Set sensible defaults with `.default()`
- Use enums for constrained values
- Add validation constraints (`.min()`, `.max()`, `.regex()`)

### 2. Error Handling Strategy
- **Logic throws, handlers catch**: Core logic throws `McpError`, handlers format responses
- Use specific `ErrorCode` values for different error types
- Include helpful error messages for debugging
- Never let unhandled exceptions crash the server

### 3. Tool Registration Pattern
```typescript
// src/tools/index.ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { registerCalculatorTool } from "./calculator.js";
import { registerWeatherTool } from "./weather.js";

export async function registerTools(server: McpServer) {
  registerCalculatorTool(server);
  registerWeatherTool(server);
  // Register all tools before connecting transport
}
```

### 4. Environment Configuration
```typescript
// src/config.ts
import { z } from "zod";

const EnvSchema = z.object({
  WEATHER_API_KEY: z.string().min(1),
  LOG_DIR: z.string().default("./logs"),
  NODE_ENV: z.enum(["development", "production"]).default("development")
});

export const config = EnvSchema.parse(process.env);
```

## Testing Strategy

### 1. Test Setup and Utilities

**tests/setup.ts**
```typescript
import { vi, beforeEach, afterEach } from 'vitest';
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';

// Global test setup
beforeEach(() => {
  // Reset all mocks before each test
  vi.clearAllMocks();
  
  // Reset environment variables
  process.env.NODE_ENV = 'test';
});

afterEach(() => {
  // Cleanup after each test
  vi.restoreAllMocks();
});

// Test server factory
export function createTestServer(): McpServer {
  return new McpServer({
    name: 'test-server',
    version: '1.0.0'
  });
}

// Mock fetch for API testing
export function mockFetch(response: any, status = 200): void {
  global.fetch = vi.fn().mockResolvedValue({
    ok: status >= 200 && status < 300,
    status,
    json: () => Promise.resolve(response),
    text: () => Promise.resolve(JSON.stringify(response)),
    statusText: status === 200 ? 'OK' : 'Error'
  });
}

// Environment variable helper
export function setTestEnv(vars: Record<string, string>): void {
  Object.entries(vars).forEach(([key, value]) => {
    process.env[key] = value;
  });
}
```

### 2. Tool Unit Tests

**tests/tools/calculator.test.ts**
```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { McpError, ErrorCode } from '@modelcontextprotocol/sdk/types.js';
import { registerCalculatorTool } from '../../src/tools/calculator.js';
import { createTestServer } from '../setup.js';

describe('Calculator Tool', () => {
  let server: ReturnType<typeof createTestServer>;
  
  beforeEach(() => {
    server = createTestServer();
    registerCalculatorTool(server);
  });

  describe('addition', () => {
    it('should add positive numbers correctly', async () => {
      const result = await server.callTool('calculator', {
        operation: 'add',
        a: 2,
        b: 3
      });
      
      expect(result.content[0].text).toBe('2 add 3 = 5');
    });

    it('should handle negative numbers', async () => {
      const result = await server.callTool('calculator', {
        operation: 'add',
        a: -5,
        b: 3
      });
      
      expect(result.content[0].text).toBe('-5 add 3 = -2');
    });

    it('should handle decimal numbers', async () => {
      const result = await server.callTool('calculator', {
        operation: 'add',
        a: 1.5,
        b: 2.7
      });
      
      expect(result.content[0].text).toBe('1.5 add 2.7 = 4.2');
    });
  });

  describe('division', () => {
    it('should divide numbers correctly', async () => {
      const result = await server.callTool('calculator', {
        operation: 'divide',
        a: 10,
        b: 2
      });
      
      expect(result.content[0].text).toBe('10 divide 2 = 5');
    });

    it('should throw error for division by zero', async () => {
      await expect(
        server.callTool('calculator', {
          operation: 'divide',
          a: 10,
          b: 0
        })
      ).rejects.toThrow(McpError);
      
      await expect(
        server.callTool('calculator', {
          operation: 'divide',
          a: 10,
          b: 0
        })
      ).rejects.toMatchObject({
        code: ErrorCode.InvalidParams,
        message: 'Division by zero is not allowed'
      });
    });
  });

  describe('input validation', () => {
    it('should reject invalid operation', async () => {
      await expect(
        server.callTool('calculator', {
          operation: 'invalid' as any,
          a: 1,
          b: 2
        })
      ).rejects.toThrow();
    });

    it('should reject non-numeric inputs', async () => {
      await expect(
        server.callTool('calculator', {
          operation: 'add',
          a: 'not a number' as any,
          b: 2
        })
      ).rejects.toThrow();
    });

    it('should reject missing parameters', async () => {
      await expect(
        server.callTool('calculator', {
          operation: 'add',
          a: 1
          // missing b
        })
      ).rejects.toThrow();
    });
  });
});
```

**tests/tools/weather.test.ts**
```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { McpError, ErrorCode } from '@modelcontextprotocol/sdk/types.js';
import { registerWeatherTool } from '../../src/tools/weather.js';
import { createTestServer, mockFetch, setTestEnv } from '../setup.js';

describe('Weather Tool', () => {
  let server: ReturnType<typeof createTestServer>;
  
  beforeEach(() => {
    server = createTestServer();
    registerWeatherTool(server);
    setTestEnv({ WEATHER_API_KEY: 'test-api-key' });
  });

  describe('successful weather fetch', () => {
    it('should return weather data in celsius', async () => {
      mockFetch({
        main: { temp: 20, humidity: 65 },
        weather: [{ description: 'clear sky' }],
        wind: { speed: 3.5 }
      });

      const result = await server.callTool('get_weather', {
        location: 'London',
        unit: 'celsius'
      });

      expect(result.content[0].text).toContain('Temperature: 20.0°C');
      expect(result.content[0].text).toContain('Conditions: clear sky');
      expect(result.content[0].text).toContain('Humidity: 65%');
    });

    it('should convert temperature to fahrenheit', async () => {
      mockFetch({
        main: { temp: 20, humidity: 65 },
        weather: [{ description: 'clear sky' }],
        wind: { speed: 3.5 }
      });

      const result = await server.callTool('get_weather', {
        location: 'London',
        unit: 'fahrenheit'
      });

      expect(result.content[0].text).toContain('Temperature: 68.0°F');
    });

    it('should include hourly forecast note when requested', async () => {
      mockFetch({
        main: { temp: 20, humidity: 65 },
        weather: [{ description: 'clear sky' }],
        wind: { speed: 3.5 }
      });

      const result = await server.callTool('get_weather', {
        location: 'London',
        includeHourly: true
      });

      expect(result.content[0].text).toContain('Hourly forecast would be implemented');
    });
  });

  describe('error handling', () => {
    it('should handle location not found', async () => {
      mockFetch({}, 404);

      await expect(
        server.callTool('get_weather', {
          location: 'NonexistentCity'
        })
      ).rejects.toMatchObject({
        code: ErrorCode.InvalidParams,
        message: expect.stringContaining('Location not found')
      });
    });

    it('should handle API errors', async () => {
      mockFetch({}, 500);

      await expect(
        server.callTool('get_weather', {
          location: 'London'
        })
      ).rejects.toMatchObject({
        code: ErrorCode.InternalError,
        message: expect.stringContaining('Weather API error')
      });
    });

    it('should handle network errors', async () => {
      global.fetch = vi.fn().mockRejectedValue(new Error('Network error'));

      await expect(
        server.callTool('get_weather', {
          location: 'London'
        })
      ).rejects.toMatchObject({
        code: ErrorCode.InternalError,
        message: expect.stringContaining('Failed to fetch weather data')
      });
    });
  });
});
```

### 3. Schema Validation Tests

**tests/schemas/validation.test.ts**
```typescript
import { describe, it, expect } from 'vitest';
import { CalculatorSchema, WeatherSchema } from '../../src/schemas/tool-schemas.js';

describe('Schema Validation', () => {
  describe('CalculatorSchema', () => {
    it('should accept valid calculator input', () => {
      const validInput = {
        operation: 'add' as const,
        a: 5,
        b: 3
      };

      const result = CalculatorSchema.safeParse(validInput);
      expect(result.success).toBe(true);
      if (result.success) {
        expect(result.data).toEqual(validInput);
      }
    });

    it('should reject invalid operation', () => {
      const invalidInput = {
        operation: 'invalid',
        a: 5,
        b: 3
      };

      const result = CalculatorSchema.safeParse(invalidInput);
      expect(result.success).toBe(false);
    });

    it('should reject non-numeric inputs', () => {
      const invalidInput = {
        operation: 'add',
        a: 'not a number',
        b: 3
      };

      const result = CalculatorSchema.safeParse(invalidInput);
      expect(result.success).toBe(false);
    });
  });

  describe('WeatherSchema', () => {
    it('should accept valid weather input with defaults', () => {
      const input = { location: 'London' };
      
      const result = WeatherSchema.safeParse(input);
      expect(result.success).toBe(true);
      if (result.success) {
        expect(result.data.unit).toBe('celsius');
        expect(result.data.includeHourly).toBe(false);
      }
    });

    it('should reject empty location', () => {
      const invalidInput = { location: '' };
      
      const result = WeatherSchema.safeParse(invalidInput);
      expect(result.success).toBe(false);
    });

    it('should accept custom unit and hourly settings', () => {
      const input = {
        location: 'Paris',
        unit: 'fahrenheit' as const,
        includeHourly: true
      };
      
      const result = WeatherSchema.safeParse(input);
      expect(result.success).toBe(true);
      if (result.success) {
        expect(result.data).toEqual(input);
      }
    });
  });
});
```

### 4. Integration Tests

**tests/integration/server.test.ts**
```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { registerTools } from '../../src/tools/index.js';

describe('MCP Server Integration', () => {
  let server: McpServer;
  
  beforeEach(async () => {
    server = new McpServer({
      name: 'test-integration-server',
      version: '1.0.0'
    });
    
    await registerTools(server);
  });
  
  afterEach(async () => {
    await server.close();
  });

  it('should start server and list tools', async () => {
    const tools = await server.listTools();
    
    expect(tools.tools).toHaveLength(2);
    expect(tools.tools.map(t => t.name)).toContain('calculator');
    expect(tools.tools.map(t => t.name)).toContain('get_weather');
  });

  it('should handle tool execution end-to-end', async () => {
    const result = await server.callTool('calculator', {
      operation: 'multiply',
      a: 6,
      b: 7
    });
    
    expect(result.content[0].text).toBe('6 multiply 7 = 42');
  });

  it('should handle invalid tool names gracefully', async () => {
    await expect(
      server.callTool('nonexistent-tool', {})
    ).rejects.toThrow();
  });
});
```

### 5. Test Coverage and CI Integration

**package.json test configuration**
```json
{
  "scripts": {
    "test": "vitest",
    "test:ci": "vitest run --coverage --reporter=verbose",
    "test:watch": "vitest --watch",
    "test:ui": "vitest --ui --open",
    "coverage": "vitest run --coverage && open coverage/index.html"
  }
}
```

### 6. Testing Best Practices

**Key Testing Principles:**
- **Isolate external dependencies**: Mock APIs, file system, and network calls
- **Test error paths**: Ensure all error conditions are covered
- **Validate schemas separately**: Test Zod schemas independently from tool logic
- **Use type-safe mocks**: Leverage TypeScript for better test reliability
- **Test the happy path and edge cases**: Both success and failure scenarios

**Mock Patterns:**
```typescript
// Mock environment variables
setTestEnv({ API_KEY: 'test-key' });

// Mock external APIs
mockFetch({ data: 'response' }, 200);

// Mock file system
vi.mock('fs/promises', () => ({
  readFile: vi.fn().mockResolvedValue('test content')
}));

// Mock with different responses per call
global.fetch = vi.fn()
  .mockResolvedValueOnce({ ok: true, json: () => ({ temp: 20 }) })
  .mockResolvedValueOnce({ ok: false, status: 404 });
```

## Deployment Options

### 1. Local (stdio transport)
- Direct process communication via stdin/stdout
- Used by Claude Desktop, Cursor, and other local clients
- Configuration in client's MCP settings

### 2. Remote (HTTP transport)
```typescript
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamable.js";
import express from "express";

const app = express();
const server = new McpServer({ name: "remote-server", version: "1.0.0" });

// Register tools...

app.post("/mcp", async (req, res) => {
  const transport = new StreamableHTTPServerTransport();
  await server.connect(transport);
  await transport.handleRequest(req, res, req.body);
});

app.listen(3000);
```

## Debugging and Development

### 1. Use the MCP Inspector
```bash
npm run inspector
```
Opens a web interface to test your tools interactively.

### 2. Logging Best Practices
```typescript
// Use console.error for server logs (stdio uses stdout for protocol)
console.error("Tool executed:", toolName, args);
```

### 3. Validation Testing
```typescript
// Test schema validation separately
const result = CalculatorSchema.safeParse(input);
if (!result.success) {
  console.error("Validation failed:", result.error.format());
}
```

This guide provides a solid foundation for building production-ready MCP servers with TypeScript and Zod. The patterns emphasize type safety, proper error handling, and maintainable architecture that scales with your needs. }],

// Ensure error handling in tools
'mcp/require-error-handling': 'error',

// Validate schema definitions
'mcp/validate-schemas': 'error'
```

### 3. Code Formatting Standards

**Prettier configuration for MCP projects:**
```javascript
// prettier.config.js
export default {
  semi: true,
  trailingComma: 'es5',
  singleQuote: true,
  printWidth: 100,
  tabWidth: 2,
  useTabs: false,
  // MCP-specific formatting
  arrowParens: 'avoid',
  bracketSpacing: true,
  endOfLine: 'lf'
};
```

### 4. Quality Gates and CI Integration

**GitHub Actions workflow (.github/workflows/ci.yml):**
```yaml
name: CI

on: [push, pull_request]

jobs:
  quality:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'
      
      - run: npm ci
      - run: npm run lint
      - run: npm run format:check
      - run: npm run test:ci
      - run: npm run build
      
      # Upload coverage reports
      - uses: codecov/codecov-action@v3
        with:
          files: ./coverage/lcov.info
```bash
mkdir my-mcp-server
cd my-mcp-server
npm init -y
```

### 2. Essential Dependencies

```bash
# Core MCP and validation
npm install @modelcontextprotocol/sdk zod

# Development dependencies
npm install -D typescript @types/node

# Testing and linting
npm install -D vitest @vitest/ui eslint @typescript-eslint/parser @typescript-eslint/eslint-plugin eslint-config-prettier prettier
```

### 3. Project Configuration

**package.json**
```json
{
  "name": "my-mcp-server",
  "version": "1.0.0",
  "type": "module",
  "bin": {
    "my-mcp-server": "./build/index.js"
  },
  "files": ["build"],
  "scripts": {
    "build": "tsc && chmod +x build/index.js",
    "watch": "tsc --watch",
    "inspector": "npx @modelcontextprotocol/inspector build/index.js",
    "test": "vitest",
    "test:ui": "vitest --ui",
    "test:run": "vitest run",
    "test:coverage": "vitest run --coverage",
    "lint": "eslint src/**/*.ts",
    "lint:fix": "eslint src/**/*.ts --fix",
    "format": "prettier --write src/**/*.ts",
    "format:check": "prettier --check src/**/*.ts"
  },
  "dependencies": {
    "@modelcontextprotocol/sdk": "^0.6.0",
    "zod": "^3.22.0"
  },
  "devDependencies": {
    "@types/node": "^20.11.24",
    "typescript": "^5.3.3"
  }
}
```

**vitest.config.ts**
```typescript
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node',
    include: ['tests/**/*.test.ts'],
    exclude: ['node_modules', 'build'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'json', 'html'],
      exclude: ['tests/**', 'build/**', 'node_modules/**']
    }
  }
});
```

**eslint.config.js**
```javascript
import js from '@eslint/js';
import tseslint from '@typescript-eslint/eslint-plugin';
import tsparser from '@typescript-eslint/parser';
import prettier from 'eslint-config-prettier';

export default [
  js.configs.recommended,
  {
    files: ['src/**/*.ts'],
    languageOptions: {
      parser: tsparser,
      parserOptions: {
        ecmaVersion: 2022,
        sourceType: 'module',
        project: './tsconfig.json'
      }
    },
    plugins: {
      '@typescript-eslint': tseslint
    },
    rules: {
      ...tseslint.configs.recommended.rules,
      '@typescript-eslint/no-unused-vars': ['error', { argsIgnorePattern: '^_' }],
      '@typescript-eslint/explicit-function-return-type': 'warn',
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/prefer-const': 'error',
      'prefer-const': 'off', // Use TypeScript version
      'no-var': 'error',
      'no-console': ['warn', { allow: ['error', 'warn'] }], // Allow console.error for MCP logging
      'eqeqeq': 'error',
      'curly': 'error'
    }
  },
  {
    files: ['tests/**/*.ts'],
    rules: {
      '@typescript-eslint/no-explicit-any': 'off', // Allow any in tests
      'no-console': 'off' // Allow console in tests
    }
  },
  prettier
];
```

**prettier.config.js**
```javascript
export default {
  semi: true,
  trailingComma: 'es5',
  singleQuote: true,
  printWidth: 100,
  tabWidth: 2,
  useTabs: false
};
```

**tsconfig.json**
```json
{
  "compilerOptions": {
    "target": "ES2022",
    "module": "Node16",
    "moduleResolution": "Node16",
    "outDir": "./build",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "build"]
}
```

### 4. Recommended Project Structure

```
src/
├── index.ts              # Server entry point
├── tools/                # Tool definitions
│   ├── calculator.ts
│   └── weather.ts
├── resources/            # Resource handlers
│   └── logs.ts
├── schemas/              # Zod validation schemas
│   └── tool-schemas.ts
├── utils/                # Shared utilities
│   ├── errors.ts
│   └── validation.ts
└── types/                # TypeScript type definitions
    └── index.ts

tests/
├── setup.ts              # Test setup and utilities
├── tools/                # Tool-specific tests
│   ├── calculator.test.ts
│   └── weather.test.ts
├── resources/            # Resource tests
│   └── logs.test.ts
├── integration/          # End-to-end tests
│   └── server.test.ts
└── fixtures/             # Test data and mocks
    ├── weather-api.json
    └── log-samples.txt
```

## Core Implementation Patterns

### 1. Server Setup with Error Handling

**src/index.ts**
```typescript
#!/usr/bin/env node

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";
import { registerTools } from "./tools/index.js";
import { registerResources } from "./resources/index.js";

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

### 2. Tool Definition with Zod Validation

**src/schemas/tool-schemas.ts**
```typescript
import { z } from "zod";

export const CalculatorSchema = z.object({
  operation: z.enum(["add", "subtract", "multiply", "divide"]),
  a: z.number().describe("First number"),
  b: z.number().describe("Second number")
});

export const WeatherSchema = z.object({
  location: z.string().min(1).describe("City name or coordinates"),
  unit: z.enum(["celsius", "fahrenheit"]).default("celsius"),
  includeHourly: z.boolean().default(false).describe("Include hourly forecast")
});

export const FileSearchSchema = z.object({
  pattern: z.string().min(1).describe("Search pattern"),
  path: z.string().optional().describe("Directory path to search"),
  includeHidden: z.boolean().default(false)
});
```

**src/tools/calculator.ts**
```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";
import { z } from "zod";
import { CalculatorSchema } from "../schemas/tool-schemas.js";

type CalculatorInput = z.infer<typeof CalculatorSchema>;

export function registerCalculatorTool(server: McpServer) {
  server.registerTool(
    "calculator",
    {
      title: "Calculator",
      description: "Perform basic arithmetic operations with proper error handling",
      inputSchema: CalculatorSchema.shape
    },
    async (args: CalculatorInput) => {
      try {
        // Validate input (redundant but good practice)
        const { operation, a, b } = CalculatorSchema.parse(args);
        
        let result: number;
        
        switch (operation) {
          case "add":
            result = a + b;
            break;
          case "subtract":
            result = a - b;
            break;
          case "multiply":
            result = a * b;
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
          default:
            throw new McpError(
              ErrorCode.InvalidParams,
              `Unsupported operation: ${operation}`
            );
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

### 3. Advanced Tool with External API

**src/tools/weather.ts**
```typescript
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";
import { z } from "zod";
import { WeatherSchema } from "../schemas/tool-schemas.js";

type WeatherInput = z.infer<typeof WeatherSchema>;

interface WeatherData {
  temperature: number;
  description: string;
  humidity: number;
  windSpeed: number;
}

async function fetchWeatherData(location: string): Promise<WeatherData> {
  try {
    // Example using a weather API (replace with actual API)
    const response = await fetch(
      `https://api.openweathermap.org/data/2.5/weather?q=${encodeURIComponent(location)}&appid=${process.env.WEATHER_API_KEY}&units=metric`
    );
    
    if (!response.ok) {
      if (response.status === 404) {
        throw new McpError(ErrorCode.InvalidParams, `Location not found: ${location}`);
      }
      throw new McpError(ErrorCode.InternalError, `Weather API error: ${response.statusText}`);
    }
    
    const data = await response.json();
    
    return {
      temperature: data.main.temp,
      description: data.weather[0].description,
      humidity: data.main.humidity,
      windSpeed: data.wind.speed
    };
  } catch (error) {
    if (error instanceof McpError) {
      throw error;
    }
    throw new McpError(ErrorCode.InternalError, `Failed to fetch weather data: ${error}`);
  }
}

export function registerWeatherTool(server: McpServer) {
  server.registerTool(
    "get_weather",
    {
      title: "Get Weather",
      description: "Get current weather information for a specified location",
      inputSchema: WeatherSchema.shape
    },
    async (args: WeatherInput) => {
      const { location, unit, includeHourly } = WeatherSchema.parse(args);
      
      const weatherData = await fetchWeatherData(location);
      
      // Convert temperature if needed
      const temperature = unit === "fahrenheit" 
        ? (weatherData.temperature * 9/5) + 32 
        : weatherData.temperature;
      
      const tempUnit = unit === "fahrenheit" ? "°F" : "°C";
      
      let weatherText = `Weather in ${location}:
Temperature: ${temperature.toFixed(1)}${tempUnit}
Conditions: ${weatherData.description}
Humidity: ${weatherData.humidity}%
Wind Speed: ${weatherData.windSpeed} m/s`;

      if (includeHourly) {
        weatherText += "\n\n(Note: Hourly forecast would be implemented here)";
      }
      
      return {
        content: [{
          type: "text",
          text: weatherText
        }]
      };
    }
  );
}
```

### 4. Resource Implementation

**src/resources/logs.ts**
```typescript
import { McpServer, ResourceTemplate } from "@modelcontextprotocol/sdk/server/mcp.js";
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";
import { readFile } from "fs/promises";
import { join } from "path";

export function registerLogResources(server: McpServer) {
  // Static resource
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

### 5. Comprehensive Error Handling Utility

**src/utils/errors.ts**
```typescript
import { McpError, ErrorCode } from "@modelcontextprotocol/sdk/types.js";
import { ZodError } from "zod";

export function handleToolError(error: unknown, toolName: string): never {
  if (error instanceof McpError) {
    throw error;
  }
  
  if (error instanceof ZodError) {
    const validationErrors = error.errors.map(e => `${e.path.join('.')}: ${e.message}`).join(', ');
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

## Best Practices

### 1. Schema Design
- Use descriptive field names and include `.describe()` for AI understanding
- Set sensible defaults with `.default()`
- Use enums for constrained values
- Add validation constraints (`.min()`, `.max()`, `.regex()`)

### 2. Error Handling Strategy
- **Logic throws, handlers catch**: Core logic throws `McpError`, handlers format responses
- Use specific `ErrorCode` values for different error types
- Include helpful error messages for debugging
- Never let unhandled exceptions crash the server

### 3. Tool Registration Pattern
```typescript
// src/tools/index.ts
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { registerCalculatorTool } from "./calculator.js";
import { registerWeatherTool } from "./weather.js";

export async function registerTools(server: McpServer) {
  registerCalculatorTool(server);
  registerWeatherTool(server);
  // Register all tools before connecting transport
}
```

### 4. Environment Configuration
```typescript
// src/config.ts
import { z } from "zod";

const EnvSchema = z.object({
  WEATHER_API_KEY: z.string().min(1),
  LOG_DIR: z.string().default("./logs"),
  NODE_ENV: z.enum(["development", "production"]).default("development")
});

export const config = EnvSchema.parse(process.env);
```

## Testing Strategy

### 1. Test Setup and Utilities

**tests/setup.ts**
```typescript
import { vi, beforeEach, afterEach } from 'vitest';
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';

// Global test setup
beforeEach(() => {
  // Reset all mocks before each test
  vi.clearAllMocks();
  
  // Reset environment variables
  process.env.NODE_ENV = 'test';
});

afterEach(() => {
  // Cleanup after each test
  vi.restoreAllMocks();
});

// Test server factory
export function createTestServer(): McpServer {
  return new McpServer({
    name: 'test-server',
    version: '1.0.0'
  });
}

// Mock fetch for API testing
export function mockFetch(response: any, status = 200): void {
  global.fetch = vi.fn().mockResolvedValue({
    ok: status >= 200 && status < 300,
    status,
    json: () => Promise.resolve(response),
    text: () => Promise.resolve(JSON.stringify(response)),
    statusText: status === 200 ? 'OK' : 'Error'
  });
}

// Environment variable helper
export function setTestEnv(vars: Record<string, string>): void {
  Object.entries(vars).forEach(([key, value]) => {
    process.env[key] = value;
  });
}
```

### 2. Tool Unit Tests

**tests/tools/calculator.test.ts**
```typescript
import { describe, it, expect, beforeEach } from 'vitest';
import { McpError, ErrorCode } from '@modelcontextprotocol/sdk/types.js';
import { registerCalculatorTool } from '../../src/tools/calculator.js';
import { createTestServer } from '../setup.js';

describe('Calculator Tool', () => {
  let server: ReturnType<typeof createTestServer>;
  
  beforeEach(() => {
    server = createTestServer();
    registerCalculatorTool(server);
  });

  describe('addition', () => {
    it('should add positive numbers correctly', async () => {
      const result = await server.callTool('calculator', {
        operation: 'add',
        a: 2,
        b: 3
      });
      
      expect(result.content[0].text).toBe('2 add 3 = 5');
    });

    it('should handle negative numbers', async () => {
      const result = await server.callTool('calculator', {
        operation: 'add',
        a: -5,
        b: 3
      });
      
      expect(result.content[0].text).toBe('-5 add 3 = -2');
    });

    it('should handle decimal numbers', async () => {
      const result = await server.callTool('calculator', {
        operation: 'add',
        a: 1.5,
        b: 2.7
      });
      
      expect(result.content[0].text).toBe('1.5 add 2.7 = 4.2');
    });
  });

  describe('division', () => {
    it('should divide numbers correctly', async () => {
      const result = await server.callTool('calculator', {
        operation: 'divide',
        a: 10,
        b: 2
      });
      
      expect(result.content[0].text).toBe('10 divide 2 = 5');
    });

    it('should throw error for division by zero', async () => {
      await expect(
        server.callTool('calculator', {
          operation: 'divide',
          a: 10,
          b: 0
        })
      ).rejects.toThrow(McpError);
      
      await expect(
        server.callTool('calculator', {
          operation: 'divide',
          a: 10,
          b: 0
        })
      ).rejects.toMatchObject({
        code: ErrorCode.InvalidParams,
        message: 'Division by zero is not allowed'
      });
    });
  });

  describe('input validation', () => {
    it('should reject invalid operation', async () => {
      await expect(
        server.callTool('calculator', {
          operation: 'invalid' as any,
          a: 1,
          b: 2
        })
      ).rejects.toThrow();
    });

    it('should reject non-numeric inputs', async () => {
      await expect(
        server.callTool('calculator', {
          operation: 'add',
          a: 'not a number' as any,
          b: 2
        })
      ).rejects.toThrow();
    });

    it('should reject missing parameters', async () => {
      await expect(
        server.callTool('calculator', {
          operation: 'add',
          a: 1
          // missing b
        })
      ).rejects.toThrow();
    });
  });
});
```

**tests/tools/weather.test.ts**
```typescript
import { describe, it, expect, beforeEach, vi } from 'vitest';
import { McpError, ErrorCode } from '@modelcontextprotocol/sdk/types.js';
import { registerWeatherTool } from '../../src/tools/weather.js';
import { createTestServer, mockFetch, setTestEnv } from '../setup.js';

describe('Weather Tool', () => {
  let server: ReturnType<typeof createTestServer>;
  
  beforeEach(() => {
    server = createTestServer();
    registerWeatherTool(server);
    setTestEnv({ WEATHER_API_KEY: 'test-api-key' });
  });

  describe('successful weather fetch', () => {
    it('should return weather data in celsius', async () => {
      mockFetch({
        main: { temp: 20, humidity: 65 },
        weather: [{ description: 'clear sky' }],
        wind: { speed: 3.5 }
      });

      const result = await server.callTool('get_weather', {
        location: 'London',
        unit: 'celsius'
      });

      expect(result.content[0].text).toContain('Temperature: 20.0°C');
      expect(result.content[0].text).toContain('Conditions: clear sky');
      expect(result.content[0].text).toContain('Humidity: 65%');
    });

    it('should convert temperature to fahrenheit', async () => {
      mockFetch({
        main: { temp: 20, humidity: 65 },
        weather: [{ description: 'clear sky' }],
        wind: { speed: 3.5 }
      });

      const result = await server.callTool('get_weather', {
        location: 'London',
        unit: 'fahrenheit'
      });

      expect(result.content[0].text).toContain('Temperature: 68.0°F');
    });

    it('should include hourly forecast note when requested', async () => {
      mockFetch({
        main: { temp: 20, humidity: 65 },
        weather: [{ description: 'clear sky' }],
        wind: { speed: 3.5 }
      });

      const result = await server.callTool('get_weather', {
        location: 'London',
        includeHourly: true
      });

      expect(result.content[0].text).toContain('Hourly forecast would be implemented');
    });
  });

  describe('error handling', () => {
    it('should handle location not found', async () => {
      mockFetch({}, 404);

      await expect(
        server.callTool('get_weather', {
          location: 'NonexistentCity'
        })
      ).rejects.toMatchObject({
        code: ErrorCode.InvalidParams,
        message: expect.stringContaining('Location not found')
      });
    });

    it('should handle API errors', async () => {
      mockFetch({}, 500);

      await expect(
        server.callTool('get_weather', {
          location: 'London'
        })
      ).rejects.toMatchObject({
        code: ErrorCode.InternalError,
        message: expect.stringContaining('Weather API error')
      });
    });

    it('should handle network errors', async () => {
      global.fetch = vi.fn().mockRejectedValue(new Error('Network error'));

      await expect(
        server.callTool('get_weather', {
          location: 'London'
        })
      ).rejects.toMatchObject({
        code: ErrorCode.InternalError,
        message: expect.stringContaining('Failed to fetch weather data')
      });
    });
  });
});
```

### 3. Schema Validation Tests

**tests/schemas/validation.test.ts**
```typescript
import { describe, it, expect } from 'vitest';
import { CalculatorSchema, WeatherSchema } from '../../src/schemas/tool-schemas.js';

describe('Schema Validation', () => {
  describe('CalculatorSchema', () => {
    it('should accept valid calculator input', () => {
      const validInput = {
        operation: 'add' as const,
        a: 5,
        b: 3
      };

      const result = CalculatorSchema.safeParse(validInput);
      expect(result.success).toBe(true);
      if (result.success) {
        expect(result.data).toEqual(validInput);
      }
    });

    it('should reject invalid operation', () => {
      const invalidInput = {
        operation: 'invalid',
        a: 5,
        b: 3
      };

      const result = CalculatorSchema.safeParse(invalidInput);
      expect(result.success).toBe(false);
    });

    it('should reject non-numeric inputs', () => {
      const invalidInput = {
        operation: 'add',
        a: 'not a number',
        b: 3
      };

      const result = CalculatorSchema.safeParse(invalidInput);
      expect(result.success).toBe(false);
    });
  });

  describe('WeatherSchema', () => {
    it('should accept valid weather input with defaults', () => {
      const input = { location: 'London' };
      
      const result = WeatherSchema.safeParse(input);
      expect(result.success).toBe(true);
      if (result.success) {
        expect(result.data.unit).toBe('celsius');
        expect(result.data.includeHourly).toBe(false);
      }
    });

    it('should reject empty location', () => {
      const invalidInput = { location: '' };
      
      const result = WeatherSchema.safeParse(invalidInput);
      expect(result.success).toBe(false);
    });

    it('should accept custom unit and hourly settings', () => {
      const input = {
        location: 'Paris',
        unit: 'fahrenheit' as const,
        includeHourly: true
      };
      
      const result = WeatherSchema.safeParse(input);
      expect(result.success).toBe(true);
      if (result.success) {
        expect(result.data).toEqual(input);
      }
    });
  });
});
```

### 4. Integration Tests

**tests/integration/server.test.ts**
```typescript
import { describe, it, expect, beforeEach, afterEach } from 'vitest';
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { registerTools } from '../../src/tools/index.js';

describe('MCP Server Integration', () => {
  let server: McpServer;
  
  beforeEach(async () => {
    server = new McpServer({
      name: 'test-integration-server',
      version: '1.0.0'
    });
    
    await registerTools(server);
  });
  
  afterEach(async () => {
    await server.close();
  });

  it('should start server and list tools', async () => {
    const tools = await server.listTools();
    
    expect(tools.tools).toHaveLength(2);
    expect(tools.tools.map(t => t.name)).toContain('calculator');
    expect(tools.tools.map(t => t.name)).toContain('get_weather');
  });

  it('should handle tool execution end-to-end', async () => {
    const result = await server.callTool('calculator', {
      operation: 'multiply',
      a: 6,
      b: 7
    });
    
    expect(result.content[0].text).toBe('6 multiply 7 = 42');
  });

  it('should handle invalid tool names gracefully', async () => {
    await expect(
      server.callTool('nonexistent-tool', {})
    ).rejects.toThrow();
  });
});
```

### 5. Test Coverage and CI Integration

**package.json test configuration**
```json
{
  "scripts": {
    "test": "vitest",
    "test:ci": "vitest run --coverage --reporter=verbose",
    "test:watch": "vitest --watch",
    "test:ui": "vitest --ui --open",
    "coverage": "vitest run --coverage && open coverage/index.html"
  }
}
```

### 6. Testing Best Practices

**Key Testing Principles:**
- **Isolate external dependencies**: Mock APIs, file system, and network calls
- **Test error paths**: Ensure all error conditions are covered
- **Validate schemas separately**: Test Zod schemas independently from tool logic
- **Use type-safe mocks**: Leverage TypeScript for better test reliability
- **Test the happy path and edge cases**: Both success and failure scenarios

**Mock Patterns:**
```typescript
// Mock environment variables
setTestEnv({ API_KEY: 'test-key' });

// Mock external APIs
mockFetch({ data: 'response' }, 200);

// Mock file system
vi.mock('fs/promises', () => ({
  readFile: vi.fn().mockResolvedValue('test content')
}));

// Mock with different responses per call
global.fetch = vi.fn()
  .mockResolvedValueOnce({ ok: true, json: () => ({ temp: 20 }) })
  .mockResolvedValueOnce({ ok: false, status: 404 });
```

## Deployment Options

### 1. Local (stdio transport)
- Direct process communication via stdin/stdout
- Used by Claude Desktop, Cursor, and other local clients
- Configuration in client's MCP settings

### 2. Remote (HTTP transport)
```typescript
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamable.js";
import express from "express";

const app = express();
const server = new McpServer({ name: "remote-server", version: "1.0.0" });

// Register tools...

app.post("/mcp", async (req, res) => {
  const transport = new StreamableHTTPServerTransport();
  await server.connect(transport);
  await transport.handleRequest(req, res, req.body);
});

app.listen(3000);
```

## Debugging and Development

### 1. Use the MCP Inspector
```bash
npm run inspector
```
Opens a web interface to test your tools interactively.

### 2. Logging Best Practices
```typescript
// Use console.error for server logs (stdio uses stdout for protocol)
console.error("Tool executed:", toolName, args);
```

### 3. Validation Testing
```typescript
// Test schema validation separately
const result = CalculatorSchema.safeParse(input);
if (!result.success) {
  console.error("Validation failed:", result.error.format());
}
```

This guide provides a solid foundation for building production-ready MCP servers with TypeScript and Zod. The patterns emphasize type safety, proper error handling, and maintainable architecture that scales with your needs.