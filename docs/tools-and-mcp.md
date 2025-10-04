# Tools & MCP - Claude Agent SDK

> **Comprehensive guide to built-in tools, custom tool development, and the MCP ecosystem**

[← Back to Index](index.md)

---

## Table of Contents

1. [Built-in Tools](#built-in-tools)
2. [Custom Tool Development](#custom-tool-development)
3. [MCP Server Architecture](#mcp-server-architecture)
4. [MCP Ecosystem Catalog](#mcp-ecosystem-catalog)
5. [Building Custom MCP Servers](#building-custom-mcp-servers)
6. [Tool Integration Patterns](#tool-integration-patterns)

---

## Built-in Tools

The Claude Agent SDK provides six core built-in tools that enable file operations, code execution, and web access.[^1]

### Read Tool

Reads file contents from the filesystem.

**Capabilities**:
- Read any file with absolute path
- Line offset and limit for large files
- Automatic line numbering (cat -n format)
- Multimodal support (images, PDFs, Jupyter notebooks)

**Example**:
```python
from claude_agent_sdk import ClaudeAgentOptions, ClaudeSDKClient

options = ClaudeAgentOptions(
    allowed_tools=["Read"],
    permission_mode='ask'
)

async with ClaudeSDKClient(options=options) as client:
    await client.query("Read the config.json file")
    async for msg in client.receive_response():
        print(msg)
```

**Permission Control**:
- `permission_mode='ask'`: Prompt for each read
- `permission_mode='acceptAll'`: Auto-approve all reads

### Write Tool

Creates or overwrites files on the filesystem.

**Capabilities**:
- Create new files with absolute paths
- Overwrite existing files (requires Read first)
- Automatic directory creation
- UTF-8 encoding support

**Safety Requirements**:
- Must Read existing files before Write
- Fails if file exists and not previously read

**Example**:
```python
options = ClaudeAgentOptions(
    allowed_tools=["Read", "Write"],
    permission_mode='acceptEdits'  # Auto-approve file edits
)

async with ClaudeSDKClient(options=options) as client:
    await client.query("Create a hello.py file with a print statement")
    async for msg in client.receive_response():
        print(msg)
```

### Edit Tool

Performs exact string replacements in files.

**Capabilities**:
- Exact string matching for old_string
- Preserve indentation and formatting
- Replace all occurrences with `replace_all=true`
- Must Read file first (enforced)

**Critical Requirements**:[^2]
- Preserve exact indentation from Read output
- `old_string` must be unique unless using `replace_all`
- Never include line number prefixes in strings

**Example**:
```python
# Claude will read the file first, then edit
await client.query("In config.py, change DEBUG=False to DEBUG=True")
```

### Bash Tool

Executes shell commands with timeout and environment control.

**Capabilities**:
- Command execution up to 10-minute timeout
- Background execution with `run_in_background`
- Environment variable access
- Output streaming for long-running commands

**Security Considerations**:[^3]
- Command injection risks require validation
- Use hooks for command filtering
- Avoid user-controlled command strings

**Example**:
```python
options = ClaudeAgentOptions(
    allowed_tools=["Bash"],
    permission_mode='ask'
)

async with ClaudeSDKClient(options=options) as client:
    await client.query("Run pytest on the tests directory")
    async for msg in client.receive_response():
        print(msg)
```

**Background Execution**:
```python
# Long-running commands can be backgrounded
await client.query("Start the development server in background")
# Claude uses: Bash(command="npm run dev", run_in_background=True)
```

### Grep Tool

Powerful search built on ripgrep for code exploration.

**Capabilities**:
- Full regex syntax support
- File type filtering (`type="py"`)
- Glob pattern matching (`glob="*.js"`)
- Context lines (-A, -B, -C)
- Case-insensitive search (-i)
- Multiline mode for cross-line patterns

**Output Modes**:
- `files_with_matches`: File paths only (default)
- `content`: Matching lines with context
- `count`: Match count per file

**Example**:
```python
await client.query("Find all functions named 'process_data' in Python files")
# Claude uses: Grep(pattern="def process_data", type="py", output_mode="content")
```

**Advanced Search**:
```python
# Search with context lines
# Claude uses: Grep(pattern="TODO", glob="**/*.py", -B=2, -C=2, -n=True)
await client.query("Find all TODO comments in Python with context")
```

### Glob Tool

Fast file pattern matching for file discovery.

**Capabilities**:
- Glob patterns (`**/*.js`, `src/**/*.ts`)
- Results sorted by modification time
- Recursive directory traversal
- Fast codebase-wide file location

**Example**:
```python
await client.query("Find all TypeScript files in the src directory")
# Claude uses: Glob(pattern="src/**/*.ts")
```

### WebFetch Tool

Retrieves and processes web content with AI analysis.

**Capabilities**:
- URL content fetching
- HTML to markdown conversion
- AI-powered content extraction
- 15-minute response cache
- Automatic HTTPS upgrade

**Example**:
```python
options = ClaudeAgentOptions(
    allowed_tools=["WebFetch"],
    permission_mode='acceptAll'
)

async with ClaudeSDKClient(options=options) as client:
    await client.query("Fetch the latest Python release notes from python.org")
    async for msg in client.receive_response():
        print(msg)
```

---

## Custom Tool Development

The `@tool` decorator enables custom tool creation for domain-specific functionality.[^4]

### Tool Definition Pattern

**Basic Structure**:
```python
from claude_agent_sdk import tool

@tool(
    name="tool_name",           # Unique identifier
    description="What it does", # For Claude's understanding
    schema={"param": type}      # Input parameter schema
)
async def tool_function(args: dict) -> dict:
    # Access parameters
    value = args["param"]

    # Perform work
    result = perform_operation(value)

    # Return formatted response
    return {
        "content": [
            {"type": "text", "text": f"Result: {result}"}
        ]
    }
```

### Parameter Schema Types

**Supported Types**:
- `str`: String values
- `int`: Integer numbers
- `float`: Floating-point numbers
- `bool`: Boolean true/false
- `list`: Array of values
- `dict`: Object/dictionary structures

**Example - Complex Schema**:
```python
@tool(
    "search_database",
    "Search database with filters and sorting",
    {
        "query": str,          # Required string
        "limit": int,          # Required integer
        "filters": dict,       # Optional object
        "sort_by": str         # Optional string
    }
)
async def search_database(args):
    query = args["query"]
    limit = args.get("limit", 10)  # Default if not provided
    filters = args.get("filters", {})
    sort_by = args.get("sort_by", "relevance")

    results = db.search(query, limit, filters, sort_by)

    return {
        "content": [
            {"type": "text", "text": format_results(results)}
        ]
    }
```

### Error Handling in Tools

**Return Error Indicator**:
```python
@tool("divide", "Divide two numbers", {"a": float, "b": float})
async def divide(args):
    try:
        result = args["a"] / args["b"]
        return {
            "content": [
                {"type": "text", "text": f"Result: {result}"}
            ]
        }
    except ZeroDivisionError:
        return {
            "content": [
                {"type": "text", "text": "Error: Division by zero"}
            ],
            "isError": True  # Signals error to Claude
        }
```

### Tool Return Format

**Standard Return**:
```python
{
    "content": [
        {"type": "text", "text": "Response text here"}
    ]
}
```

**Optional Fields**:
- `isError` (bool): Indicates error condition
- Additional content blocks for rich responses

---

## MCP Server Architecture

Model Context Protocol (MCP) enables tool integration through standardized server communication.[^5]

### In-Process MCP Servers

**Created with `create_sdk_mcp_server()`**:
```python
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool("greet", "Greet a user", {"name": str})
async def greet_user(args):
    return {
        "content": [{
            "type": "text",
            "text": f"Hello, {args['name']}!"
        }]
    }

# Create in-process MCP server
server = create_sdk_mcp_server(
    name="greetings",
    version="1.0.0",
    tools=[greet_user]
)
```

**Integration with ClaudeSDKClient**:
```python
options = ClaudeAgentOptions(
    mcp_servers={"greetings": server},
    allowed_tools=["mcp__greetings__greet"]
)

async with ClaudeSDKClient(options=options) as client:
    await client.query("Greet Alice")
    async for msg in client.receive_response():
        print(msg)
```

### External MCP Servers

**Configuration Format**:
```python
options = ClaudeAgentOptions(
    mcp_servers={
        "filesystem": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/dir"]
        },
        "github": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-github"],
            "env": {"GITHUB_TOKEN": "your_token"}
        }
    },
    allowed_tools=[
        "mcp__filesystem__read_file",
        "mcp__github__create_issue"
    ]
)
```

### MCP Tool Naming Convention

**Format**: `mcp__<server_name>__<tool_name>`

**Examples**:
- `mcp__greetings__greet` - In-process server tool
- `mcp__filesystem__read_file` - External server tool
- `mcp__github__create_issue` - GitHub MCP server tool

---

## MCP Ecosystem Catalog

The MCP ecosystem includes 500+ servers across multiple categories.[^6]

### Official Anthropic Servers

**Productivity & Communication**:
- **@modelcontextprotocol/server-slack** - Slack workspace integration
- **@modelcontextprotocol/server-gmail** - Gmail operations
- **@modelcontextprotocol/server-google-drive** - Google Drive access

**Development Tools**:
- **@modelcontextprotocol/server-github** - GitHub repository management
- **@modelcontextprotocol/server-gitlab** - GitLab integration
- **@modelcontextprotocol/server-git** - Local Git operations

**Data & Databases**:
- **@modelcontextprotocol/server-postgres** - PostgreSQL integration
- **@modelcontextprotocol/server-sqlite** - SQLite database access
- **@modelcontextprotocol/server-mysql** - MySQL operations

**File Systems**:
- **@modelcontextprotocol/server-filesystem** - Local filesystem access
- **@modelcontextprotocol/server-gdrive** - Google Drive filesystem

**Web & Search**:
- **@modelcontextprotocol/server-brave-search** - Brave Search API
- **@modelcontextprotocol/server-fetch** - HTTP requests and web scraping

### Microsoft Catalog Servers

**Azure Services**:
- **mcp-azure-search** - Azure AI Search integration
- **mcp-azure-storage** - Azure Blob Storage
- **mcp-cosmosdb** - Cosmos DB operations

**Microsoft 365**:
- **mcp-teams** - Microsoft Teams integration
- **mcp-sharepoint** - SharePoint access
- **mcp-outlook** - Outlook operations

### Community Servers

**Development & DevOps** (150+ servers):
- **mcp-jira** - Jira project management
- **mcp-linear** - Linear issue tracking
- **mcp-kubernetes** - Kubernetes cluster management
- **mcp-docker** - Docker container operations
- **mcp-terraform** - Infrastructure as code

**Business & CRM** (80+ servers):
- **mcp-salesforce** - Salesforce CRM
- **mcp-hubspot** - HubSpot marketing
- **mcp-zendesk** - Customer support

**Data & Analytics** (120+ servers):
- **mcp-snowflake** - Snowflake data warehouse
- **mcp-bigquery** - Google BigQuery
- **mcp-redshift** - AWS Redshift
- **mcp-elasticsearch** - Elasticsearch search

**AI & ML** (50+ servers):
- **mcp-openai** - OpenAI API integration
- **mcp-anthropic** - Anthropic Claude API
- **mcp-huggingface** - Hugging Face models

**Cloud Providers** (90+ servers):
- **mcp-aws-s3** - AWS S3 storage
- **mcp-gcp-storage** - Google Cloud Storage
- **mcp-azure-functions** - Azure Functions

### Finding MCP Servers

**Official Sources**:
1. **Anthropic MCP Registry**: https://github.com/modelcontextprotocol/servers
2. **Microsoft Catalog**: https://github.com/microsoft/mcp-servers
3. **Awesome MCP**: https://github.com/punkpeye/awesome-mcp

**Installation Pattern** (npm-based):
```bash
# Install via npx (no local install needed)
npx -y @modelcontextprotocol/server-github
```

---

## Building Custom MCP Servers

Create specialized MCP servers for domain-specific functionality.[^7]

### Python MCP Server Template

**File: `custom_server.py`**
```python
from mcp.server import Server
from mcp.types import Tool, TextContent
import asyncio

# Create server instance
server = Server("custom-server")

@server.list_tools()
async def list_tools() -> list[Tool]:
    """Define available tools"""
    return [
        Tool(
            name="custom_tool",
            description="Description of what this tool does",
            inputSchema={
                "type": "object",
                "properties": {
                    "param1": {
                        "type": "string",
                        "description": "First parameter"
                    },
                    "param2": {
                        "type": "integer",
                        "description": "Second parameter",
                        "default": 10
                    }
                },
                "required": ["param1"]
            }
        )
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    """Handle tool execution"""
    if name == "custom_tool":
        param1 = arguments["param1"]
        param2 = arguments.get("param2", 10)

        # Perform operations
        result = perform_work(param1, param2)

        return [
            TextContent(
                type="text",
                text=f"Result: {result}"
            )
        ]

    raise ValueError(f"Unknown tool: {name}")

async def main():
    from mcp.server.stdio import stdio_server

    async with stdio_server() as (read_stream, write_stream):
        await server.run(
            read_stream,
            write_stream,
            server.create_initialization_options()
        )

if __name__ == "__main__":
    asyncio.run(main())
```

### TypeScript MCP Server Template

**File: `custom-server.ts`**
```typescript
import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

const server = new Server(
  {
    name: "custom-server",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// List available tools
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "custom_tool",
        description: "Description of what this tool does",
        inputSchema: {
          type: "object",
          properties: {
            param1: {
              type: "string",
              description: "First parameter",
            },
            param2: {
              type: "number",
              description: "Second parameter",
              default: 10,
            },
          },
          required: ["param1"],
        },
      },
    ],
  };
});

// Handle tool calls
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  if (request.params.name === "custom_tool") {
    const { param1, param2 = 10 } = request.params.arguments;

    // Perform operations
    const result = performWork(param1, param2);

    return {
      content: [
        {
          type: "text",
          text: `Result: ${result}`,
        },
      ],
    };
  }

  throw new Error(`Unknown tool: ${request.params.name}`);
});

// Start server
async function main() {
  const transport = new StdioServerTransport();
  await server.connect(transport);
}

main().catch(console.error);
```

### MCP Server Configuration

**Add to ClaudeAgentOptions**:
```python
from claude_agent_sdk import ClaudeAgentOptions, ClaudeSDKClient

options = ClaudeAgentOptions(
    mcp_servers={
        "custom": {
            "command": "python",
            "args": ["/path/to/custom_server.py"]
        }
    },
    allowed_tools=["mcp__custom__custom_tool"]
)

async with ClaudeSDKClient(options=options) as client:
    await client.query("Use the custom tool with parameter 'test'")
    async for msg in client.receive_response():
        print(msg)
```

---

## Tool Integration Patterns

### Multi-Tool Workflows

**Pattern 1: Sequential Tool Chain**:
```python
options = ClaudeAgentOptions(
    allowed_tools=["Read", "Grep", "Write"],
    permission_mode='acceptEdits'
)

async with ClaudeSDKClient(options=options) as client:
    await client.query("""
    1. Search for all TODO comments in Python files
    2. Read the files containing TODOs
    3. Create a todo_summary.md file with findings
    """)
    async for msg in client.receive_response():
        print(msg)
```

**Pattern 2: Parallel Tool Execution**:
```python
# Claude automatically parallelizes independent tool calls
await client.query("""
Analyze the codebase:
- Find all Python files
- Search for security issues
- Check for performance bottlenecks
""")
# Results in parallel: Glob + Grep + Grep
```

### Tool Permission Strategies

**Ask Mode** (Maximum Control):
```python
options = ClaudeAgentOptions(
    allowed_tools=["Read", "Write", "Bash"],
    permission_mode='ask'  # Prompt for every tool use
)
```

**Accept Edits** (File Operations Only):
```python
options = ClaudeAgentOptions(
    allowed_tools=["Read", "Write", "Edit"],
    permission_mode='acceptEdits'  # Auto-approve file edits
)
```

**Accept All** (Full Automation):
```python
options = ClaudeAgentOptions(
    allowed_tools=["Read", "Write", "Bash", "WebFetch"],
    permission_mode='acceptAll'  # Auto-approve everything (use with caution)
)
```

### Tool Allowlist Configuration

**Selective Tool Access**:
```python
# Only allow specific tools
options = ClaudeAgentOptions(
    allowed_tools=[
        "Read",                      # Built-in: Read files
        "Grep",                      # Built-in: Search
        "mcp__github__create_issue", # MCP: GitHub
        "mcp__custom__analyze"       # MCP: Custom tool
    ]
)
```

**Tool Wildcards**:
```python
# Allow all tools from specific MCP server
options = ClaudeAgentOptions(
    allowed_tools=[
        "Read",
        "Write",
        "mcp__github__*"  # All GitHub MCP tools
    ]
)
```

### Hook-Based Tool Control

**Pre-Tool Validation**:
```python
from claude_agent_sdk import HookMatcher

async def validate_bash(input_data, tool_use_id, context):
    if input_data["tool_name"] != "Bash":
        return {}

    command = input_data["tool_input"].get("command", "")

    # Block dangerous commands
    if any(danger in command for danger in ["rm -rf", "mkfs", ":()"]):
        return {
            "hookSpecificOutput": {
                "permissionDecision": "deny",
                "permissionDecisionReason": f"Blocked dangerous command"
            }
        }

    return {}

options = ClaudeAgentOptions(
    allowed_tools=["Bash"],
    hooks={
        "PreToolUse": [HookMatcher(matcher="Bash", hooks=[validate_bash])]
    }
)
```

**Post-Tool Logging**:
```python
async def log_tool_use(input_data, tool_use_id, context):
    print(f"Tool used: {input_data['tool_name']}")
    print(f"Arguments: {input_data['tool_input']}")
    return {}

options = ClaudeAgentOptions(
    hooks={
        "PostToolUse": [HookMatcher(matcher="*", hooks=[log_tool_use])]
    }
)
```

### Combined Built-in and MCP Tools

**Example: Enhanced Code Analysis**:
```python
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool("complexity_analysis", "Analyze code complexity", {"file_path": str})
async def analyze_complexity(args):
    # Custom complexity analysis logic
    return {"content": [{"type": "text", "text": "Complexity: Medium"}]}

custom_server = create_sdk_mcp_server(
    name="analysis",
    version="1.0.0",
    tools=[analyze_complexity]
)

options = ClaudeAgentOptions(
    allowed_tools=[
        "Read",                           # Read files
        "Grep",                           # Search code
        "mcp__github__list_issues",       # GitHub issues
        "mcp__analysis__complexity_analysis"  # Custom analysis
    ],
    mcp_servers={
        "analysis": custom_server,
        "github": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-github"],
            "env": {"GITHUB_TOKEN": "token"}
        }
    }
)

async with ClaudeSDKClient(options=options) as client:
    await client.query("""
    Analyze the codebase:
    1. Find complex functions with Grep
    2. Analyze complexity with custom tool
    3. Check if there are related GitHub issues
    """)
    async for msg in client.receive_response():
        print(msg)
```

---

## References

[^1]: Claude Docs. "Python SDK Reference - Built-in Tools." Tool Documentation, 2025. https://docs.claude.com/en/docs/claude-code/sdk/sdk-python
[^2]: eesel AI. "A Practical Guide to the Python Claude Code SDK." Edit Tool Best Practices, 2025. https://www.eesel.ai/blog/python-claude-code-sdk
[^3]: PromptLayer. "Building Agents with Claude Code's SDK." Security Considerations, 2025. https://blog.promptlayer.com/building-agents-with-claude-codes-sdk/
[^4]: GitHub. "Claude Agent SDK Python Examples." Custom Tools, 2025. https://github.com/anthropics/claude-agent-sdk-python/tree/main/examples
[^5]: Model Context Protocol. "MCP Specification." Protocol Documentation, 2025. https://modelcontextprotocol.io/docs/spec
[^6]: GitHub. "Model Context Protocol Servers." Server Registry, 2025. https://github.com/modelcontextprotocol/servers
[^7]: Model Context Protocol. "Building MCP Servers." Developer Guide, 2025. https://modelcontextprotocol.io/docs/guides/building-servers

[**→ Complete Bibliography**](references.md)

[← Back to Index](index.md)
