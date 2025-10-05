# Getting Started - Claude Agent SDK

> **Installation, setup, and first steps with SuperClaude framework integration**

[← Back to Documentation Index](index.md)

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [SuperClaude Framework Setup](#superclaude-framework-setup)
5. [Hello World Examples](#hello-world-examples)
6. [SuperClaude Integration Examples](#superclaude-integration-examples)
7. [Common Setup Issues](#common-setup-issues)

---

## Prerequisites

### System Requirements

**Python SDK**:
- **Python 3.10+** (explicitly required)[^1]
- pip package manager
- Virtual environment (recommended)
- Claude Code CLI 2.0.0+ (for full integration features)

**TypeScript SDK**:
- **Node.js 18+** (explicitly required)[^1]
- npm or yarn package manager
- Claude Code CLI 2.0.0+ (for full integration features)

**Optional**:
- Claude Code CLI (for local integration)[^2]
- Docker (for containerized deployments)

### API Access

**Anthropic API Key** (Required):
1. Sign up at [Claude Console](https://console.anthropic.com/)
2. Navigate to API Keys section
3. Create new API key
4. Copy and save securely

**Billing Setup**:
- Active billing required for API usage[^3]
- Pay-as-you-go pricing model
- Set spending limits in console

---

## Installation

```
                    Quick Start Workflow

    ┌───────────────────────────────────────────┐
    │  1. Prerequisites                         │
    │  ✓ Python 3.10+ or Node.js 18+          │
    │  ✓ Anthropic API Key                     │
    └──────────────┬────────────────────────────┘
                   │
                   ▼
    ┌───────────────────────────────────────────┐
    │  2. Install SDK                           │
    │  pip install claude-agent-sdk (Python)    │
    │  npm install claude-agent-sdk (TypeScript)│
    └──────────────┬────────────────────────────┘
                   │
                   ▼
    ┌───────────────────────────────────────────┐
    │  3. Configure API Key                     │
    │  export ANTHROPIC_API_KEY='sk-ant-...'   │
    └──────────────┬────────────────────────────┘
                   │
                   ▼
    ┌───────────────────────────────────────────┐
    │  4. Hello World                           │
    │  from claude_agent_sdk import query       │
    │  async for msg in query("Hello!"):        │
    │      print(msg)                           │
    └──────────────┬────────────────────────────┘
                   │
                   ▼
    ┌───────────────────────────────────────────┐
    │  5. Production Ready                      │
    │  ✓ Add tools & MCP servers               │
    │  ✓ Configure hooks & security            │
    │  ✓ Deploy & monitor                      │
    └───────────────────────────────────────────┘
```

### Python SDK

**Standard Installation**:
```bash
pip install claude-agent-sdk
```

**With Virtual Environment** (Recommended):
```bash
# Create virtual environment
python -m venv claude-env

# Activate (macOS/Linux)
source claude-env/bin/activate

# Activate (Windows)
claude-env\Scripts\activate

# Install SDK
pip install claude-agent-sdk
```

**Verify Installation**:
```python
import claude_agent_sdk
print(claude_agent_sdk.__version__)
```

### TypeScript SDK

**Standard Installation**:
```bash
npm install @anthropic-ai/claude-agent-sdk
```

**With Yarn**:
```bash
yarn add @anthropic-ai/claude-agent-sdk
```

**Verify Installation**:
```typescript
import { version } from '@anthropic-ai/claude-agent-sdk';
console.log(version);
```

### Claude Code CLI (Optional)

**Installation**:
```bash
npm install -g @anthropic-ai/claude-code
```

**Verify**:
```bash
claude --version
```

**Benefits**:
- Local Claude Code integration
- File-based features (subagents, CLAUDE.md)
- Slash commands support

---

## Configuration

### Environment Variables

**Set API Key** (Required):

**macOS/Linux**:
```bash
export ANTHROPIC_API_KEY='your-api-key-here'

# Make permanent (add to ~/.bashrc or ~/.zshrc)
echo 'export ANTHROPIC_API_KEY="your-api-key-here"' >> ~/.bashrc
```

**Windows (PowerShell)**:
```powershell
$env:ANTHROPIC_API_KEY='your-api-key-here'

# Make permanent
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_API_KEY', 'your-api-key-here', 'User')
```

**Windows (Command Prompt)**:
```cmd
set ANTHROPIC_API_KEY=your-api-key-here

# Make permanent
setx ANTHROPIC_API_KEY "your-api-key-here"
```

**Verify**:
```bash
echo $ANTHROPIC_API_KEY  # macOS/Linux
echo %ANTHROPIC_API_KEY%  # Windows CMD
$env:ANTHROPIC_API_KEY    # Windows PowerShell
```

### Python Configuration

**Option 1: Environment Variable** (Recommended):
```python
import os
# API key loaded automatically from ANTHROPIC_API_KEY
```

**Option 2: Direct in Code** (Not recommended for production):
```python
import os
os.environ['ANTHROPIC_API_KEY'] = 'your-api-key'
```

**Option 3: .env File** (With python-dotenv):
```bash
pip install python-dotenv
```

```python
# .env file
ANTHROPIC_API_KEY=your-api-key-here

# Load in Python
from dotenv import load_dotenv
load_dotenv()
```

### TypeScript Configuration

**Option 1: Environment Variable**:
```typescript
// Loaded automatically from process.env.ANTHROPIC_API_KEY
```

**Option 2: .env File** (With dotenv):
```bash
npm install dotenv
```

```typescript
// .env file
ANTHROPIC_API_KEY=your-api-key-here

// Load in TypeScript
import * as dotenv from 'dotenv';
dotenv.config();
```

---

## SuperClaude Framework Setup

The Claude Agent SDK integrates seamlessly with the **SuperClaude framework** - an enhanced Claude Code environment with behavioral modes, MCP servers, and intelligent tool orchestration.

### Framework Architecture

**Four-Layer System**:
```
┌─────────────────────────────────────┐
│  Python Agent SDK (Programmatic)    │  ← New Layer
├─────────────────────────────────────┤
│  Slash Commands (/sc:*)             │
├─────────────────────────────────────┤
│  MCP Servers (Sequential, Magic...)  │
├─────────────────────────────────────┤
│  Native Tools (Read, Write, Edit...) │
└─────────────────────────────────────┘
```

### Core Framework Components

**See**: [Claude Configuration](../../../CLAUDE.md) for complete architecture

#### 1. CLAUDE.md (Repository Instructions)
- Project-specific instructions and architecture
- Environment setup and dependencies
- File organization and workflows
- Automatically loaded when `setting_sources=["project"]`

#### 2. MODE System (Behavioral Modes)
- [Task Management Mode](../../../MODE_Task_Management.md) - TodoWrite integration, memory persistence
- [Orchestration Mode](../../../MODE_Orchestration.md) - Tool selection optimization
- [Token Efficiency Mode](../../../MODE_Token_Efficiency.md) - Symbol-based compression
- [Introspection Mode](../../../MODE_Introspection.md) - Meta-cognitive analysis
- [Brainstorming Mode](../../../MODE_Brainstorming.md) - Requirements discovery
- [Deep Research Mode](../../../MODE_DeepResearch.md) - Research workflows

Activate modes via system prompt flags: `--task-manage`, `--orchestrate`, `--uc`, etc.

#### 3. MCP Servers (Specialized Tools)
- [Sequential Thinking MCP](../../../MCP_Sequential.md) - Multi-step reasoning engine
- [Magic UI MCP](../../../MCP_Magic.md) - UI component generation (21st.dev)
- [Context7 Documentation MCP](../../../MCP_Context7.md) - Official library documentation
- [Serena Memory MCP](../../../MCP_Serena.md) - Semantic understanding & memory
- [Morphllm Pattern MCP](../../../MCP_Morphllm.md) - Pattern-based bulk edits
- [Playwright Browser MCP](../../../MCP_Playwright.md) - Browser automation & E2E testing

#### 4. Framework Rules & Principles
- [Framework Rules](../../../RULES.md) - Safety, quality, and workflow rules
- [Engineering Principles](../../../PRINCIPLES.md) - SOLID, DRY, KISS engineering principles

### Quick Setup with SuperClaude

**Minimal Integration** (Loads CLAUDE.md):
```python
from claude_agent_sdk import ClaudeAgentOptions

options = ClaudeAgentOptions(
    setting_sources=["project"],  # Load CLAUDE.md from project
    system_prompt={
        "type": "preset",
        "preset": "claude_code"
    }
)
```

**Full Framework Integration** (MODE + MCP + RULES):
```python
from claude_agent_sdk import ClaudeAgentOptions

options = ClaudeAgentOptions(
    # Load framework instructions
    setting_sources=["project"],

    # Activate modes via flags
    system_prompt={
        "type": "preset",
        "preset": "claude_code",
        "append": "--task-manage --orchestrate --think-hard"
    },

    # Enable MCP servers
    mcp_servers={
        "sequential": {
            "type": "stdio",
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
        },
        "serena": {
            "type": "stdio",
            "command": "npx",
            "args": ["-y", "@serena/mcp-server"]
        }
    },

    # Configure tools and permissions
    allowed_tools=["Read", "Write", "Edit", "TodoWrite", "Task",
                   "mcp__sequential__sequentialthinking",
                   "mcp__serena__write_memory"],
    permission_mode="acceptEdits"
)
```

### Framework Benefits

**Automatic Behaviors**:
- **Task Management**: TodoWrite tracking, memory persistence ([Task Management Mode](../../../MODE_Task_Management.md))
- **Tool Optimization**: Intelligent MCP routing ([Orchestration Mode](../../../MODE_Orchestration.md))
- **Safety Enforcement**: [Framework Rules](../../../RULES.md) compliance via hooks
- **Reasoning Enhancement**: Sequential MCP for complex analysis
- **Cross-Session Memory**: Serena MCP for project context

**See Also**:
- [Tools & MCP Guide](tools-and-mcp.md) - MCP server integration guide
- [Production Patterns Guide](production-patterns.md) - Enterprise deployment patterns
- [API Reference](api-reference.md) - Complete API documentation

---

## Hello World Examples

### Example 1: Simple Query (Python)

**Based on**: Official quick_start.py example

```python
import anyio
from claude_agent_sdk import query, AssistantMessage, TextBlock

async def main():
    async for message in query(prompt="What is 2 + 2?"):
        if isinstance(message, AssistantMessage):
            for block in message.content:
                if isinstance(block, TextBlock):
                    print(f"Claude: {block.text}")

anyio.run(main)
```

> **Note**: Official SDK examples use `anyio.run()` instead of `asyncio.run()` for better compatibility with different async environments (including Jupyter notebooks).

**Output**:
```
Claude: 2 + 2 equals 4.
```

### Example 2: Query with Options (Python)

**Based on**: Official quick_start.py with_options_example

```python
import anyio
from claude_agent_sdk import query, ClaudeAgentOptions, AssistantMessage, TextBlock

async def main():
    options = ClaudeAgentOptions(
        system_prompt="You are a helpful assistant that explains things simply.",
        max_turns=1  # Limit to single turn for efficiency
    )

    async for message in query(
        prompt="Explain what Python is in one sentence.",
        options=options
    ):
        if isinstance(message, AssistantMessage):
            for block in message.content:
                if isinstance(block, TextBlock):
                    print(f"Claude: {block.text}")

anyio.run(main)
```

### Example 3: Stateful Conversation (Python)

```python
import anyio
from claude_agent_sdk import ClaudeSDKClient

async def main():
    async with ClaudeSDKClient() as client:
        # First query
        await client.query("What's the capital of France?")
        async for msg in client.receive_response():
            print(msg)

        # Follow-up (context preserved)
        await client.query("What's the population?")
        async for msg in client.receive_response():
            print(msg)

anyio.run(main)
```

### Example 4: File Operations (Python)

**Based on**: Official quick_start.py with_tools_example

```python
import anyio
from claude_agent_sdk import query, ClaudeAgentOptions, AssistantMessage, ResultMessage, TextBlock

async def main():
    options = ClaudeAgentOptions(
        allowed_tools=["Read", "Write"],
        system_prompt="You are a helpful file assistant."
    )

    async for message in query(
        prompt="Create a file called hello.txt with 'Hello, World!' in it",
        options=options
    ):
        if isinstance(message, AssistantMessage):
            for block in message.content:
                if isinstance(block, TextBlock):
                    print(f"Claude: {block.text}")
        elif isinstance(message, ResultMessage) and message.total_cost_usd and message.total_cost_usd > 0:
            print(f"\nCost: ${message.total_cost_usd:.4f}")

anyio.run(main)
```

> **Tip**: Track costs in production using `ResultMessage.total_cost_usd` to monitor API usage.

### Example 5: Custom Tool (Python)

```python
import anyio
from claude_agent_sdk import (
    tool, create_sdk_mcp_server,
    ClaudeAgentOptions, ClaudeSDKClient
)

# Define custom tool
@tool("greet", "Greet a person", {"name": str})
async def greet_person(args):
    return {
        "content": [{
            "type": "text",
            "text": f"Hello, {args['name']}! 👋"
        }]
    }

# Create MCP server
server = create_sdk_mcp_server(
    name="greetings",
    version="1.0.0",
    tools=[greet_person]
)

async def main():
    options = ClaudeAgentOptions(
        mcp_servers={"greetings": server},
        allowed_tools=["mcp__greetings__greet"]
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query("Greet Alice")
        async for msg in client.receive_response():
            print(msg)

anyio.run(main)
```

**Output**:
```
Hello, Alice! 👋
```

### Example 6: TypeScript Hello World

```typescript
import { query } from '@anthropic-ai/claude-agent-sdk';

async function main() {
    for await (const message of query({ prompt: "What is 2 + 2?" })) {
        console.log(message);
    }
}

main();
```

### Example 7: TypeScript with Options

```typescript
import { query, ClaudeAgentOptions } from '@anthropic-ai/claude-agent-sdk';

async function main() {
    const options: ClaudeAgentOptions = {
        systemPrompt: "You are a TypeScript expert",
        maxTokens: 1024
    };

    for await (const message of query({
        prompt: "Explain async/await",
        options
    })) {
        console.log(message);
    }
}

main();
```

---

## Official SDK Examples

These examples are based on the [official Anthropic SDK repository](https://github.com/anthropics/claude-agent-sdk-python/tree/main/examples). The repository contains 12 official examples demonstrating production-ready patterns:

**Available Examples**:
1. `quick_start.py` - Basic SDK usage patterns
2. `agents.py` - Custom agent definitions (code-reviewer, doc-writer)
3. `hooks.py` - Safety hooks and permission controls
4. `streaming_mode.py` - Streaming response handling
5. `streaming_mode_ipython.py` - IPython-specific streaming
6. `streaming_mode_trio.py` - Trio async framework integration
7. `system_prompt.py` - System prompt configuration
8. `include_partial_messages.py` - Partial message streaming
9. `setting_sources.py` - Filesystem settings loading
10. `stderr_callback_example.py` - Error output handling
11. `tool_permission_callback.py` - Dynamic tool permissions
12. `mcp_calculator.py` - MCP server implementation example

### Example 8: Custom Agent Definition

**Source**: `examples/agents.py` from official repository

**Purpose**: Define specialized agents with custom prompts and tool access

```python
import anyio
from claude_agent_sdk import (
    AgentDefinition,
    AssistantMessage,
    ClaudeAgentOptions,
    ResultMessage,
    TextBlock,
    query,
)

async def code_reviewer_example():
    """Custom code reviewer agent with restricted tools."""

    options = ClaudeAgentOptions(
        agents={
            "code-reviewer": AgentDefinition(
                description="Reviews code for best practices and potential issues",
                prompt="""You are a code reviewer. Analyze code for bugs, performance issues,
                security vulnerabilities, and adherence to best practices.
                Provide constructive feedback.""",
                tools=["Read", "Grep"],  # Limited to read-only operations
                model="sonnet",  # Specify model for this agent
            ),
        },
    )

    async for message in query(
        prompt="Use the code-reviewer agent to review the code in src/main.py",
        options=options,
    ):
        if isinstance(message, AssistantMessage):
            for block in message.content:
                if isinstance(block, TextBlock):
                    print(f"Reviewer: {block.text}")
        elif isinstance(message, ResultMessage) and message.total_cost_usd:
            print(f"\nCost: ${message.total_cost_usd:.4f}")

anyio.run(code_reviewer_example)
```

**Key Patterns**:
- `AgentDefinition` for specialized personas
- `tools` parameter restricts agent capabilities
- `model` parameter allows per-agent model selection
- Cost tracking via `ResultMessage.total_cost_usd`

**Available Models**: `"sonnet"`, `"opus"`, `"haiku"`, `"inherit"` (uses parent model)

### Example 9: Safety Hooks

**Source**: `examples/hooks.py` from official repository

**Purpose**: Implement safety controls using PreToolUse hooks

```python
import anyio
from claude_agent_sdk import ClaudeAgentOptions, HookMatcher, query

async def block_dangerous_commands(input_data, tool_use_id, context):
    """Hook to block potentially dangerous bash commands."""

    tool_name = input_data.get('tool_name')
    if tool_name == "Bash":
        command = input_data.get('tool_input', {}).get('command', '')

        # Block dangerous operations
        dangerous_patterns = ['rm -rf /', 'dd if=', 'mkfs', ':(){:|:&};:']

        for pattern in dangerous_patterns:
            if pattern in command:
                return {
                    'hookSpecificOutput': {
                        'hookEventName': 'PreToolUse',
                        'permissionDecision': 'deny',
                        'permissionDecisionReason': f'Blocked dangerous command pattern: {pattern}'
                    }
                }

    return {}  # Allow if no dangerous patterns found

async def safety_example():
    options = ClaudeAgentOptions(
        allowed_tools=["Bash"],
        hooks={
            'PreToolUse': [
                HookMatcher(matcher='Bash', hooks=[block_dangerous_commands])
            ]
        }
    )

    async for message in query(
        prompt="List files in the current directory",
        options=options
    ):
        print(message)

anyio.run(safety_example)
```

**Hook Return Structure**:
```python
{
    'hookSpecificOutput': {
        'hookEventName': 'PreToolUse',  # Hook type
        'permissionDecision': 'deny',   # 'allow' or 'deny'
        'permissionDecisionReason': str  # Human-readable explanation
    }
}
```

### Example 10: Documentation Writer Agent

**Source**: `examples/agents.py` - doc-writer agent

**Purpose**: Multi-agent workflow with different specializations

```python
import anyio
from claude_agent_sdk import AgentDefinition, ClaudeAgentOptions, query

async def multi_agent_documentation():
    """Use multiple specialized agents in one workflow."""

    options = ClaudeAgentOptions(
        agents={
            "code-reviewer": AgentDefinition(
                description="Reviews code for best practices",
                prompt="Expert code reviewer focusing on quality and security.",
                tools=["Read", "Grep"],
                model="sonnet",
            ),
            "doc-writer": AgentDefinition(
                description="Writes comprehensive documentation",
                prompt="""Technical documentation expert. Write clear, comprehensive
                documentation with examples. Focus on clarity and completeness.""",
                tools=["Read", "Write", "Edit"],
                model="sonnet",
            ),
            "test-writer": AgentDefinition(
                description="Creates comprehensive test suites",
                prompt="Test engineer. Write thorough unit and integration tests.",
                tools=["Read", "Write", "Bash"],
                model="haiku",  # Faster model for test generation
            ),
        },
    )

    async for message in query(
        prompt="""
        1. Use code-reviewer to analyze src/auth.py
        2. Use doc-writer to create documentation based on the review
        3. Use test-writer to generate tests for the documented API
        """,
        options=options,
    ):
        print(message)

anyio.run(multi_agent_documentation)
```

**Agent Orchestration Benefits**:
- Specialized expertise per task
- Cost optimization (haiku for simpler tasks)
- Security via tool restrictions
- Parallel execution when possible

### Example 11: Streaming Modes

**Source**: `examples/streaming_mode.py` from official repository

**Purpose**: Handle streaming responses with real-time output

```python
import anyio
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions, AssistantMessage, TextBlock

async def streaming_example():
    """Stream responses as they arrive for better UX."""

    options = ClaudeAgentOptions(
        include_partial_messages=True,  # Enable streaming partial updates
        allowed_tools=["Read", "Write"]
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query("Write a short story about a robot learning to code")

        async for message in client.receive_response():
            if isinstance(message, AssistantMessage):
                for block in message.content:
                    if isinstance(block, TextBlock):
                        # Print text as it streams in
                        print(block.text, end='', flush=True)

anyio.run(streaming_example)
```

**Key Features**:
- `include_partial_messages=True` enables streaming
- Messages arrive incrementally for real-time display
- Better user experience for long-running tasks

### Example 12: Setting Sources Configuration

**Source**: `examples/setting_sources.py` from official repository

**Purpose**: Control which filesystem settings to load

```python
import anyio
from claude_agent_sdk import query, ClaudeAgentOptions

async def settings_example():
    """Demonstrate different setting source configurations."""

    # Load all settings (legacy behavior)
    all_settings = ClaudeAgentOptions(
        setting_sources=["user", "project", "local"]
    )

    # Load only project settings (common for SDK usage)
    project_only = ClaudeAgentOptions(
        setting_sources=["project"]  # Loads .claude/settings.json and CLAUDE.md
    )

    # No filesystem settings (SDK-only configuration)
    sdk_only = ClaudeAgentOptions(
        # setting_sources=None is the default in v2.0+
        mcp_servers={...},
        agents={...}
    )

    async for message in query(
        prompt="Analyze project structure",
        options=project_only
    ):
        print(message)

anyio.run(settings_example)
```

**Breaking Change (v2.0+)**:
- **Previous behavior**: Loaded all settings sources by default
- **Current behavior**: When `setting_sources` is omitted or `None`, no filesystem settings are loaded
- **Migration**: Add `setting_sources=["project"]` to maintain previous behavior

### Example 13: Tool Permission Callback

**Source**: `examples/tool_permission_callback.py` from official repository

**Purpose**: Dynamic tool permission decisions at runtime

```python
import anyio
from claude_agent_sdk import query, ClaudeAgentOptions

async def permission_callback(tool_name: str, input_data: dict, context: dict):
    """Custom permission logic for tool execution."""

    # Allow read-only operations automatically
    if tool_name in ["Read", "Grep", "Glob"]:
        return {"behavior": "allow", "updatedInput": input_data}

    # Require explicit confirmation for writes
    if tool_name in ["Write", "Edit"]:
        file_path = input_data.get("file_path", "")
        if "/tmp/" in file_path:
            return {"behavior": "allow", "updatedInput": input_data}
        else:
            # In production, this could trigger a notification or approval workflow
            print(f"⚠️  Write requested to: {file_path}")
            return {"behavior": "allow", "updatedInput": input_data}

    # Block destructive operations
    if tool_name == "Bash":
        command = input_data.get("command", "")
        if any(danger in command for danger in ["rm -rf", "dd if=", "mkfs"]):
            return {
                "behavior": "deny",
                "message": "Blocked potentially dangerous command"
            }

    return {"behavior": "allow", "updatedInput": input_data}

async def main():
    options = ClaudeAgentOptions(
        allowed_tools=["Read", "Write", "Bash"],
        can_use_tool=permission_callback
    )

    async for message in query(
        prompt="Clean up old log files in /tmp",
        options=options
    ):
        print(message)

anyio.run(main)
```

**Permission Response Options**:
- `{"behavior": "allow", "updatedInput": data}` - Allow execution
- `{"behavior": "deny", "message": "reason"}` - Block execution
- Can modify `updatedInput` to transform tool parameters

### Example 14: Error Handling with Stderr Callback

**Source**: `examples/stderr_callback_example.py` from official repository

**Purpose**: Custom stderr processing and logging

```python
import anyio
from claude_agent_sdk import query, ClaudeAgentOptions
import logging

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def stderr_handler(stderr_line: str):
    """Process stderr output from Claude Code CLI."""

    # Log all stderr to file
    logger.error(f"SDK stderr: {stderr_line}")

    # Parse specific error patterns
    if "ENOENT" in stderr_line:
        logger.critical("File not found error detected")
    elif "EACCES" in stderr_line:
        logger.critical("Permission denied error detected")
    elif "context length exceeded" in stderr_line:
        logger.warning("Context limit reached - consider /compact")

async def main():
    options = ClaudeAgentOptions(
        stderr=stderr_handler,  # Custom stderr processing
        allowed_tools=["Read", "Bash"]
    )

    async for message in query(
        prompt="Run git status and analyze output",
        options=options
    ):
        print(message)

anyio.run(main)
```

**Use Cases**:
- Production monitoring and alerting
- Custom error logging and metrics
- Debug information collection
- Integration with external logging systems

---

## SuperClaude Integration Examples

### Example 15: Framework-Aware Query

**Purpose**: Load CLAUDE.md and activate SuperClaude framework features

```python
import anyio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
    options = ClaudeAgentOptions(
        # Load CLAUDE.md from project root
        setting_sources=["project"],

        # Use Claude Code system prompt
        system_prompt={
            "type": "preset",
            "preset": "claude_code"
        },

        # Enable framework tools
        allowed_tools=["Read", "Write", "Edit", "Grep", "Glob"],
        permission_mode="acceptEdits",

        # Set working directory
        cwd="/path/to/project"
    )

    async for message in query(
        prompt="Analyze the authentication module following Engineering Principles",
        options=options
    ):
        print(message)

anyio.run(main)
```

**Framework Behavior**:
- Loads [Claude Configuration](../../../CLAUDE.md) instructions automatically
- Applies [Engineering Principles](../../../PRINCIPLES.md) (SOLID, DRY, KISS) to analysis
- Follows [Framework Rules](../../../RULES.md) safety and quality standards
- Uses framework-aware file organization

**See**: [Claude Configuration](../../../CLAUDE.md), [Engineering Principles](../../../PRINCIPLES.md), [Framework Rules](../../../RULES.md)

### Example 16: MODE Activation

**Purpose**: Activate behavioral modes for specialized workflows

```python
import anyio
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions

async def main():
    options = ClaudeAgentOptions(
        setting_sources=["project"],

        # Activate Task Management mode
        system_prompt={
            "type": "preset",
            "preset": "claude_code",
            "append": "--task-manage --orchestrate"
        },

        allowed_tools=["TodoWrite", "Task", "Read", "Write", "Edit"],
        permission_mode="acceptEdits"
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query("""
        Implement user authentication system:
        1. Database models
        2. API endpoints
        3. Frontend integration
        4. Testing

        Use TodoWrite for task tracking.
        """)

        async for msg in client.receive_response():
            print(msg)

anyio.run(main)
```

**MODE Behaviors**:
- `--task-manage`: Activates TodoWrite tracking, memory persistence [Task Management Mode](../../../MODE_Task_Management.md)
- `--orchestrate`: Optimizes tool selection and parallel execution [Orchestration Mode](../../../MODE_Orchestration.md)
- `--think-hard`: Enables Sequential MCP for deep analysis [Deep Research Mode](../../../MODE_DeepResearch.md)
- `--uc`: Ultra-compressed symbol communication [Token Efficiency Mode](../../../MODE_Token_Efficiency.md)

**Available Modes**: `--task-manage`, `--orchestrate`, `--brainstorm`, `--introspect`, `--token-efficient`, `--think`, `--think-hard`, `--ultrathink`

### Example 17: MCP Server Integration

**Purpose**: Use Sequential MCP for complex multi-step reasoning

```python
import anyio
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions

async def main():
    options = ClaudeAgentOptions(
        setting_sources=["project"],

        # Enable Sequential MCP server
        mcp_servers={
            "sequential": {
                "type": "stdio",
                "command": "npx",
                "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
            }
        },

        allowed_tools=["mcp__sequential__sequentialthinking", "Read", "Grep"],

        system_prompt={
            "type": "preset",
            "preset": "claude_code",
            "append": "--think-hard"
        }
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query("""
        Debug the authentication flow:
        1. Analyze login endpoint
        2. Trace token generation
        3. Identify security vulnerabilities
        4. Recommend fixes
        """)

        async for msg in client.receive_response():
            print(msg)

anyio.run(main)
```

**MCP Behavior**:
- Sequential MCP provides structured multi-step reasoning
- `--think-hard` flag activates deep analysis mode
- Systematic investigation following framework patterns

**See**: [Sequential Thinking MCP](../../../MCP_Sequential.md), [Tools & MCP Guide](tools-and-mcp.md)

### Example 18: Cross-Session Memory with Serena

**Purpose**: Persist context across multiple sessions using Serena MCP

```python
import anyio
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions

async def session_1_start():
    """Session 1: Start project planning"""
    options = ClaudeAgentOptions(
        setting_sources=["project"],

        # Enable Serena for memory persistence
        mcp_servers={
            "serena": {
                "type": "stdio",
                "command": "npx",
                "args": ["-y", "@serena/mcp-server"]
            }
        },

        allowed_tools=[
            "mcp__serena__write_memory",
            "mcp__serena__read_memory",
            "TodoWrite", "Read", "Write"
        ],

        system_prompt={
            "type": "preset",
            "preset": "claude_code",
            "append": "--task-manage"
        }
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query("""
        Plan microservices architecture:
        1. Service decomposition
        2. API contracts
        3. Database schema

        Store plan in Serena memory for future sessions.
        """)

        async for msg in client.receive_response():
            print(msg)

async def session_2_continue():
    """Session 2: Continue implementation (hours/days later)"""
    options = ClaudeAgentOptions(
        setting_sources=["project"],

        mcp_servers={
            "serena": {
                "type": "stdio",
                "command": "npx",
                "args": ["-y", "@serena/mcp-server"]
            }
        },

        allowed_tools=[
            "mcp__serena__read_memory",
            "mcp__serena__write_memory",
            "Read", "Write", "Edit"
        ],

        system_prompt={
            "type": "preset",
            "preset": "claude_code",
            "append": "--task-manage"
        }
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query("Continue microservices implementation from stored plan")
        # Claude retrieves plan from Serena memory automatically

        async for msg in client.receive_response():
            print(msg)

# Run sessions
anyio.run(session_1_start)
# ... hours or days later ...
anyio.run(session_2_continue)
```

**Serena Workflow**:
- Session 1: `write_memory()` stores project plan and decisions
- Session 2: `read_memory()` retrieves context from previous session
- Cross-session learning and context preservation

**See**: [Serena Memory MCP](../../../MCP_Serena.md), [Task Management Mode](../../../MODE_Task_Management.md)

### Example 19: Multi-MCP Orchestration

**Purpose**: Coordinate multiple MCP servers for comprehensive workflows

```python
import anyio
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions

async def main():
    options = ClaudeAgentOptions(
        setting_sources=["project"],

        # Enable multiple MCP servers
        mcp_servers={
            "sequential": {
                "type": "stdio",
                "command": "npx",
                "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
            },
            "context7": {
                "type": "stdio",
                "command": "npx",
                "args": ["-y", "@context7/mcp-server"]
            },
            "magic": {
                "type": "stdio",
                "command": "npx",
                "args": ["-y", "@21st-dev/magic-mcp"]
            }
        },

        allowed_tools=[
            "mcp__sequential__sequentialthinking",
            "mcp__context7__get_library_docs",
            "mcp__magic__21st_magic_component_builder",
            "Read", "Write", "Edit"
        ],

        system_prompt={
            "type": "preset",
            "preset": "claude_code",
            "append": "--orchestrate --think-hard"
        }
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query("""
        Build React login form:
        1. Context7: Get official React patterns
        2. Sequential: Analyze implementation approach
        3. Magic: Generate accessible login component
        4. Write component to src/components/
        """)

        async for msg in client.receive_response():
            print(msg)

anyio.run(main)
```

**Multi-MCP Coordination**:
- **Context7**: Official React documentation and patterns [Context7 Documentation MCP](../../../MCP_Context7.md)
- **Sequential**: Structured analysis and planning [Sequential Thinking MCP](../../../MCP_Sequential.md)
- **Magic**: Production-ready UI component generation [Magic UI MCP](../../../MCP_Magic.md)
- **Orchestration Mode**: Intelligent tool routing and optimization [Orchestration Mode](../../../MODE_Orchestration.md)

### Example 20: Framework Rules Enforcement via Hooks

**Purpose**: Enforce framework safety rules using hook system

```python
import anyio
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions, HookMatcher

async def enforce_git_safety(input_data, tool_use_id, context):
    """Implement RULES.md git safety rules"""
    tool_name = input_data.get('tool_name')

    if tool_name == "Bash":
        cmd = input_data.get('tool_input', {}).get('command', '')

        # RULES.md: Never force push to main/master
        if 'push --force' in cmd and ('main' in cmd or 'master' in cmd):
            return {
                'hookSpecificOutput': {
                    'hookEventName': 'PreToolUse',
                    'permissionDecision': 'deny',
                    'permissionDecisionReason': 'Never force push to main/master (RULES.md)'
                }
            }

        # RULES.md: Always create feature branches
        if 'checkout -b' not in cmd and 'commit' in cmd:
            current_branch = "main"  # Would check via git branch
            if current_branch in ['main', 'master']:
                return {
                    'hookSpecificOutput': {
                        'hookEventName': 'PreToolUse',
                        'permissionDecision': 'deny',
                        'permissionDecisionReason': 'Work on feature branches only, never main (RULES.md)'
                    }
                }

    return {}

async def main():
    options = ClaudeAgentOptions(
        setting_sources=["project"],

        # Enforce RULES.md via hooks
        hooks={
            'PreToolUse': [
                HookMatcher(matcher='Bash', hooks=[enforce_git_safety])
            ]
        },

        allowed_tools=["Bash", "Read", "Write", "Edit"],
        permission_mode="acceptEdits"
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query("Commit the authentication changes to git")
        # Hook will enforce feature branch requirement

        async for msg in client.receive_response():
            print(msg)

anyio.run(main)
```

**Framework Rules Enforcement**:
- Git safety: Feature branches only, no force push to main
- File operations: Read before write/edit
- Code quality: Run tests before marking complete
- Professional standards: No marketing language in technical docs

**See**: [Framework Rules](../../../RULES.md), [API Reference - Hooks System](api-reference.md#hooks-system)

### Example 21: Real-World Email Agent

**Based on**: Anthropic's email agent walkthrough[^4]

```python
import anyio
from claude_agent_sdk import tool, create_sdk_mcp_server, ClaudeSDKClient, ClaudeAgentOptions

# Define email processing tool
@tool(
    "process_email",
    "Process inbound email based on rules",
    {
        "from": str,
        "subject": str,
        "body": str,
        "rules": dict
    }
)
async def process_email(args):
    email_from = args["from"]
    subject = args["subject"]
    body = args["body"]
    rules = args.get("rules", {})

    # Apply email processing rules
    if "urgent" in subject.lower():
        priority = "high"
        action = "notify_immediately"
    elif email_from in rules.get("vip_senders", []):
        priority = "medium"
        action = "flag_for_review"
    else:
        priority = "low"
        action = "auto_categorize"

    result = {
        "priority": priority,
        "action": action,
        "category": categorize_email(subject, body)
    }

    return {
        "content": [{
            "type": "text",
            "text": f"Email processed: {priority} priority, action: {action}"
        }]
    }

def categorize_email(subject, body):
    # Simple categorization logic
    if any(word in body.lower() for word in ["invoice", "payment", "billing"]):
        return "finance"
    elif any(word in subject.lower() for word in ["meeting", "schedule", "calendar"]):
        return "scheduling"
    else:
        return "general"

# Create MCP server with email tool
email_server = create_sdk_mcp_server(
    name="email_agent",
    version="1.0.0",
    tools=[process_email]
)

async def main():
    options = ClaudeAgentOptions(
        system_prompt="You are an email processing assistant",
        mcp_servers={"email_agent": email_server},
        allowed_tools=["mcp__email_agent__process_email"]
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query("""
        Process this email:
        From: boss@company.com
        Subject: URGENT: Q4 Budget Review
        Body: We need to review the Q4 budget immediately. Please schedule a meeting.
        """)

        async for msg in client.receive_response():
            print(msg)

anyio.run(main())
```

### Example 22: Customer Support Shopify Integration

**Based on**: Custom tool pattern for e-commerce[^5]

```python
import anyio
from claude_agent_sdk import tool, create_sdk_mcp_server, ClaudeSDKClient, ClaudeAgentOptions
import httpx

# Shopify API integration tool
@tool(
    "lookup_order",
    "Look up order details from Shopify",
    {"order_id": str}
)
async def lookup_order(args):
    order_id = args["order_id"]

    # Simulate Shopify API call (replace with actual API)
    async with httpx.AsyncClient() as client:
        # In real implementation, use actual Shopify API
        # response = await client.get(f"https://shop.myshopify.com/admin/api/2024-01/orders/{order_id}.json")
        # order_data = response.json()

        # Mock response for demonstration
        order_data = {
            "order_id": order_id,
            "status": "shipped",
            "tracking": "1Z999AA10123456784",
            "items": ["Product A", "Product B"],
            "total": "$129.99"
        }

    return {
        "content": [{
            "type": "text",
            "text": f"""Order {order_id} Details:
Status: {order_data['status']}
Tracking: {order_data['tracking']}
Items: {', '.join(order_data['items'])}
Total: {order_data['total']}"""
        }]
    }

# Create customer support agent
support_server = create_sdk_mcp_server(
    name="shopify_support",
    version="1.0.0",
    tools=[lookup_order]
)

async def main():
    options = ClaudeAgentOptions(
        system_prompt="""You are a helpful customer support agent.
When customers ask about their orders, use the lookup_order tool to get real-time information.""",
        mcp_servers={"shopify_support": support_server},
        allowed_tools=["mcp__shopify_support__lookup_order"]
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query("Can you check the status of my order #12345?")

        async for msg in client.receive_response():
            print(msg)

anyio.run(main())
```

### Example 23: Document Generation Agent

**Based on**: Real-world document creation workflows[^6]

```python
import anyio
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions
from openpyxl import Workbook
from pptx import Presentation
from docx import Document

async def main():
    options = ClaudeAgentOptions(
        system_prompt="""You are a document generation expert.
You can create Excel spreadsheets, PowerPoint presentations, and Word documents.
Use Python scripts to generate documents with proper formatting.""",
        allowed_tools=["Bash", "Write"],
        permission_mode='acceptEdits'
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query("""
        Create a Python script that generates a sales report Excel file with:
        1. A header row with: Date, Product, Quantity, Revenue
        2. Sample data for 5 products
        3. A total revenue calculation
        4. Save as 'sales_report.xlsx'

        Then create a PowerPoint presentation summarizing the data.
        """)

        async for msg in client.receive_response():
            print(msg)

anyio.run(main())
```

---

## Common Setup Issues

### Issue 1: Import Error

**Error**:
```python
ImportError: No module named 'claude_agent_sdk'
```

**Solutions**:

1. **Verify Installation**:
   ```bash
   pip list | grep claude
   ```

2. **Check for Old Package**:
   ```bash
   pip uninstall claude-code-sdk  # Old name
   pip install claude-agent-sdk   # New name
   ```

3. **Verify Python Version**:
   ```bash
   python --version  # Must be 3.10+
   ```

4. **Use Correct Python**:
   ```bash
   python3 -m pip install claude-agent-sdk
   python3 your_script.py
   ```

### Issue 2: API Key Not Found

**Error**:
```
Error: ANTHROPIC_API_KEY environment variable not set
```

**Solutions**:

1. **Check Environment Variable**:
   ```bash
   echo $ANTHROPIC_API_KEY  # Should show your key
   ```

2. **Set in Current Session**:
   ```bash
   export ANTHROPIC_API_KEY='your-key'
   ```

3. **Set Permanently** (add to ~/.bashrc):
   ```bash
   echo 'export ANTHROPIC_API_KEY="your-key"' >> ~/.bashrc
   source ~/.bashrc
   ```

4. **Verify in Python**:
   ```python
   import os
   print(os.environ.get('ANTHROPIC_API_KEY'))
   ```

### Issue 3: Async Runtime Error

**Error**:
```
RuntimeError: asyncio.run() cannot be called from a running event loop
```

**Solutions**:

1. **Use anyio Instead** (Recommended):
   ```python
   import anyio
   anyio.run(main)  # Instead of asyncio.run(main)
   ```

2. **In Jupyter/IPython** (Already has event loop):
   ```python
   # Just use await directly
   await main()
   ```

3. **Install anyio**:
   ```bash
   pip install anyio
   ```

### Issue 4: Permission Denied

**Error**:
```
Error: Permission denied for tool execution
```

**Solutions**:

1. **Check permission_mode**:
   ```python
   options = ClaudeAgentOptions(
       permission_mode='acceptEdits'  # or 'acceptAll'
   )
   ```

2. **Verify allowed_tools**:
   ```python
   options = ClaudeAgentOptions(
       allowed_tools=["Read", "Write", "Bash"]
   )
   ```

3. **Check Hook Blocking**:
   ```python
   # Ensure hooks aren't denying permission
   # Remove or modify hooks if blocking unintentionally
   ```

### Issue 5: Context Length Exceeded

**Error**:
```
Error: Maximum context length exceeded
```

**Solutions**:

1. **Reduce max_tokens**:
   ```python
   options = ClaudeAgentOptions(max_tokens=4096)
   ```

2. **Limit Conversation Turns**:
   ```python
   options = ClaudeAgentOptions(max_turns=20)
   ```

3. **Use Manual Compact**:
   ```python
   # In Claude Code CLI
   /compact
   ```

4. **Design Concise Tools**:
   ```python
   # Return summaries, not full content
   @tool("summary", "Get summary", {"topic": str})
   async def get_summary(args):
       full_data = fetch_data(args["topic"])
       summary = summarize(full_data)  # Summarize first
       return {"content": [{"type": "text", "text": summary}]}
   ```

### Issue 6: Module Import in Jupyter

**Error**:
```
ModuleNotFoundError in Jupyter notebook
```

**Solutions**:

1. **Install in Jupyter Kernel**:
   ```bash
   # Find kernel
   jupyter kernelspec list

   # Install in kernel's Python
   /path/to/kernel/python -m pip install claude-agent-sdk
   ```

2. **Or Install from Notebook**:
   ```python
   !pip install claude-agent-sdk
   ```

3. **Restart Kernel** after installation

### Issue 7: Node.js Version Too Old

**Error** (TypeScript):
```
Error: Node.js version 18 or higher required
```

**Solutions**:

1. **Check Version**:
   ```bash
   node --version
   ```

2. **Update Node.js**:
   ```bash
   # Using nvm (recommended)
   nvm install 18
   nvm use 18

   # Or download from nodejs.org
   ```

3. **Verify**:
   ```bash
   node --version  # Should be 18+
   ```

### Issue 8: CLAUDE.md Not Loading

**Error**:
```
Warning: setting_sources=["project"] but no CLAUDE.md found
```

**Solutions**:

1. **Check File Location**:
   ```bash
   ls -la CLAUDE.md  # Should be in project root
   ```

2. **Verify cwd Setting**:
   ```python
   options = ClaudeAgentOptions(
       setting_sources=["project"],
       cwd="/correct/path/to/project"  # Must have CLAUDE.md
   )
   ```

3. **Create CLAUDE.md**:
   ```markdown
   # Project Instructions

   ## Architecture
   [Your project architecture]

   ## Development Standards
   [Your coding standards]
   ```

4. **Check File Permissions**:
   ```bash
   chmod 644 CLAUDE.md
   ```

### Issue 9: MCP Server Connection Failed

**Error**:
```
Error: Failed to connect to MCP server 'sequential'
```

**Solutions**:

1. **Verify MCP Server Installation**:
   ```bash
   npx -y @modelcontextprotocol/server-sequential-thinking --version
   ```

2. **Check Server Configuration**:
   ```python
   mcp_servers={
       "sequential": {
           "type": "stdio",
           "command": "npx",  # Correct command
           "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
       }
   }
   ```

3. **Test Server Manually**:
   ```bash
   npx -y @modelcontextprotocol/server-sequential-thinking
   ```

4. **Check Network/Firewall**:
   - Ensure npx has network access
   - Check firewall settings for Node.js

---

## Next Steps

### Learn Core Concepts
- [Architecture Guide](architecture.md) - Understanding the agent loop and internals
- [API Reference](api-reference.md) - Complete API documentation with SuperClaude integration

### Build with Tools
- [Tools & MCP Guide](tools-and-mcp.md) - Custom tools and MCP integration with framework
- [Real-World Use Cases](real-world-use-cases.md) - Practical SuperClaude examples

### Deploy to Production
- [Production Patterns Guide](production-patterns.md) - Enterprise deployment with framework
- [Security Best Practices](security.md) - Best practices and security

### Optimize Performance
- [Performance Optimization Guide](performance-optimization.md) - Benchmarks and cost optimization

---

## Setup Summary

**Basic Requirements**:
- Python 3.10+ or Node.js 18+ installed
- claude-agent-sdk package installed via pip or npm
- ANTHROPIC_API_KEY environment variable configured
- Hello World example executed successfully
- Query function tested with configuration options
- Custom tool created and registered

**SuperClaude Framework Integration**:
- CLAUDE.md created in project root directory
- setting_sources=["project"] configured in ClaudeAgentOptions
- MODE activation tested (--task-manage, --orchestrate flags)
- MCP servers installed (Sequential, Serena, Magic)
- Hooks configured for Framework Rules enforcement
- Cross-session memory tested with Serena MCP server

**Related Documentation**:
- [Real-World Use Cases](real-world-use-cases.md) - Production implementations and case studies
- [Architecture Guide](architecture.md) - Internal systems and design patterns
- [Security Best Practices](security.md) - Security architecture and vulnerability mitigation
- [Tools & MCP Guide](tools-and-mcp.md) - Built-in tools and MCP integration patterns

---

## References

[^1]: GitHub. "Claude Agent SDK Python." Installation Requirements, 2025. https://github.com/anthropics/claude-agent-sdk-python
[^2]: DataCamp. "Claude Agent SDK Tutorial." Prerequisites, 2025. https://www.datacamp.com/tutorial/how-to-use-claude-agent-sdk
[^3]: DataCamp. "Claude Code: A Guide With Practical Examples." Billing Setup, 2025. https://www.datacamp.com/tutorial/claude-code
[^4]: Anthropic. "Building agents with the Claude Agent SDK." Email Agent Example, 2025. https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk
[^5]: eesel AI. "A Practical Guide to the Python Claude Code SDK." Custom Tools, 2025. https://www.eesel.ai/blog/python-claude-code-sdk
[^6]: Anthropic. "Building agents with the Claude Agent SDK." Document Generation, 2025. https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk

[**→ Complete Bibliography**](references.md)

[← Back to Documentation Index](index.md)
