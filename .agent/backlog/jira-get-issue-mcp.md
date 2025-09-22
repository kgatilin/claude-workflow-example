I want a simple MCP server with a single tool that returns a Jira issue by its key. The tool should be called `get_jira_issue` and it should take a single argument, `issue_key`. The tool should return the issue's summary, description, status, and assignee.

The credentials should be stored in the .env file, the path to the .env file should be passed to the MCP server as an argument, e.g.:
```
my-mcp-server .env
```

Use WebSearch tool to find the latest Atlassian API documentation for getting a Jira issue by its key. Use the documentation to implement the `get_jira_issue` tool.

Read @docs/mcp_guide.md for MCP server implementation details and best practices.