# API Reference - Claude Agent SDK (Python)

> **Complete API documentation for all functions, classes, and types with SuperClaude framework integration**

[← Back to Index](index.md) | [SuperClaude Integration Guide](../SDK_Python.md)

---

## Table of Contents

1. [Core Functions](#core-functions)
   - [query()](#query)
   - [tool()](#tool)
   - [create_sdk_mcp_server()](#create_sdk_mcp_server)
2. [Classes](#classes)
   - [ClaudeSDKClient](#claudesdkclient)
3. [Type Definitions](#type-definitions)
   - [ClaudeAgentOptions](#claudeagentoptions)
   - [SystemPromptPreset](#systempromptpreset)
   - [SettingSource](#settingsource)
   - [AgentDefinition](#agentdefinition)
   - [PermissionMode](#permissionmode)
   - [Message Types](#message-types)
   - [MCP Server Configs](#mcp-server-configs)
4. [Hook System](#hook-system)
5. [Error Types](#error-types)
6. [Tool Input/Output Schemas](#tool-inputoutput-schemas)

---

## Core Functions

### `query()`

**Creates a new session for each interaction.** Returns an async iterator that yields messages as they arrive. Each call to `query()` starts fresh with no memory of previous interactions.

**Signature**:
```python
async def query(
    *,
    prompt: str | AsyncIterable[dict[str, Any]],
    options: ClaudeAgentOptions | None = None
) -> AsyncIterator[Message]
```

**Parameters**:
- `prompt` (str | AsyncIterable[dict]): The input prompt as a string or async iterable for streaming mode
- `options` (ClaudeAgentOptions | None): Optional configuration object (defaults to `ClaudeAgentOptions()` if None)

**Returns**: `AsyncIterator[Message]` - Yields messages from the conversation

**When to Use**:
- ✅ One-off questions without conversation history
- ✅ Independent tasks without context requirements
- ✅ Simple automation scripts
- ✅ CI/CD pipelines
- ❌ Multi-turn conversations (use `ClaudeSDKClient`)
- ❌ Interactive applications (use `ClaudeSDKClient`)

**Basic Example**:
```python
import asyncio
from claude_agent_sdk import query

async def main():
    async for message in query(prompt="What is 2 + 2?"):
        print(message)

asyncio.run(main())
```

**With SuperClaude Framework Integration**:
```python
from claude_agent_sdk import query, ClaudeAgentOptions

async def framework_integrated_query():
    options = ClaudeAgentOptions(
        # Load CLAUDE.md instructions
        setting_sources=["project"],

        # Use Claude Code system prompt
        system_prompt={
            "type": "preset",
            "preset": "claude_code",
            "append": "--think-hard --token-efficient"  # Activate modes
        },

        # Configure tools
        allowed_tools=["Read", "Write", "Edit"],
        permission_mode="acceptEdits",

        # Set working directory
        cwd="/path/to/project"
    )

    async for message in query(
        prompt="Analyze authentication system",
        options=options
    ):
        print(message)
```

---

### `tool()`

**Decorator for defining MCP tools with type safety.**

**Signature**:
```python
def tool(
    name: str,
    description: str,
    input_schema: type | dict[str, Any]
) -> Callable[[Callable[[Any], Awaitable[dict[str, Any]]]], SdkMcpTool[Any]]
```

**Parameters**:
- `name` (str): Unique identifier for the tool
- `description` (str): Human-readable description of what the tool does
- `input_schema` (type | dict[str, Any]): Schema defining the tool's input parameters

**Input Schema Options**:

1. **Simple type mapping** (recommended):
   ```python
   {"text": str, "count": int, "enabled": bool}
   ```

2. **JSON Schema format** (for complex validation):
   ```python
   {
       "type": "object",
       "properties": {
           "text": {"type": "string"},
           "count": {"type": "integer", "minimum": 0}
       },
       "required": ["text"]
   }
   ```

**Returns**: A decorator function that wraps the tool implementation and returns an `SdkMcpTool` instance

**Basic Example**:
```python
from claude_agent_sdk import tool
from typing import Any

@tool("greet", "Greet a user", {"name": str})
async def greet(args: dict[str, Any]) -> dict[str, Any]:
    return {
        "content": [{
            "type": "text",
            "text": f"Hello, {args['name']}!"
        }]
    }
```

**SuperClaude Pattern Example**:
```python
from claude_agent_sdk import tool
import subprocess

# Tool following mcps/ dual-mode pattern
@tool("analyze_complexity", "Analyze code complexity", {"file_path": str})
async def analyze_complexity(args: dict[str, Any]) -> dict[str, Any]:
    """Matches mcps/TEMPLATE.py pattern from SuperClaude wiki"""

    file_path = args["file_path"]

    # Core logic (reusable by both SDK and CLI modes)
    result = subprocess.run(
        ["radon", "cc", file_path, "-s"],
        capture_output=True,
        text=True
    )

    return {
        "content": [{
            "type": "text",
            "text": f"Complexity Analysis:\n{result.stdout}"
        }]
    }
```

---

### `create_sdk_mcp_server()`

**Create an in-process MCP server that runs within your Python application.**

**Signature**:
```python
def create_sdk_mcp_server(
    name: str,
    version: str = "1.0.0",
    tools: list[SdkMcpTool[Any]] | None = None
) -> McpSdkServerConfig
```

**Parameters**:
- `name` (str): Unique identifier for the server
- `version` (str): Server version string (default: "1.0.0")
- `tools` (list[SdkMcpTool[Any]] | None): List of tool functions created with `@tool` decorator

**Returns**: `McpSdkServerConfig` object that can be passed to `ClaudeAgentOptions.mcp_servers`

**Example**:
```python
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool("add", "Add two numbers", {"a": float, "b": float})
async def add(args):
    return {
        "content": [{
            "type": "text",
            "text": f"Sum: {args['a'] + args['b']}"
        }]
    }

@tool("multiply", "Multiply two numbers", {"a": float, "b": float})
async def multiply(args):
    return {
        "content": [{
            "type": "text",
            "text": f"Product: {args['a'] * args['b']}"
        }]
    }

# Create SDK MCP server
calculator = create_sdk_mcp_server(
    name="calculator",
    version="2.0.0",
    tools=[add, multiply]
)

# Use with Claude
from claude_agent_sdk import ClaudeAgentOptions

options = ClaudeAgentOptions(
    mcp_servers={"calc": calculator},
    allowed_tools=["mcp__calc__add", "mcp__calc__multiply"]
)
```

**SuperClaude Integration Pattern**:
```python
from claude_agent_sdk import tool, create_sdk_mcp_server, ClaudeAgentOptions

# SDK server (in-process)
@tool("validate_security", "Security validation", {"code": str})
async def validate_security(args):
    # Implementation
    return {"content": [{"type": "text", "text": "Security check passed"}]}

sdk_server = create_sdk_mcp_server("security", tools=[validate_security])

# Combined with stdio MCP servers from SuperClaude wiki
options = ClaudeAgentOptions(
    mcp_servers={
        "security": sdk_server,  # SDK server (in-process)
        "readfiles": {           # Stdio server (mcps/readfiles.py)
            "type": "stdio",
            "command": "conda",
            "args": ["run", "-n", "mcp-claude", "python",
                     "C:\\Users\\ELI\\.claude\\mcps\\readfiles.py", "--server"]
        }
    },
    allowed_tools=[
        "mcp__security__validate_security",
        "mcp__readfiles__read_files"
    ]
)
```

---

## Classes

### `ClaudeSDKClient`

**Maintains a conversation session across multiple exchanges.** This is the Python equivalent of how the TypeScript SDK's `query()` function works internally.

**Key Features**:
- ✅ Session Continuity: Maintains conversation context
- ✅ Same Conversation: Claude remembers previous messages
- ✅ Interrupt Support: Can stop Claude mid-execution
- ✅ Explicit Lifecycle: You control when session starts/ends
- ✅ Response-driven Flow: React to responses and send follow-ups
- ✅ Custom Tools & Hooks: Supports custom tools and hooks

**Signature**:
```python
class ClaudeSDKClient:
    def __init__(self, options: ClaudeAgentOptions | None = None)
    async def connect(self, prompt: str | AsyncIterable[dict] | None = None) -> None
    async def query(self, prompt: str | AsyncIterable[dict], session_id: str = "default") -> None
    async def receive_messages(self) -> AsyncIterator[Message]
    async def receive_response(self) -> AsyncIterator[Message]
    async def interrupt(self) -> None
    async def disconnect(self) -> None
```

**Methods**:

| Method | Description |
|--------|-------------|
| `__init__(options)` | Initialize the client with optional configuration |
| `connect(prompt)` | Connect to Claude with an optional initial prompt or message stream |
| `query(prompt, session_id)` | Send a new request in streaming mode |
| `receive_messages()` | Receive all messages from Claude as an async iterator |
| `receive_response()` | Receive messages until and including a ResultMessage |
| `interrupt()` | Send interrupt signal (only works in streaming mode) |
| `disconnect()` | Disconnect from Claude |

**Context Manager Support**:
```python
async with ClaudeSDKClient() as client:
    await client.query("Hello Claude")
    async for message in client.receive_response():
        print(message)
```

> **Important**: When iterating over messages, avoid using `break` to exit early as this can cause asyncio cleanup issues. Instead, let the iteration complete naturally or use flags to track when you've found what you need.

**Multi-Turn Conversation Example**:
```python
import asyncio
from claude_agent_sdk import ClaudeSDKClient, AssistantMessage, TextBlock

async def continuous_conversation():
    async with ClaudeSDKClient() as client:
        # Turn 1
        await client.query("What's the capital of France?")
        async for message in client.receive_response():
            if isinstance(message, AssistantMessage):
                for block in message.content:
                    if isinstance(block, TextBlock):
                        print(f"Claude: {block.text}")

        # Turn 2 - Claude remembers context
        await client.query("What's the population of that city?")
        async for message in client.receive_response():
            if isinstance(message, AssistantMessage):
                for block in message.content:
                    if isinstance(block, TextBlock):
                        print(f"Claude: {block.text}")

asyncio.run(continuous_conversation())
```

**SuperClaude Task Management Pattern**:
```python
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions

async def task_management_session():
    """Multi-session task workflow (see MODE_Task_Management.md)"""

    options = ClaudeAgentOptions(
        mcp_servers={"serena": {...}},  # For memory persistence
        allowed_tools=["TodoWrite", "Task", "Read", "Write"],
        permission_mode="acceptEdits",
        setting_sources=["project"]  # Load CLAUDE.md
    )

    async with ClaudeSDKClient(options=options) as client:
        # Session 1: Planning
        await client.query("Plan authentication system implementation")
        async for message in client.receive_response():
            pass  # TodoWrite creates task hierarchy

        # Session 2: Implementation (continues context)
        await client.query("Implement first phase from plan")
        # Claude remembers the plan from Session 1
```

**Streaming Input Example**:
```python
async def message_stream():
    """Generate messages dynamically"""
    yield {"type": "text", "text": "Analyze the following data:"}
    await asyncio.sleep(0.5)
    yield {"type": "text", "text": "Temperature: 25°C"}
    await asyncio.sleep(0.5)
    yield {"type": "text", "text": "Humidity: 60%"}

async def main():
    async with ClaudeSDKClient() as client:
        await client.query(message_stream())
        async for message in client.receive_response():
            print(message)
```

**Using Interrupts**:
```python
async def interruptible_task():
    options = ClaudeAgentOptions(
        allowed_tools=["Bash"],
        permission_mode="acceptEdits"
    )

    async with ClaudeSDKClient(options=options) as client:
        # Start long-running task
        await client.query("Count from 1 to 100 slowly")

        # Let it run for a bit
        await asyncio.sleep(2)

        # Interrupt the task
        await client.interrupt()
        print("Task interrupted!")

        # Send new command
        await client.query("Just say hello instead")
        async for message in client.receive_response():
            pass
```

---

## Type Definitions

### `ClaudeAgentOptions`

**Configuration dataclass for Claude Code queries with SuperClaude framework integration.**

```python
@dataclass
class ClaudeAgentOptions:
    # Tool Control
    allowed_tools: list[str] = field(default_factory=list)
    disallowed_tools: list[str] = field(default_factory=list)

    # System Behavior
    system_prompt: str | SystemPromptPreset | None = None
    permission_mode: PermissionMode | None = None

    # MCP Integration
    mcp_servers: dict[str, McpServerConfig] | str | Path = field(default_factory=dict)

    # Session Management
    continue_conversation: bool = False
    resume: str | None = None
    fork_session: bool = False
    max_turns: int | None = None

    # Advanced Control
    can_use_tool: CanUseTool | None = None
    hooks: dict[HookEvent, list[HookMatcher]] | None = None
    agents: dict[str, AgentDefinition] | None = None
    setting_sources: list[SettingSource] | None = None

    # Environment
    model: str | None = None
    cwd: str | Path | None = None
    env: dict[str, str] = field(default_factory=dict)
    add_dirs: list[str | Path] = field(default_factory=list)

    # Output Control
    include_partial_messages: bool = False
    max_buffer_size: int | None = None
    stderr: Callable[[str], None] | None = None

    # CLI Integration
    settings: str | None = None
    permission_prompt_tool_name: str | None = None
    extra_args: dict[str, str | None] = field(default_factory=dict)
```

**Key Parameters**:

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `allowed_tools` | `list[str]` | `[]` | List of allowed tool names |
| `system_prompt` | `str \| SystemPromptPreset \| None` | `None` | System prompt configuration |
| `mcp_servers` | `dict[str, McpServerConfig] \| str \| Path` | `{}` | MCP server configurations |
| `permission_mode` | `PermissionMode \| None` | `None` | Permission mode for tool usage |
| `setting_sources` | `list[SettingSource] \| None` | `None` | Which filesystem settings to load |
| `agents` | `dict[str, AgentDefinition] \| None` | `None` | Programmatically defined subagents |
| `can_use_tool` | `CanUseTool \| None` | `None` | Tool permission callback function |
| `hooks` | `dict[HookEvent, list[HookMatcher]] \| None` | `None` | Hook configurations |

**SuperClaude Framework Configuration Examples**:

```python
# MODE Activation
options = ClaudeAgentOptions(
    system_prompt={
        "type": "preset",
        "preset": "claude_code",
        "append": "--brainstorm --think-hard --introspect"
    }
)

# MCP Server Ecosystem (from SuperClaude wiki)
options = ClaudeAgentOptions(
    mcp_servers={
        "sequential": {...},  # MCP_Sequential.md
        "context7": {...},    # MCP_Context7.md
        "magic": {...},       # MCP_Magic.md
        "playwright": {...}   # MCP_Playwright.md
    },
    allowed_tools=[
        "mcp__sequential__sequentialthinking",
        "mcp__context7__get_library_docs",
        "mcp__magic__21st_magic_component_builder"
    ]
)

# RULES.md Compliance
async def safety_handler(tool_name: str, input_data: dict, context: dict):
    """Implement RULES.md safety patterns"""
    if tool_name == "Bash" and "rm -rf" in input_data.get("command", ""):
        return {
            "behavior": "deny",
            "message": "Dangerous command blocked (RULES.md)"
        }
    return {"behavior": "allow", "updatedInput": input_data}

options = ClaudeAgentOptions(can_use_tool=safety_handler)

# CLAUDE.md Project Instructions
options = ClaudeAgentOptions(
    setting_sources=["project"],  # Loads .claude/settings.json and CLAUDE.md
    system_prompt={"type": "preset", "preset": "claude_code"}
)
```

---

### `SystemPromptPreset`

**Configuration for using Claude Code's preset system prompt with optional additions.**

```python
class SystemPromptPreset(TypedDict):
    type: Literal["preset"]
    preset: Literal["claude_code"]
    append: NotRequired[str]
```

| Field | Required | Description |
|-------|----------|-------------|
| `type` | Yes | Must be `"preset"` to use a preset system prompt |
| `preset` | Yes | Must be `"claude_code"` to use Claude Code's system prompt |
| `append` | No | Additional instructions to append to the preset |

**Examples**:
```python
# Use Claude Code preset
system_prompt = {
    "type": "preset",
    "preset": "claude_code"
}

# Extend with custom instructions
system_prompt = {
    "type": "preset",
    "preset": "claude_code",
    "append": "Focus on Python best practices and type safety"
}

# Activate SuperClaude modes
system_prompt = {
    "type": "preset",
    "preset": "claude_code",
    "append": "--introspect --task-manage --think-hard"
}
```

---

### `SettingSource`

**Controls which filesystem-based configuration sources the SDK loads settings from.**

```python
SettingSource = Literal["user", "project", "local"]
```

| Value | Description | Location |
|-------|-------------|----------|
| `"user"` | Global user settings | `~/.claude/settings.json` |
| `"project"` | Shared project settings (version controlled) | `.claude/settings.json` |
| `"local"` | Local project settings (gitignored) | `.claude/settings.local.json` |

**Default Behavior**: When `setting_sources` is **omitted** or **`None`**, the SDK does **not** load any filesystem settings.

**Important**: Must include `"project"` to load CLAUDE.md files.

**Examples**:
```python
# Load all settings (legacy behavior)
options = ClaudeAgentOptions(
    setting_sources=["user", "project", "local"]
)

# Load only project settings
options = ClaudeAgentOptions(
    setting_sources=["project"]  # Only .claude/settings.json
)

# Load CLAUDE.md instructions
options = ClaudeAgentOptions(
    setting_sources=["project"],  # Required for CLAUDE.md
    system_prompt={"type": "preset", "preset": "claude_code"}
)

# SDK-only (no filesystem dependencies)
options = ClaudeAgentOptions(
    # setting_sources=None is the default
    agents={...},
    mcp_servers={...}
)
```

**Settings Precedence** (highest to lowest):
1. Local settings (`.claude/settings.local.json`)
2. Project settings (`.claude/settings.json`)
3. User settings (`~/.claude/settings.json`)

Programmatic options always override filesystem settings.

---

### `AgentDefinition`

**Configuration for a subagent defined programmatically.**

```python
@dataclass
class AgentDefinition:
    description: str
    prompt: str
    tools: list[str] | None = None
    model: Literal["sonnet", "opus", "haiku", "inherit"] | None = None
```

| Field | Required | Description |
|-------|----------|-------------|
| `description` | Yes | Natural language description of when to use this agent |
| `prompt` | Yes | The agent's system prompt |
| `tools` | No | Array of allowed tool names. If omitted, inherits all tools |
| `model` | No | Model override for this agent. If omitted, uses the main model |

**Example**:
```python
options = ClaudeAgentOptions(
    agents={
        "security-analyst": AgentDefinition(
            description="Security vulnerability analysis",
            prompt="Expert security engineer. See PRINCIPLES.md for standards.",
            tools=["Read", "Grep", "Glob"],
            model="sonnet"
        ),
        "performance-optimizer": AgentDefinition(
            description="Performance optimization specialist",
            prompt="Apply MODE_Orchestration patterns for efficiency.",
            tools=["Read", "Bash", "Edit"],
            model="haiku"
        )
    }
)
```

---

### `PermissionMode`

**Permission modes for controlling tool execution.**

```python
PermissionMode = Literal[
    "default",           # Standard permission behavior
    "acceptEdits",       # Auto-accept file edits
    "plan",              # Planning mode - no execution
    "bypassPermissions"  # Bypass all permission checks (use with caution)
]
```

**Examples**:
```python
# Production: Strict validation
prod_options = ClaudeAgentOptions(
    permission_mode="default",
    can_use_tool=safety_handler
)

# Development: Fast iteration
dev_options = ClaudeAgentOptions(
    permission_mode="acceptEdits"
)

# Planning: Safe exploration
plan_options = ClaudeAgentOptions(
    permission_mode="plan"
)

# CI/CD: Automated execution
ci_options = ClaudeAgentOptions(
    permission_mode="bypassPermissions"
)
```

---

### Message Types

Complete message type system for handling SDK responses.

#### `Message` - Union Type
```python
Message = UserMessage | AssistantMessage | SystemMessage | ResultMessage
```

#### `UserMessage`
```python
@dataclass
class UserMessage:
    content: str | list[ContentBlock]
```

#### `AssistantMessage`
```python
@dataclass
class AssistantMessage:
    content: list[ContentBlock]
    model: str
```

#### `SystemMessage`
```python
@dataclass
class SystemMessage:
    subtype: str
    data: dict[str, Any]
```

#### `ResultMessage`
```python
@dataclass
class ResultMessage:
    subtype: str
    duration_ms: int
    duration_api_ms: int
    is_error: bool
    num_turns: int
    session_id: str
    total_cost_usd: float | None = None
    usage: dict[str, Any] | None = None
    result: str | None = None
```

**Content Block Types**:
```python
ContentBlock = TextBlock | ThinkingBlock | ToolUseBlock | ToolResultBlock

@dataclass
class TextBlock:
    text: str

@dataclass
class ThinkingBlock:
    thinking: str
    signature: str

@dataclass
class ToolUseBlock:
    id: str
    name: str
    input: dict[str, Any]

@dataclass
class ToolResultBlock:
    tool_use_id: str
    content: str | list[dict[str, Any]] | None = None
    is_error: bool | None = None
```

---

### MCP Server Configs

**Union type for MCP server configurations.**

```python
McpServerConfig = McpStdioServerConfig | McpSSEServerConfig | McpHttpServerConfig | McpSdkServerConfig
```

#### `McpStdioServerConfig`
```python
class McpStdioServerConfig(TypedDict):
    type: NotRequired[Literal["stdio"]]
    command: str
    args: NotRequired[list[str]]
    env: NotRequired[dict[str, str]]
```

#### `McpSSEServerConfig`
```python
class McpSSEServerConfig(TypedDict):
    type: Literal["sse"]
    url: str
    headers: NotRequired[dict[str, str]]
```

#### `McpHttpServerConfig`
```python
class McpHttpServerConfig(TypedDict):
    type: Literal["http"]
    url: str
    headers: NotRequired[dict[str, str]]
```

#### `McpSdkServerConfig`
```python
class McpSdkServerConfig(TypedDict):
    type: Literal["sdk"]
    name: str
    instance: Any  # MCP Server instance
```

---

## Hook System

Complete hook system for behavior modification.

### `HookEvent`

**Supported hook event types.**

```python
HookEvent = Literal[
    "PreToolUse",       # Called before tool execution
    "PostToolUse",      # Called after tool execution
    "UserPromptSubmit", # Called when user submits a prompt
    "Stop",             # Called when stopping execution
    "SubagentStop",     # Called when a subagent stops
    "PreCompact"        # Called before message compaction
]
```

> **Note**: Due to setup limitations, the Python SDK does not support SessionStart, SessionEnd, and Notification hooks.

### `HookCallback`

**Type definition for hook callback functions.**

```python
HookCallback = Callable[
    [dict[str, Any], str | None, HookContext],
    Awaitable[dict[str, Any]]
]
```

**Parameters**:
- `input_data`: Hook-specific input data
- `tool_use_id`: Optional tool use identifier (for tool-related hooks)
- `context`: Hook context with additional information

**Returns**: Dictionary that may contain:
- `decision`: `"block"` to block the action
- `systemMessage`: System message to add to the transcript
- `hookSpecificOutput`: Hook-specific output data

### `HookContext`

```python
@dataclass
class HookContext:
    signal: Any | None = None  # Future: abort signal support
```

### `HookMatcher`

```python
@dataclass
class HookMatcher:
    matcher: str | None = None        # Tool name or pattern (e.g., "Bash", "Write|Edit")
    hooks: list[HookCallback] = field(default_factory=list)
```

**Example - RULES.md Enforcement**:
```python
from claude_agent_sdk import ClaudeAgentOptions, HookMatcher

async def enforce_safety(input_data, tool_use_id, context):
    """Implement RULES.md safety rules via hooks"""
    tool_name = input_data.get('tool_name')

    if tool_name == "Bash":
        cmd = input_data.get('tool_input', {}).get('command', '')
        if 'push --force' in cmd and 'main' in cmd:
            return {
                'hookSpecificOutput': {
                    'hookEventName': 'PreToolUse',
                    'permissionDecision': 'deny',
                    'permissionDecisionReason': 'Never force push to main (RULES.md)'
                }
            }
    return {}

options = ClaudeAgentOptions(
    hooks={
        'PreToolUse': [
            HookMatcher(matcher='Bash', hooks=[enforce_safety])
        ]
    }
)
```

---

## Error Types

### Error Hierarchy
```python
ClaudeSDKError (Base)
├── CLIConnectionError
│   └── CLINotFoundError
├── ProcessError
└── CLIJSONDecodeError
```

### `ClaudeSDKError`
```python
class ClaudeSDKError(Exception):
    """Base error for Claude SDK."""
```

### `CLINotFoundError`
```python
class CLINotFoundError(CLIConnectionError):
    def __init__(self, message: str = "Claude Code not found", cli_path: str | None = None):
        self.cli_path = cli_path
```

### `CLIConnectionError`
```python
class CLIConnectionError(ClaudeSDKError):
    """Failed to connect to Claude Code."""
```

### `ProcessError`
```python
class ProcessError(ClaudeSDKError):
    def __init__(self, message: str, exit_code: int | None = None, stderr: str | None = None):
        self.exit_code = exit_code
        self.stderr = stderr
```

### `CLIJSONDecodeError`
```python
class CLIJSONDecodeError(ClaudeSDKError):
    def __init__(self, line: str, original_error: Exception):
        self.line = line
        self.original_error = original_error
```

**Error Handling Example**:
```python
from claude_agent_sdk import (
    query,
    CLINotFoundError,
    ProcessError,
    CLIJSONDecodeError
)

try:
    async for message in query(prompt="Analyze code"):
        print(message)
except CLINotFoundError as e:
    print(f"Install Claude Code: npm install -g @anthropic-ai/claude-code")
    print(f"Path searched: {e.cli_path}")
except ProcessError as e:
    print(f"Process failed: {e.exit_code}")
    print(f"Error output: {e.stderr}")
except CLIJSONDecodeError as e:
    print(f"Parse error on line: {e.line}")
```

---

## Tool Input/Output Schemas

Documentation of input/output schemas for all built-in Claude Code tools.

### Task
**Tool name**: `Task`

**Input**:
```python
{
    "description": str,      # Short (3-5 word) description
    "prompt": str,           # Task for the agent to perform
    "subagent_type": str     # Type of specialized agent to use
}
```

**Output**:
```python
{
    "result": str,
    "usage": dict | None,
    "total_cost_usd": float | None,
    "duration_ms": int | None
}
```

### Read
**Tool name**: `Read`

**Input**:
```python
{
    "file_path": str,       # Absolute path to file
    "offset": int | None,   # Line number to start from
    "limit": int | None     # Number of lines to read
}
```

**Output (Text)**:
```python
{
    "content": str,
    "total_lines": int,
    "lines_returned": int
}
```

**Output (Images)**:
```python
{
    "image": str,        # Base64 encoded
    "mime_type": str,
    "file_size": int
}
```

### Write
**Tool name**: `Write`

**Input**:
```python
{
    "file_path": str,  # Absolute path
    "content": str
}
```

**Output**:
```python
{
    "message": str,
    "bytes_written": int,
    "file_path": str
}
```

### Edit
**Tool name**: `Edit`

**Input**:
```python
{
    "file_path": str,
    "old_string": str,
    "new_string": str,
    "replace_all": bool | None
}
```

**Output**:
```python
{
    "message": str,
    "replacements": int,
    "file_path": str
}
```

### Bash
**Tool name**: `Bash`

**Input**:
```python
{
    "command": str,
    "timeout": int | None,           # Max 600000ms
    "description": str | None,
    "run_in_background": bool | None
}
```

**Output**:
```python
{
    "output": str,
    "exitCode": int,
    "killed": bool | None,
    "shellId": str | None
}
```

### TodoWrite
**Tool name**: `TodoWrite`

**Input**:
```python
{
    "todos": [
        {
            "content": str,
            "status": "pending" | "in_progress" | "completed",
            "activeForm": str
        }
    ]
}
```

**Output**:
```python
{
    "message": str,
    "stats": {
        "total": int,
        "pending": int,
        "in_progress": int,
        "completed": int
    }
}
```

---

## See Also

**SuperClaude Framework**:
- [SDK_Python.md](../SDK_Python.md) - Complete SuperClaude integration guide
- [CLAUDE.md](../CLAUDE.md) - Architecture overview
- [MODE_Task_Management.md](../MODE_Task_Management.md) - Task patterns
- [MCP_Sequential.md](../MCP_Sequential.md) - Complex reasoning
- [RULES.md](../RULES.md) - Safety and compliance

**Official Documentation**:
- [Python SDK Guide](https://docs.claude.com/en/api/agent-sdk/python)
- [TypeScript SDK Reference](https://docs.claude.com/en/docs/claude-code/typescript-sdk-reference)
- [CLI Reference](https://docs.claude.com/en/docs/claude-code/cli-reference)
- [Common Workflows](https://docs.claude.com/en/docs/claude-code/common-workflows)

---

[← Back to Index](index.md) | [Getting Started →](getting-started.md)
