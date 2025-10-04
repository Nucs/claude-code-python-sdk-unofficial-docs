# Getting Started - Claude Agent SDK

> **Installation, setup, and first steps**

[← Back to Index](index.md)

---

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Hello World Examples](#hello-world-examples)
5. [Common Setup Issues](#common-setup-issues)

---

## Prerequisites

### System Requirements

**Python SDK**:
- Python 3.10 or higher[^1]
- pip package manager
- Virtual environment (recommended)

**TypeScript SDK**:
- Node.js 18 or higher[^1]
- npm or yarn package manager

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

## Hello World Examples

### Example 1: Simple Query (Python)

```python
import anyio
from claude_agent_sdk import query

async def main():
    async for message in query(prompt="What is 2 + 2?"):
        print(message)

anyio.run(main)
```

**Output**:
```
2 + 2 equals 4.
```

### Example 2: Query with Options (Python)

```python
import anyio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
    options = ClaudeAgentOptions(
        system_prompt="You are a helpful Python expert",
        max_tokens=1024
    )

    async for message in query(
        prompt="Explain list comprehensions",
        options=options
    ):
        print(message)

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

```python
import anyio
from claude_agent_sdk import query, ClaudeAgentOptions

async def main():
    options = ClaudeAgentOptions(
        allowed_tools=["Read", "Write"],
        permission_mode='ask'  # Prompt for permission
    )

    async for msg in query(
        prompt="Create a file called hello.txt with 'Hello, World!'",
        options=options
    ):
        print(msg)

anyio.run(main)
```

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

### Example 8: Real-World Email Agent

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

### Example 9: Customer Support Shopify Integration

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

### Example 10: Document Generation Agent

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

---

## Next Steps

### Learn Core Concepts
- [Architecture](architecture.md) - Understanding the agent loop and internals
- [API Reference](api-reference.md) - Complete API documentation

### Build with Tools
- [Tools & MCP](tools-and-mcp.md) - Custom tools and MCP integration
- [Real-World Use Cases](real-world-use-cases.md) - Practical examples

### Deploy to Production
- [Production Patterns](production-patterns.md) - Enterprise deployment
- [Security](security.md) - Best practices and security

### Optimize Performance
- [Performance & Optimization](performance-optimization.md) - Benchmarks and cost

---

## Quick Start Checklist

- [ ] Install Python 3.10+ or Node.js 18+
- [ ] Install claude-agent-sdk package
- [ ] Set ANTHROPIC_API_KEY environment variable
- [ ] Run Hello World example
- [ ] Try query with options
- [ ] Create custom tool
- [ ] Explore [Real-World Use Cases](real-world-use-cases.md)
- [ ] Read [Architecture](architecture.md) guide
- [ ] Review [Security](security.md) best practices

---

## References

[^1]: GitHub. "Claude Agent SDK Python." Installation Requirements, 2025. https://github.com/anthropics/claude-agent-sdk-python
[^2]: DataCamp. "Claude Agent SDK Tutorial." Prerequisites, 2025. https://www.datacamp.com/tutorial/how-to-use-claude-agent-sdk
[^3]: DataCamp. "Claude Code: A Guide With Practical Examples." Billing Setup, 2025. https://www.datacamp.com/tutorial/claude-code
[^4]: Anthropic. "Building agents with the Claude Agent SDK." Email Agent Example, 2025. https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk
[^5]: eesel AI. "A Practical Guide to the Python Claude Code SDK." Custom Tools, 2025. https://www.eesel.ai/blog/python-claude-code-sdk
[^6]: Anthropic. "Building agents with the Claude Agent SDK." Document Generation, 2025. https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk

[**→ Complete Bibliography**](references.md)

[← Back to Index](index.md)
