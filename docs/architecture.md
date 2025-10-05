# Architecture - Claude Agent SDK

> **Internal design, implementation details, and technical architecture**

[← Back to Documentation Index](index.md)

---

## Table of Contents

1. [Overview](#overview)
2. [Agent Loop Architecture](#agent-loop-architecture)
3. [Context Management System](#context-management-system)
4. [Tool Execution Framework](#tool-execution-framework)
5. [Subagent Architecture](#subagent-architecture)
6. [Hook System](#hook-system)
7. [MCP Integration Layer](#mcp-integration-layer)
8. [Performance Optimizations](#performance-optimizations)

---

## Overview

The Claude Agent SDK is built on top of the **agent harness that powers Claude Code**, providing all the building blocks needed to build production-ready agents.[^1]

### Core Design Principles

1. **Agent-Centric**: Designed for autonomous operation, not just text generation
2. **Stateful Sessions**: Maintains conversation and context across interactions
3. **Tool-First**: Actions through tools, not just responses
4. **Production-Ready**: Automatic context management, error handling, monitoring

### Architecture Stack

```
┌─────────────────────────────────────────┐
│         User Application Layer          │
├─────────────────────────────────────────┤
│      Claude Agent SDK (Python/TS)       │
├─────────────────────────────────────────┤
│         Agent Harness (Core)            │
├─────────────────────────────────────────┤
│    Claude API + Extended Thinking       │
├─────────────────────────────────────────┤
│   Model Context Protocol (MCP) Layer    │
└─────────────────────────────────────────┘
```

---

## Agent Loop Architecture

### Core Loop Pattern

The Claude Agent SDK implements a **structured agent loop with four key steps**:[^2]

```
1. Gather Context → 2. Take Action → 3. Verify Work → 4. Repeat
```

This iterative cycle mirrors how a human expert tackles complex problems, allowing the agent to build understanding, make progress, and self-correct.

### Detailed Loop Implementation

#### Phase 1: Gather Context

**Purpose**: Build comprehensive understanding of the problem space

**Methods**:
- **Agentic Search**: File system traversal and semantic search
- **Documentation Analysis**: Read relevant docs and code
- **Subagent Delegation**: Parallel information gathering
- **Context Compaction**: Automatic summarization of gathered data

**Implementation**:
```python
# Context gathering through multiple tools
tools_used = [
    "Read",      # File contents
    "Grep",      # Code search
    "Glob",      # File pattern matching
    "WebFetch"   # External documentation
]
```

**Folder structure as context engineering**: The file system represents information that could be pulled into the model's context. When Claude encounters large files, it decides which way to load these into its context by using bash scripts like grep and tail.[^3]

#### Phase 2: Take Action

**Purpose**: Execute operations to make progress toward goals

**Action Types**:
1. **Custom Tools**: User-defined Python/TypeScript functions
2. **Built-in Tools**: File operations, bash commands, web fetch
3. **Code Generation**: Create scripts for complex operations
4. **MCP Integration**: External service calls

**Tool Execution Framework**:
- **In-Process Tools**: Custom Python functions via `@tool` decorator
- **External MCP**: Separate process tools via stdio/HTTP
- **Code Execution**: Generate and run scripts for complex operations

**Example Action Flow**:
```python
# Action: Generate code to solve complex problem
code = generate_solution()
result = execute_code(code)
if result.success:
    save_to_file(result.output)
```

#### Phase 3: Verify Work

**Purpose**: Ensure actions produced correct results

**Verification Methods**:
1. **Rule-Based**: Check against defined specifications
2. **Visual Feedback**: Screenshots, output inspection
3. **LLM-as-Judge**: Use another model to validate
4. **Test Execution**: Run automated tests

**Quality Gates**:
- Output validation
- Error checking
- Compliance verification
- Performance validation

#### Phase 4: Repeat

**Purpose**: Continue until task completion or stopping condition

**Loop Control**:
- Task completion detection
- Error handling and retry logic
- Context window management
- User intervention points

**Stopping Conditions**:
- Task successfully completed
- Maximum iterations reached
- Unrecoverable error encountered
- User stops execution

---

## Context Management System

### Automatic Context Management

The SDK features **automatic compaction and context management** to ensure agents don't run out of context.[^1]

### Context Management Layers

#### 1. Large Context Windows

- **Claude 4**: 200,000 token context window[^4]
- **Automatic Summarization**: SDK handles token management behind the scenes[^5]
- **Intelligent Loading**: Selective context loading based on relevance

#### 2. Compaction Strategies

**Micro-Compact** (Introduced v1.0.68):[^6]
- Selective removal of old tool calls only
- Preserves conversation flow
- Maintains project context
- Minimal disruption to agent reasoning

**Auto-Compact**:[^6]
- Full conversation summarization
- Triggers at ~95% context capacity (25% remaining)[^7]
- Condenses entire message history
- Preserves essential information

**Manual Compact**:[^6]
- User-triggered via `/compact` command
- Recommended when finishing tasks
- Creates smaller, focused context
- Useful for problem-solving continuity

#### 3. CLAUDE.md Context Loading

**Project Context Management**:[^3]

```
Project-Level:   .claude/CLAUDE.md or CLAUDE.md
User-Level:      ~/.claude/CLAUDE.md
Organization:    /Library/Application Support/ClaudeCode/CLAUDE.md (macOS)
```

**Loading Requirement**:
Must explicitly set `settingSources: ['project']` to load CLAUDE.md files.[^3]

**Content Guidelines**:
- Project architecture
- Build commands
- Contribution guidelines
- Coding standards
- Domain knowledge

### Context Optimization Benefits

1. **Reduced Token Usage**: 90% savings with prompt caching[^8]
2. **Cost Efficiency**: Compaction reduces API costs
3. **Performance**: Focused context improves response quality
4. **Continuity**: Maintains conversation coherence

---

## Tool Execution Framework

### Tool Architecture

```
┌─────────────────────────────────────────┐
│            User Application              │
├─────────────────────────────────────────┤
│   @tool Decorated Functions (Custom)    │
├─────────────────────────────────────────┤
│    In-Process MCP Server (SDK)          │
├─────────────────────────────────────────┤
│      Built-in Tools (SDK Core)          │
├─────────────────────────────────────────┤
│   External MCP Servers (Stdio/HTTP)     │
└─────────────────────────────────────────┘
```

### Built-in Tool Ecosystem

**Core Tools Provided by SDK**:[^1]
- **File Operations**: Read, Write, Edit
- **Code Execution**: Bash, script running
- **Search**: Grep, Glob pattern matching
- **Web**: WebFetch for external content
- **MCP Extensibility**: Connect to external services

### Custom Tool Implementation

**In-Process MCP Servers**:

Custom tools are implemented as **in-process MCP servers that run directly within your Python application**, eliminating the need for separate processes.[^9]

```python
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool("greet", "Greet a user", {"name": str})
async def greet_user(args):
    return {
        "content": [
            {"type": "text", "text": f"Hello, {args['name']}!"}
        ]
    }

# Create in-process MCP server
server = create_sdk_mcp_server(
    name="my-tools",
    version="1.0.0",
    tools=[greet_user]
)
```

**Tool Design for Context Efficiency**:[^10]

Tools should return concise, relevant information to maximize context efficiency:

```python
# ❌ Bad - Returns too much data
@tool("get_logs", "Get all logs", {})
async def get_all_logs(args):
    return {"content": [{"type": "text", "text": read_entire_log()}]}

# ✅ Good - Returns filtered, relevant data
@tool("get_error_logs", "Get recent errors", {"count": int})
async def get_error_logs(args):
    errors = filter_errors(read_log(), limit=args["count"])
    return {"content": [{"type": "text", "text": format_errors(errors)}]}
```

### External MCP Integration

**MCP Protocol Foundation**:[^11]

Built on **JSON-RPC**, MCP provides a stateful session protocol focused on context exchange and sampling coordination between clients and servers.

**Transport Mechanisms**:[^11]
- **stdio (Standard Input/Output)**: Local machine integration
- **HTTP + SSE (Server-Sent Events)**: Remote connections

**Client-Host-Server Architecture**:[^12]

```
AI Application (Client) ←→ MCP Host ←→ MCP Server
```

- Each client has 1:1 relationship with MCP server
- Multiple clients can connect to singular MCP host
- Orchestration logic in integration layer (IDEs, Claude Desktop)

---

## Subagent Architecture

### Subagent Design

**Definition**: Specialized agents designed for one specific job, delegated from a main agent.[^13]

**Key Benefits**:
1. **Parallelization**: Spin up multiple subagents for concurrent tasks[^14]
2. **Context Management**: Isolated context windows per subagent[^14]
3. **Specialization**: Dedicated agents for specific domains
4. **Information Flow**: Only relevant info sent back to orchestrator[^14]

### Subagent Implementation Patterns

#### Pattern 1: Task Specialization

```python
# Main orchestrator agent
orchestrator = ClaudeSDKClient(options=orchestrator_options)

# Specialized subagents
security_reviewer = ClaudeSDKClient(options=security_options)
code_generator = ClaudeSDKClient(options=coding_options)
test_writer = ClaudeSDKClient(options=testing_options)
```

**Example**: 7-Agent Documentation Pipeline[^15]

Rick Hightower demonstrated orchestration power with 7 subagents:
1. Diagram extractor
2. Image generator
3. Word compiler
4. PDF compiler
5. Content analyzer
6. Style validator
7. Orchestrator managing flow

#### Pattern 2: Parallel Execution

**Concurrent Task Processing**:[^14]
- Multiple subagents work simultaneously
- Independent context windows
- Coordinated by orchestrator
- Results aggregated for final output

```python
# Parallel subagent execution
async with asyncio.TaskGroup() as group:
    task1 = group.create_task(research_subagent.execute())
    task2 = group.create_task(analysis_subagent.execute())
    task3 = group.create_task(synthesis_subagent.execute())
```

### Subagent Coordination

**Orchestrator Responsibilities**:
- Task decomposition and delegation
- Subagent lifecycle management
- Result aggregation and synthesis
- Context coordination across agents

**Communication Patterns**:
- Orchestrator → Subagent: Task specification
- Subagent → Orchestrator: Results and status
- Subagent ↔ Subagent: Limited (via orchestrator)

---

## Hook System

### Hook Architecture

**Definition**: Hooks are Python functions that the Claude Code application invokes at specific points of the Claude agent loop.[^16]

**Purpose**:
- Deterministic processing
- Automated feedback
- Safety controls
- Behavior customization

### Hook Event Types

**Supported Hooks**:[^17]

| Hook Event | When Fired | Use Case |
|-----------|------------|----------|
| `PreToolUse` | Before tool execution | Input validation, blocking |
| `PostToolUse` | After tool execution | Result logging, modification |
| `UserPromptSubmit` | When user submits prompt | Input filtering |
| `Stop` | When stopping execution | Cleanup, state saving |
| `SubagentStop` | When subagent stops | Result aggregation |
| `PreCompact` | Before message compaction | Message preservation |

**Not Supported in Python SDK** (due to setup limitations):[^17]
- SessionStart
- SessionEnd
- Notification

### Hook Implementation

**Basic Hook Pattern**:

```python
from claude_agent_sdk import HookMatcher

async def safety_check(input_data, tool_use_id, context):
    tool_name = input_data["tool_name"]
    tool_input = input_data["tool_input"]

    # Validation logic
    if is_dangerous(tool_input):
        return {
            "hookSpecificOutput": {
                "hookEventName": "PreToolUse",
                "permissionDecision": "deny",
                "permissionDecisionReason": "Blocked dangerous operation"
            }
        }

    return {}  # Allow

options = ClaudeAgentOptions(
    hooks={
        "PreToolUse": [
            HookMatcher(matcher="Bash", hooks=[safety_check])
        ]
    }
)
```

### Hook Use Cases

1. **Security Controls**: Block dangerous commands
2. **Usage Tracking**: Monitor tool invocations
3. **Cost Management**: Rate limiting and budgets
4. **Quality Assurance**: Validate outputs
5. **Compliance**: Audit trails and logging

---

## MCP Integration Layer

### Model Context Protocol (MCP)

**Official Specification**: Based on TypeScript schema in `schema.ts`, available as JSON Schema for wider compatibility.[^18]

**Protocol Version**: Latest specification from March 26, 2025 with OAuth 2.1 authentication.[^19]

### MCP Capabilities

**Three Main Types**:[^20]

1. **Resources**: Information retrieval (databases, files)
   - Returns data, no side effects
   - Read-only operations

2. **Tools**: Actionable operations
   - Can perform calculations
   - API requests with side effects
   - State modifications

3. **Prompts**: Reusable templates
   - LLM-server communication patterns
   - Workflow templates

### Transport Layer

**Standard Mechanisms**:[^11]

```
stdio:      Client ←→ Server (same machine)
HTTP + SSE: Client ←→ Remote Server
```

**Selection Criteria**:
- Local integration → stdio (simple, effective)
- Remote services → HTTP + SSE (streaming support)

### Security Considerations

**Authentication** (March 2025 Update):[^19]
- Mandates OAuth 2.1 framework
- Secure authentication for remote HTTP servers
- Enhanced security and scalability

**Known Issues** (Security Research Findings):[^21]
- Prompt injection vulnerabilities
- Tool permission combining can exfiltrate files
- Lookalike tools can silently replace trusted ones

**Mitigation**:
- Hosts must obtain explicit user consent before tool invocation[^21]
- Write own MCP servers or use trusted providers[^22]
- Anthropic does not manage/audit MCP servers[^22]

### MCP Ecosystem

**Official Servers**:
- Slack, Salesforce, Gmail, PostgreSQL[^23]
- Google Drive, GitHub, Puppeteer[^24]

**Community Servers**:
- 500+ integrations in MCP Registry[^25]
- Curated lists on GitHub (awesome-mcp-servers)[^26]

**Major Adopters** (March 2025):[^27]
- OpenAI (ChatGPT desktop app integration)
- Google DeepMind
- Anthropic (Claude Desktop, Claude Code)

---

## Performance Optimizations

### Automatic Optimizations

**Built-in Features**:[^1]
- Automatic prompt caching
- Context compaction
- Long-run context control
- Performance monitoring

### Prompt Caching

**Cost Savings**: 90% savings on subsequent calls with same document[^8]

**Implementation**:
```python
# Automatic caching for repeated content
options = ClaudeAgentOptions(
    max_tokens=8192,  # Prevent excessive usage
    # Caching handled automatically by SDK
)
```

### Context Optimization

**Token Efficiency**:[^5]

The SDK handles token management with:
- Large context windows (200K tokens)[^4]
- Automatic summarization
- Selective content loading
- Intelligent compaction

**Best Practices**:
- Design concise tools
- Use context-aware prompts
- Enable auto-compaction
- Manual compact at task boundaries

### Performance Characteristics

**Model Comparison**:[^28]

| Model | Speed | Cost | Best For |
|-------|-------|------|----------|
| Sonnet | Optimal | $3/$15 | Most development tasks |
| Opus | Slower | 5x cost | Complex reasoning |
| Haiku | Fastest | Lowest | Simple operations |

**Sonnet Advantages**:[^28]
- Excellent speed-to-quality ratio
- Consistent response patterns
- 95% of Opus capabilities at 20% cost[^29]

### Scaling Optimizations

**Dynamic Model Routing**: 70% cost reduction while maintaining quality[^29]

**Parallel Tool Execution**: SDK supports concurrent tool calls for performance

**Subagent Parallelization**: Multiple agents executing simultaneously[^14]

---

## References

[^1]: Anthropic. "Agent SDK Overview." Claude Docs, 2025. https://docs.claude.com/en/api/agent-sdk/overview
[^2]: Anthropic. "Building agents with the Claude Agent SDK." Engineering Blog, 2025. https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk
[^3]: Sid Bharath. "Cooking with Claude Code: The Complete Guide." 2025. https://www.siddharthbharath.com/claude-code-the-complete-guide/
[^4]: Anthropic. "Introducing Claude 4." Anthropic News, 2025. https://www.anthropic.com/news/claude-4
[^5]: PromptLayer. "Building Agents with Claude Code's SDK." 2025. https://blog.promptlayer.com/building-agents-with-claude-codes-sdk/
[^6]: ClaudeLog. "What is Micro-Compact in Claude Code." 2025. https://claudelog.com/faqs/what-is-micro-compact/
[^7]: Forge Code. "Context Compaction." Documentation, 2025. https://forgecode.dev/docs/context-compaction/
[^8]: Cursor IDE. "Claude 4 Opus Pricing Guide 2025." 2025. https://www.cursor-ide.com/blog/claude-4-opus-pricing-guide-2025
[^9]: eesel AI. "A Practical Guide to the Python Claude Code SDK." 2025. https://www.eesel.ai/blog/python-claude-code-sdk
[^10]: Anthropic. "Building agents with the Claude Agent SDK." Tool Design, 2025. https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk
[^11]: Model Context Protocol. "Specification 2025-03-26." MCP Docs, 2025. https://modelcontextprotocol.io/specification/2025-03-26
[^12]: IBM. "What is Model Context Protocol (MCP)?" IBM Think, 2025. https://www.ibm.com/think/topics/model-context-protocol
[^13]: eesel AI. "A Practical Guide to the Python Claude Code SDK." Subagents, 2025. https://www.eesel.ai/blog/python-claude-code-sdk
[^14]: El-Balad. "Create Powerful Agents with Claude Agent SDK." 2025. https://el-balad.com/6723205
[^15]: eesel AI. "A Practical Guide to the Python Claude Code SDK." Case Study, 2025. https://www.eesel.ai/blog/python-claude-code-sdk
[^16]: Sid Bharath. "Cooking with Claude Code: The Complete Guide." Hooks, 2025. https://www.siddharthbharath.com/claude-code-the-complete-guide/
[^17]: PromptLayer. "Building Agents with Claude Code's SDK." Hooks, 2025. https://blog.promptlayer.com/building-agents-with-claude-codes-sdk/
[^18]: Model Context Protocol. "Specification." Technical Details, 2025. https://modelcontextprotocol.io/specification/
[^19]: Model Context Protocol. "Specification 2025-03-26." Security Update, 2025. https://modelcontextprotocol.io/specification/2025-03-26
[^20]: Descope. "What Is the Model Context Protocol (MCP) and How It Works." 2025. https://www.descope.com/learn/post/mcp
[^21]: Artificial Analysis. "Claude Security Explained." 2025. https://www.reco.ai/learn/claude-security
[^22]: Prefactor. "How to Secure Claude Code MCP Integrations in Production." 2025. https://prefactor.tech/blog/how-to-secure-claude-code-mcp-integrations-in-production
[^23]: GitHub. "Model Context Protocol Servers." Official Repository, 2025. https://github.com/modelcontextprotocol/servers
[^24]: Zapier. "7 Claude MCP servers you can set up right now." 2025. https://zapier.com/blog/claude-mcp-servers/
[^25]: Model Context Protocol. "Introducing the MCP Registry." MCP Blog, September 2025. http://blog.modelcontextprotocol.io/posts/2025-09-08-mcp-registry-preview/
[^26]: GitHub. "awesome-mcp-servers." Community Curated List, 2025. https://github.com/wong2/awesome-mcp-servers
[^27]: Wikipedia. "Model Context Protocol." Adoption Section, 2025. https://en.wikipedia.org/wiki/Model_Context_Protocol
[^28]: ClaudeLog. "Claude Code Performance Issues and Optimization." 2025. https://claudelog.com/faqs/claude-code-performance/
[^29]: Wandb. "Evaluating Claude 3.7 Sonnet." 2025. https://wandb.ai/byyoung3/Generative-AI/reports/Evaluating-Claude-3-7-Sonnet-Performance-reasoning-and-cost-optimization--VmlldzoxMTYzNDEzNQ

[**→ Complete Bibliography**](references.md)

[← Back to Documentation Index](index.md)
