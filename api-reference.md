# API Reference - Claude Agent SDK

> **Complete API documentation for all functions, classes, and types**

[← Back to Index](INDEX.md)

---

## Table of Contents

1. [Core Functions](#core-functions)
2. [Classes](#classes)
3. [Decorators](#decorators)
4. [Type Definitions](#type-definitions)
5. [Error Handling](#error-handling)

---

## Core Functions

### `query()`

Creates a new session for each interaction. Simple async function for one-off queries.[^1]

**Signature**:
```python
async def query(
    prompt: str,
    options: ClaudeAgentOptions = None
) -> AsyncIterator[str]
```

**Parameters**:
- `prompt` (str): The user's prompt or question
- `options` (ClaudeAgentOptions, optional): Configuration options

**Returns**: AsyncIterator[str] - Stream of response messages

**Note**: Does NOT support tools by default. Use `ClaudeSDKClient` for tool support.[^1]

**Example**:
```python
import anyio
from claude_agent_sdk import query

async def main():
    async for message in query(prompt="What is 2 + 2?"):
        print(message)

anyio.run(main)
```

**With Options**:
```python
from claude_agent_sdk import query, ClaudeAgentOptions

options = ClaudeAgentOptions(
    system_prompt="You are a helpful assistant",
    max_tokens=1024
)

async for msg in query("Explain Python", options=options):
    print(msg)
```

---

### `create_sdk_mcp_server()`

Creates an in-process MCP server for custom tools.[^2]

**Signature**:
```python
def create_sdk_mcp_server(
    name: str,
    version: str,
    tools: list[Callable]
) -> MCPServer
```

**Parameters**:
- `name` (str): Unique server identifier
- `version` (str): Server version (semantic versioning)
- `tools` (list[Callable]): List of `@tool` decorated functions

**Returns**: MCPServer instance

**Example**:
```python
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool("greet", "Greet a user", {"name": str})
async def greet_user(args):
    return {
        "content": [{"type": "text", "text": f"Hello, {args['name']}!"}]
    }

server = create_sdk_mcp_server(
    name="my-tools",
    version="1.0.0",
    tools=[greet_user]
)
```

---

## Classes

### `ClaudeSDKClient`

Maintains conversation session across multiple exchanges.[^1]

**Signature**:
```python
class ClaudeSDKClient:
    def __init__(self, options: ClaudeAgentOptions = None)
    async def query(self, prompt: str) -> None
    async def receive_response(self) -> AsyncIterator[str]
    async def stop(self) -> None
```

**Usage Pattern**:
```python
async with ClaudeSDKClient(options=options) as client:
    await client.query("Your prompt here")
    async for msg in client.receive_response():
        print(msg)
```

#### Methods

**`__init__(options: ClaudeAgentOptions = None)`**

Initialize client with optional configuration.

**Parameters**:
- `options` (ClaudeAgentOptions, optional): Configuration settings

**`async query(prompt: str) -> None`**

Send a query to Claude.

**Parameters**:
- `prompt` (str): User's question or instruction

**Returns**: None (use `receive_response()` to get output)

**`async receive_response() -> AsyncIterator[str]`**

Receive streaming responses from Claude.

**Returns**: AsyncIterator[str] - Stream of response messages

**`async stop() -> None`**

Stop current execution.

**Returns**: None

#### Context Manager

**Required Pattern**:
```python
async with ClaudeSDKClient(options=options) as client:
    # Use client here
    pass
# Automatic cleanup on exit
```

#### Example: Multi-Turn Conversation

```python
from claude_agent_sdk import ClaudeSDKClient

async def conversation():
    async with ClaudeSDKClient() as client:
        # Turn 1
        await client.query("What's the capital of France?")
        async for msg in client.receive_response():
            print(msg)

        # Turn 2 (context preserved)
        await client.query("What's the population?")
        async for msg in client.receive_response():
            print(msg)
```

---

### `ClaudeAgentOptions`

Configuration dataclass for Claude Agent queries.

**Signature**:
```python
@dataclass
class ClaudeAgentOptions:
    # Model Settings
    model: str = "claude-sonnet-4-5-20250929"
    max_tokens: int = 8192

    # Behavior
    system_prompt: str = None
    max_turns: int = 100

    # Tools
    allowed_tools: list[str] = None
    mcp_servers: dict = None

    # Permissions
    permission_mode: str = 'ask'

    # Environment
    cwd: str = None

    # Hooks
    hooks: dict = None
```

#### Parameters

**Model Settings**:
- `model` (str): Claude model identifier
  - Default: `"claude-sonnet-4-5-20250929"`
  - Options: `"claude-opus-4"`, `"claude-haiku-4"`
- `max_tokens` (int): Maximum response length
  - Default: `8192`
  - Range: 1 - 200000

**Behavior Settings**:
- `system_prompt` (str, optional): Custom system instructions
- `max_turns` (int): Maximum conversation turns
  - Default: `100`

**Tool Configuration**:
- `allowed_tools` (list[str], optional): Tool names Claude can use
  - Built-in: `["Read", "Write", "Bash", "Grep", "Glob", "WebFetch"]`
  - MCP: `["mcp__<server>__<tool>"]`
- `mcp_servers` (dict, optional): MCP server configurations
  - Key: Server name
  - Value: Server instance or config dict

**Permission Modes**:
- `permission_mode` (str): Tool execution permissions
  - `'ask'`: Prompt user for each tool (default)
  - `'acceptEdits'`: Auto-accept file edits only
  - `'acceptAll'`: Auto-accept all tool uses (use with caution)

**Environment**:
- `cwd` (str, optional): Working directory for file operations
  - Default: Current directory

**Hooks**:
- `hooks` (dict, optional): Event handler configuration
  - Key: Hook event type
  - Value: List of HookMatcher instances

#### Example: Complete Configuration

```python
from claude_agent_sdk import ClaudeAgentOptions

options = ClaudeAgentOptions(
    # Model
    model="claude-sonnet-4-5-20250929",
    max_tokens=4096,

    # Behavior
    system_prompt="You are an expert Python developer",
    max_turns=50,

    # Tools
    allowed_tools=["Read", "Write", "Bash", "mcp__mytools__greet"],
    mcp_servers={"mytools": my_server},

    # Permissions
    permission_mode='acceptEdits',

    # Environment
    cwd="/path/to/project",

    # Hooks
    hooks={
        "PreToolUse": [HookMatcher(matcher="Bash", hooks=[safety_check])]
    }
)
```

---

### `HookMatcher`

Matches hook events to handler functions.

**Signature**:
```python
class HookMatcher:
    matcher: str
    hooks: list[Callable]
```

**Parameters**:
- `matcher` (str): Tool name to match ("*" for all)
- `hooks` (list[Callable]): Hook handler functions

**Example**:
```python
from claude_agent_sdk import HookMatcher

async def my_hook(input_data, tool_use_id, context):
    # Hook logic
    return {}

matcher = HookMatcher(
    matcher="Bash",
    hooks=[my_hook]
)
```

---

## Decorators

### `@tool`

Decorator for defining custom tools.

**Signature**:
```python
def tool(
    name: str,
    description: str,
    schema: dict
) -> Callable
```

**Parameters**:
- `name` (str): Unique tool identifier
- `description` (str): Plain English description for Claude
- `schema` (dict): Input parameter schema
  - Key: Parameter name
  - Value: Type (str, int, bool, float, list, dict)

**Returns**: Decorator function

**Decorated Function Signature**:
```python
async def tool_function(args: dict) -> dict:
    # Implementation
    return {
        "content": [
            {"type": "text", "text": "Result"}
        ]
    }
```

**Return Format**:
- `content` (list): Array of content blocks
  - `type` (str): "text" or other content types
  - `text` (str): Response text

**Optional Return Fields**:
- `isError` (bool): Indicates error condition

#### Example: Simple Tool

```python
from claude_agent_sdk import tool

@tool("calculate", "Perform calculations", {"expression": str})
async def calculate(args):
    result = eval(args["expression"])
    return {
        "content": [
            {"type": "text", "text": f"Result: {result}"}
        ]
    }
```

#### Example: Tool with Error Handling

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
            "isError": True
        }
```

#### Example: Complex Schema

```python
@tool(
    "search_database",
    "Search database with filters",
    {
        "query": str,
        "limit": int,
        "filters": dict,
        "sort_by": str
    }
)
async def search_database(args):
    results = db.search(
        query=args["query"],
        limit=args.get("limit", 10),
        filters=args.get("filters", {}),
        sort_by=args.get("sort_by", "relevance")
    )
    return {
        "content": [
            {"type": "text", "text": format_results(results)}
        ]
    }
```

---

## Type Definitions

### Hook Function Signature

```python
async def hook_function(
    input_data: dict,
    tool_use_id: str,
    context: dict
) -> dict
```

**Parameters**:
- `input_data` (dict): Tool input information
  - `tool_name` (str): Name of tool being called
  - `tool_input` (dict): Tool arguments
- `tool_use_id` (str): Unique tool use identifier
- `context` (dict): Additional context information

**Return Format** (to allow):
```python
return {}
```

**Return Format** (to deny):
```python
return {
    "hookSpecificOutput": {
        "hookEventName": "PreToolUse",
        "permissionDecision": "deny",
        "permissionDecisionReason": "Explanation here"
    }
}
```

### Hook Event Types

**Available Events**:
- `"PreToolUse"`: Before tool execution
- `"PostToolUse"`: After tool execution
- `"UserPromptSubmit"`: When user submits prompt
- `"Stop"`: When stopping execution
- `"SubagentStop"`: When subagent stops
- `"PreCompact"`: Before message compaction

**Not Supported in Python SDK**:[^3]
- `"SessionStart"`
- `"SessionEnd"`
- `"Notification"`

### Tool Naming Convention

**Built-in Tools**:
```python
"Read", "Write", "Bash", "Grep", "Glob", "WebFetch"
```

**MCP Tools**:
```python
"mcp__<server_name>__<tool_name>"

# Example:
"mcp__myserver__greet"
"mcp__database__query"
```

---

## Error Handling

### Common Exceptions

**APIError**:
```python
from claude_agent_sdk.errors import APIError

try:
    async for msg in query("Hello"):
        print(msg)
except APIError as e:
    print(f"API Error: {e}")
```

**AuthenticationError**:
```python
from claude_agent_sdk.errors import AuthenticationError

try:
    client = ClaudeSDKClient()
except AuthenticationError:
    print("Invalid API key")
```

**RateLimitError**:
```python
from claude_agent_sdk.errors import RateLimitError
import time

try:
    async for msg in query("Hello"):
        print(msg)
except RateLimitError:
    print("Rate limited, waiting...")
    time.sleep(60)
```

**ContextLengthExceededError**:
```python
from claude_agent_sdk.errors import ContextLengthExceededError

try:
    async for msg in query("Very long prompt..."):
        print(msg)
except ContextLengthExceededError:
    print("Context too long, use compaction")
```

### Error Handling Patterns

**Retry with Backoff**:
```python
import asyncio

async def query_with_retry(prompt, max_retries=3):
    for attempt in range(max_retries):
        try:
            async for msg in query(prompt):
                print(msg)
            break
        except RateLimitError:
            if attempt < max_retries - 1:
                wait_time = 2 ** attempt
                await asyncio.sleep(wait_time)
            else:
                raise
```

**Graceful Degradation**:
```python
async def safe_query(prompt):
    try:
        async with ClaudeSDKClient() as client:
            await client.query(prompt)
            async for msg in client.receive_response():
                yield msg
    except ContextLengthExceededError:
        # Fallback to simpler query
        options = ClaudeAgentOptions(max_tokens=1024)
        async for msg in query(prompt, options):
            yield msg
```

---

## Advanced Usage

### Multiple MCP Servers

```python
from claude_agent_sdk import (
    tool, create_sdk_mcp_server,
    ClaudeAgentOptions, ClaudeSDKClient
)

# Server 1: Database tools
@tool("query_db", "Query database", {"sql": str})
async def query_db(args):
    return {"content": [{"type": "text", "text": db.execute(args["sql"])}]}

db_server = create_sdk_mcp_server("database", "1.0.0", [query_db])

# Server 2: API tools
@tool("call_api", "Call external API", {"endpoint": str})
async def call_api(args):
    return {"content": [{"type": "text", "text": api.call(args["endpoint"])}]}

api_server = create_sdk_mcp_server("api", "1.0.0", [call_api])

# Use both servers
options = ClaudeAgentOptions(
    mcp_servers={
        "database": db_server,
        "api": api_server
    },
    allowed_tools=[
        "mcp__database__query_db",
        "mcp__api__call_api"
    ]
)
```

### Hook Chaining

```python
async def log_hook(input_data, tool_use_id, context):
    print(f"Tool called: {input_data['tool_name']}")
    return {}

async def safety_hook(input_data, tool_use_id, context):
    if is_dangerous(input_data):
        return {
            "hookSpecificOutput": {
                "permissionDecision": "deny",
                "permissionDecisionReason": "Unsafe operation"
            }
        }
    return {}

options = ClaudeAgentOptions(
    hooks={
        "PreToolUse": [
            HookMatcher(matcher="*", hooks=[log_hook, safety_hook])
        ]
    }
)
```

### Session State Management

```python
class StatefulClient:
    def __init__(self):
        self.client = None
        self.history = []

    async def __aenter__(self):
        self.client = ClaudeSDKClient()
        await self.client.__aenter__()
        return self

    async def __aexit__(self, *args):
        await self.client.__aexit__(*args)

    async def query(self, prompt):
        self.history.append({"role": "user", "content": prompt})
        await self.client.query(prompt)

        response = []
        async for msg in self.client.receive_response():
            response.append(msg)

        self.history.append({"role": "assistant", "content": "".join(response)})
        return response

# Usage
async with StatefulClient() as client:
    await client.query("Hello")
    print(client.history)  # Access conversation history
```

---

## References

[^1]: Claude Docs. "Python SDK Reference." API Documentation, 2025. https://docs.claude.com/en/docs/claude-code/sdk/sdk-python
[^2]: eesel AI. "A Practical Guide to the Python Claude Code SDK." Custom Tools, 2025. https://www.eesel.ai/blog/python-claude-code-sdk
[^3]: PromptLayer. "Building Agents with Claude Code's SDK." Hooks Documentation, 2025. https://blog.promptlayer.com/building-agents-with-claude-codes-sdk/

[**→ Complete Bibliography**](references.md)

[← Back to Index](INDEX.md)
