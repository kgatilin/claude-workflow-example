#!/usr/bin/env tsx

/**
 * Simple MCP Client Test Script
 *
 * Usage: npm run test:mcp <path-to-env-file>
 *
 * Tests the Jira MCP server by:
 * 1. Spawning the server process with .env file
 * 2. Connecting an MCP client via stdio
 * 3. Calling get_jira_issue tool with EPMAI-145
 * 4. Logging the response
 */

import { Client } from "@modelcontextprotocol/sdk/client/index.js";
import { StdioClientTransport } from "@modelcontextprotocol/sdk/client/stdio.js";
import { spawn } from "child_process";
import path from "path";
import { fileURLToPath } from "url";
import { existsSync } from "fs";

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

async function main() {
  console.log("🚀 Starting MCP Client Test\n");

  // Get .env path from command line arguments, default to .env in project root
  const envPathArg = process.argv[2] || ".env";

  console.log(`🔍 Looking for env file: ${envPathArg}`);

  // Resolve to absolute path
  const envPath = path.isAbsolute(envPathArg)
    ? envPathArg
    : path.join(process.cwd(), envPathArg);

  // Validate .env file exists
  if (!existsSync(envPath)) {
    console.error(`❌ Error: .env file not found at: ${envPath}`);
    process.exit(1);
  }

  // Path to the compiled MCP server
  const serverPath = path.join(__dirname, "..", "dist", "index.js");

  console.log(`📦 Server path: ${serverPath}`);
  console.log(`⚙️  Env file: ${envPath}\n`);

  // Spawn the MCP server process
  const serverProcess = spawn("node", [serverPath, envPath], {
    stdio: ["pipe", "pipe", "inherit"], // stdin, stdout, stderr
  });

  // Create MCP client with stdio transport
  const transport = new StdioClientTransport({
    command: "node",
    args: [serverPath, envPath],
  });

  const client = new Client(
    {
      name: "mcp-test-client",
      version: "1.0.0",
    },
    {
      capabilities: {},
    }
  );

  try {
    // Connect to the server
    console.log("🔌 Connecting to MCP server...");
    await client.connect(transport);
    console.log("✅ Connected successfully\n");

    // List available tools
    console.log("📋 Listing available tools...");
    const tools = await client.listTools();
    console.log("Available tools:", JSON.stringify(tools, null, 2));
    console.log();

    // Call the get_jira_issue tool
    console.log("🎫 Calling get_jira_issue with issue key: EPMAI-145");
    const response = await client.callTool({
      name: "get_jira_issue",
      arguments: {
        issue_key: "EPMAI-145",
      },
    });

    console.log("\n📤 Response received:");
    console.log("=".repeat(80));
    console.log(JSON.stringify(response, null, 2));
    console.log("=".repeat(80));

    // Parse and display the content
    if (response.content && response.content.length > 0) {
      const textContent = response.content.find((c) => c.type === "text");
      if (textContent && "text" in textContent) {
        console.log("\n📄 Parsed Issue Data:");
        console.log("=".repeat(80));
        const issueData = JSON.parse(textContent.text);
        console.log(`Summary: ${issueData.summary}`);
        console.log(`Status: ${issueData.status}`);
        console.log(`Assignee: ${issueData.assignee}`);
        console.log(`Description: ${issueData.description.substring(0, 100)}...`);
        console.log("=".repeat(80));
      }
    }

    console.log("\n✅ Test completed successfully!");
  } catch (error) {
    console.error("\n❌ Error occurred:");
    console.error(error);
    process.exit(1);
  } finally {
    // Clean up
    console.log("\n🧹 Cleaning up...");
    await client.close();
    serverProcess.kill();
    console.log("👋 Goodbye!");
  }
}

main().catch((error) => {
  console.error("Fatal error:", error);
  process.exit(1);
});
