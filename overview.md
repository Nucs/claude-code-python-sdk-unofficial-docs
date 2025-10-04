# Overview - Claude Agent SDK

> **Introduction, history, and fundamental concepts**

[← Back to Index](INDEX.md)

---

## Table of Contents

1. [What is Claude Agent SDK?](#what-is-claude-agent-sdk)
2. [History & Evolution](#history--evolution)
3. [Core Capabilities](#core-capabilities)
4. [Key Differentiators](#key-differentiators)
5. [Supported Platforms](#supported-platforms)
6. [Use Case Categories](#use-case-categories)

---

## What is Claude Agent SDK?

The **Claude Agent SDK** is a production-ready framework for building autonomous AI agents powered by Claude. It provides developers with the tools to create agents that can:

- **Interact with local environments** - Read/write files, execute commands, search codebases
- **Use custom tools** - Define Python or TypeScript functions for Claude to invoke
- **Maintain conversation context** - Stateful sessions across multiple interactions
- **Connect to external services** - Integrate with 500+ tools via Model Context Protocol (MCP)
- **Scale to enterprise deployments** - Fine-grained controls, security, and monitoring

### The Vision

Built on the same agent harness that powers Claude Code[^1], the SDK enables developers to create agents that don't just generate text—they autonomously complete complex, multi-step tasks.

**Fundamental Principle**: Give Claude access to a computer where it can write files, run commands, and iterate on its work.[^2]

---

## History & Evolution

### Timeline

**November 2024**: Model Context Protocol (MCP) announced[^3]
- Open protocol for LLM-tool integration
- Initial SDK release in Python and TypeScript
- Foundation for Claude Agent SDK

**September 2025**: Major expansion[^4]
- JetBrains integration announced
- MCP Registry launched
- 500+ server ecosystem established

**October 2025**: Claude Sonnet 4.5 & Agent SDK[^5]
- **77.2% SWE-bench Verified** score achieved
- SDK officially renamed from "Claude Code SDK" to "Claude Agent SDK"
- Reflects broader vision beyond just coding applications

**March 2025**: Protocol adoption milestone[^6]
- OpenAI adopts MCP (ChatGPT desktop app)
- Google DeepMind integration
- OAuth 2.1 authentication standard

### Naming Evolution

**Original Name**: Claude Code SDK
- Focused on coding applications
- Emphasized software development use cases

**Current Name**: Claude Agent SDK[^7]
- Reflects broader capabilities
- Includes non-coding applications (research, content, business processes)
- "At Anthropic, we've used it for deep research, video creation, and note-taking, among countless other non-coding applications."[^2]

### Key Milestones

| Date | Milestone | Significance |
|------|-----------|--------------|
| Nov 2024 | MCP Protocol Launch | Foundation for agent ecosystem |
| May 2025 | Claude Code 1.0 | Initial public release |
| Aug 2025 | 10x Usage Growth | Mainstream adoption begins[^8] |
| Sep 2025 | JetBrains Integration | IDE ecosystem expansion[^4] |
| Oct 2025 | SDK Rename | Broader vision recognition[^7] |
| Mar 2025 | OpenAI Adoption | Industry standard status[^6] |

---

## Core Capabilities

### 1. Local Environment Interaction

**File Operations**:
- Read, write, and edit files
- Search codebases with grep/glob
- Navigate directory structures

**Command Execution**:
- Run bash commands and scripts
- Execute tests and build processes
- Interact with development tools

**Example**:
```python
from claude_agent_sdk import query, ClaudeAgentOptions

options = ClaudeAgentOptions(
    allowed_tools=["Read", "Write", "Bash", "Grep"],
    permission_mode='acceptEdits'
)

async for msg in query("Refactor auth.py to use async/await", options=options):
    print(msg)
```

### 2. Custom Tool Development

**In-Process Tools**: Python functions decorated with `@tool` run directly in your application[^9]

**Example**:
```python
from claude_agent_sdk import tool, create_sdk_mcp_server

@tool("calculate", "Perform calculations", {"expression": str})
async def calculate(args):
    result = eval(args["expression"])
    return {"content": [{"type": "text", "text": f"Result: {result}"}]}
```

### 3. Model Context Protocol (MCP)

**500+ Integrations** available through MCP servers[^10]:
- **Productivity**: Slack, Gmail, Notion, Google Drive
- **Development**: GitHub, GitLab, Jira, Linear
- **Data**: PostgreSQL, MongoDB, Salesforce, HubSpot
- **Cloud**: AWS, GCP, Azure services
- **Business**: Shopify, Stripe, Airtable

### 4. Context Management

**Automatic Compaction** ensures agents don't run out of context[^1]:
- **Micro-Compact**: Selective tool call removal[^11]
- **Auto-Compact**: Full summarization at 95% capacity[^12]
- **Manual Compact**: User-triggered optimization

**200K Token Context Window** (Claude 4)[^13] with intelligent management

### 5. Subagent Architecture

**Parallelization**: Multiple subagents for concurrent tasks[^14]

**Context Isolation**: Each subagent has independent context window[^14]

**Example**: 7-agent documentation pipeline built in minutes[^15]

### 6. Hook System

**Safety Controls** via event interception[^16]:
- PreToolUse: Validate before execution
- PostToolUse: Process results
- UserPromptSubmit: Filter inputs

**Example**:
```python
async def safety_check(input_data, tool_use_id, context):
    if is_dangerous(input_data["tool_input"]):
        return {
            "hookSpecificOutput": {
                "permissionDecision": "deny",
                "permissionDecisionReason": "Blocked dangerous operation"
            }
        }
    return {}
```

---

## Key Differentiators

### vs. Traditional Chatbots

| Feature | Chatbot | Claude Agent SDK |
|---------|---------|------------------|
| **Interaction** | Text only | Text + Actions |
| **Environment** | Isolated | Local file system access |
| **Tools** | None | Custom + 500+ MCP |
| **Context** | Per-session | Persistent + Compaction |
| **Autonomy** | Single response | Multi-step workflows |
| **Production** | Limited | Enterprise-ready |

### vs. Other Agent Frameworks

**Advantages**:
- ✅ **Built by Anthropic**: Same foundation as Claude Code
- ✅ **Production-Ready**: Automatic context management, error handling
- ✅ **Rich Ecosystem**: 500+ MCP servers, growing community
- ✅ **Enterprise Features**: Security controls, monitoring, compliance
- ✅ **Proven Performance**: 77.2% SWE-bench score[^5], $500M+ revenue[^8]

**Trade-offs**:
- Requires Anthropic API key
- Claude-specific (not model-agnostic)
- Python/TypeScript only (not all languages)

### Unique Features

1. **Agent Harness Foundation**: Same core as Claude Code CLI[^1]
2. **Automatic Compaction**: Unique context management system[^11]
3. **In-Process MCP**: Tools run in your app, no separate processes[^9]
4. **Extended Thinking**: Claude Sonnet 4.5 reasoning capabilities[^5]
5. **Project Context**: CLAUDE.md integration for domain knowledge[^17]

---

## Supported Platforms

### SDKs Available

**Python SDK** (3.10+):
```bash
pip install claude-agent-sdk
```
- Repository: https://github.com/anthropics/claude-agent-sdk-python
- License: MIT

**TypeScript SDK** (Node.js 18+):
```bash
npm install @anthropic-ai/claude-agent-sdk
```
- Repository: https://github.com/anthropics/claude-agent-sdk-typescript
- License: MIT

### Integration Platforms

**IDEs**:
- JetBrains (IntelliJ, PyCharm, WebStorm)[^4]
- VS Code (via Claude Code extension)

**Desktop Apps**:
- Claude Desktop (macOS, Windows)
- Standalone applications

**CI/CD**:
- GitHub Actions workflows[^18]
- Custom automation pipelines

### Operating Systems

- **macOS**: Full support, native integration
- **Linux**: Full support via terminal
- **Windows**: Full support (WSL or native)

---

## Use Case Categories

### 1. Development & DevOps

**SRE Agents**: Diagnose and fix production issues[^19]
- **Performance**: 3x faster incident resolution[^20]
- **Example**: Stack trace analysis, log investigation

**Code Review Bots**: Audit code for vulnerabilities[^19]
- **Results**: Found RCE vulnerability in Anthropic code[^21]
- **Features**: Security pattern detection, remediation guidance

**Engineering Automation**: Refactoring, testing, documentation[^19]
- **Adoption**: 90%+ of Anthropic engineers for git operations[^22]
- **Efficiency**: Issue-to-PR automation with 70% improvement[^23]

### 2. Business Applications

**Customer Support**: Resolve technical issues[^19]
- **Example**: Shopify order lookup integration
- **Capability**: Access internal systems, escalate to humans

**Finance Agents**: Portfolio analysis, investment evaluation[^24]
- **Application**: Risk assessment, structured products
- **Quality**: Investment-grade insights[^25]

**Legal Assistants**: Contract review, compliance[^19]
- **Implementation**: Harvey legal AI platform[^26]
- **Output**: Excellent first drafts for litigation

### 3. Security & Compliance

**Red Teaming**: Attack scenario generation[^27]
- **User**: CrowdStrike cybersecurity
- **Benefit**: Accelerates attacker tradecraft study

**Vulnerability Management**: Automated intake and analysis[^28]
- **Performance**: 44% faster processing, 25% more accurate
- **User**: Hai security platform

### 4. Content & Research

**Research Agents**: Information gathering and synthesis[^2]
- **Internal Use**: Anthropic research teams
- **Capability**: Multi-source analysis, citation tracking

**Content Creation**: Automated writing workflows[^29]
- **Performance**: 78% time reduction (23h → 5h)
- **Pipeline**: Research → Draft → Edit automation

**Video Production**: Creative content assistance[^2]
- **Application**: Anthropic video team workflows

### 5. Data & Analytics

**Jupyter Notebooks**: Data exploration automation[^30]
- **Capability**: Read/write notebooks, interpret visuals
- **Benefit**: Fast iteration cycles

**Business Intelligence**: Report generation, insights[^31]
- **Example**: Ad variation generation (100s in minutes)
- **Team**: Anthropic growth marketing

---

## Getting Started

### Quick Start

1. **Install SDK**:
   ```bash
   pip install claude-agent-sdk
   ```

2. **Set API Key**:
   ```bash
   export ANTHROPIC_API_KEY='your-key'
   ```

3. **Run First Agent**:
   ```python
   import anyio
   from claude_agent_sdk import query

   async def main():
       async for msg in query(prompt="What is 2 + 2?"):
           print(msg)

   anyio.run(main)
   ```

[See: Getting Started](getting-started.md) for detailed setup

### Next Steps

- **Learn Core Concepts**: [Architecture](architecture.md)
- **Explore API**: [API Reference](api-reference.md)
- **Build Tools**: [Tools & MCP](tools-and-mcp.md)
- **See Examples**: [Real-World Use Cases](real-world-use-cases.md)
- **Deploy Production**: [Production Patterns](production-patterns.md)

---

## References

[^1]: Anthropic. "Agent SDK Overview." Claude Docs, 2025. https://docs.claude.com/en/api/agent-sdk/overview
[^2]: Anthropic. "Building agents with the Claude Agent SDK." Engineering Blog, 2025. https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk
[^3]: Anthropic. "Introducing the Model Context Protocol." Anthropic News, November 2024. https://www.anthropic.com/news/model-context-protocol
[^4]: JetBrains. "Introducing Claude Agent in JetBrains IDEs." JetBrains Blog, September 2025. https://blog.jetbrains.com/ai/2025/09/introducing-claude-agent-in-jetbrains-ides/
[^5]: Anthropic. "Introducing Claude Sonnet 4.5." Anthropic News, October 2025. https://www.anthropic.com/news/claude-sonnet-4-5
[^6]: Wikipedia. "Model Context Protocol." Adoption Section, 2025. https://en.wikipedia.org/wiki/Model_Context_Protocol
[^7]: eesel AI. "A Practical Guide to the Python Claude Code SDK (now agent SDK) in 2025." 2025. https://www.eesel.ai/blog/python-claude-code-sdk
[^8]: Gergely Orosz. "How Claude Code is Built." Pragmatic Engineer Newsletter, 2025. https://newsletter.pragmaticengineer.com/p/how-claude-code-is-built
[^9]: eesel AI. "A Practical Guide to the Python Claude Code SDK." Custom Tools, 2025. https://www.eesel.ai/blog/python-claude-code-sdk
[^10]: Model Context Protocol. "Introducing the MCP Registry." MCP Blog, September 2025. http://blog.modelcontextprotocol.io/posts/2025-09-08-mcp-registry-preview/
[^11]: ClaudeLog. "What is Micro-Compact in Claude Code." 2025. https://claudelog.com/faqs/what-is-micro-compact/
[^12]: Forge Code. "Context Compaction." Documentation, 2025. https://forgecode.dev/docs/context-compaction/
[^13]: Anthropic. "Introducing Claude 4." Anthropic News, 2025. https://www.anthropic.com/news/claude-4
[^14]: El-Balad. "Create Powerful Agents with Claude Agent SDK." Subagents, 2025. https://el-balad.com/6723205
[^15]: eesel AI. "A Practical Guide to the Python Claude Code SDK." Case Study, 2025. https://www.eesel.ai/blog/python-claude-code-sdk
[^16]: Sid Bharath. "Cooking with Claude Code: The Complete Guide." Hooks, 2025. https://www.siddharthbharath.com/claude-code-the-complete-guide/
[^17]: Sid Bharath. "Cooking with Claude Code: The Complete Guide." CLAUDE.md, 2025. https://www.siddharthbharath.com/claude-code-the-complete-guide/
[^18]: SmartScope Blog. "AI Agent Development Practical Guide August 2025." GitHub Actions, August 2025. https://smartscope.blog/en/ai-development/ai-agent-development-practical-implementation-deep-dive-august2025/
[^19]: Anthropic. "Building agents with the Claude Agent SDK." Agent Types, 2025. https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk
[^20]: Anthropic. "How Anthropic Teams Use Claude Code." Security Engineering, 2025. https://www.anthropic.com/news/how-anthropic-teams-use-claude-code
[^21]: StackHawk. "A Developer's Guide to Writing Secure Code with Claude Code." 2025. https://www.stackhawk.com/blog/developers-guide-to-writing-secure-code-with-claude-code/
[^22]: Anthropic. "How Anthropic Teams Use Claude Code." Git Operations, 2025. https://www.anthropic.com/news/how-anthropic-teams-use-claude-code
[^23]: SmartScope Blog. "AI Agent Development Practical Guide August 2025." Performance Metrics, August 2025. https://smartscope.blog/en/ai-development/ai-agent-development-practical-implementation-deep-dive-august2025/
[^24]: Anthropic. "Building agents with the Claude Agent SDK." Financial Agents, 2025. https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk
[^25]: Anthropic. "Introducing Claude Sonnet 4.5." Financial Analysis, October 2025. https://www.anthropic.com/news/claude-sonnet-4-5
[^26]: Anthropic. "Introducing Claude Sonnet 4.5." Harvey Testimonial, October 2025. https://www.anthropic.com/news/claude-sonnet-4-5
[^27]: Anthropic. "Introducing Claude Sonnet 4.5." CrowdStrike, October 2025. https://www.anthropic.com/news/claude-sonnet-4-5
[^28]: Anthropic. "Introducing Claude Sonnet 4.5." Hai Performance, October 2025. https://www.anthropic.com/news/claude-sonnet-4-5
[^29]: eesel AI. "A Practical Guide to the Python Claude Code SDK." Content Creation, 2025. https://www.eesel.ai/blog/python-claude-code-sdk
[^30]: Anthropic. "How Anthropic Teams Use Claude Code." Research Teams, 2025. https://www.anthropic.com/news/how-anthropic-teams-use-claude-code
[^31]: Anthropic. "How Anthropic Teams Use Claude Code." Growth Marketing, 2025. https://www.anthropic.com/news/how-anthropic-teams-use-claude-code

[**→ Complete Bibliography**](references.md)

[← Back to Index](INDEX.md)
