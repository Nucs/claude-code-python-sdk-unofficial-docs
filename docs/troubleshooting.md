# Troubleshooting - Claude Agent SDK

> **Common issues, debugging techniques, and solutions for Claude Agent SDK**

[← Back to Documentation Index](index.md)

---

## Table of Contents

1. [Common Installation Issues](#common-installation-issues)
2. [Runtime Errors](#runtime-errors)
3. [Tool Execution Problems](#tool-execution-problems)
4. [Performance Issues](#performance-issues)
5. [MCP Server Troubleshooting](#mcp-server-troubleshooting)
6. [Debugging Techniques](#debugging-techniques)
7. [Error Reference](#error-reference)

---

## Common Installation Issues

### Issue 1: Module Import Error

**Error**:
```python
ImportError: No module named 'claude_agent_sdk'
```

**Cause**: Package not installed or wrong Python environment

**Solutions**:

1. **Verify Installation**:
```bash
pip list | grep claude
# Should show: claude-agent-sdk
```

2. **Check for Old Package Name**:
```bash
# Uninstall old package
pip uninstall claude-code-sdk

# Install current package
pip install claude-agent-sdk
```

3. **Verify Python Version**:
```bash
python --version
# Must be Python 3.10 or higher
```

4. **Use Correct Python Executable**:
```bash
# If using multiple Python installations
python3 -m pip install claude-agent-sdk
python3 your_script.py
```

5. **Virtual Environment Issues**:
```bash
# Ensure virtual environment is activated
source venv/bin/activate  # macOS/Linux
venv\Scripts\activate     # Windows

# Install in active environment
pip install claude-agent-sdk
```

### Issue 2: API Key Not Found

**Error**:
```
Error: ANTHROPIC_API_KEY environment variable not set
```

**Cause**: API key not configured in environment

**Solutions**:

1. **Check Environment Variable**:
```bash
# macOS/Linux
echo $ANTHROPIC_API_KEY

# Windows PowerShell
$env:ANTHROPIC_API_KEY

# Windows CMD
echo %ANTHROPIC_API_KEY%
```

2. **Set for Current Session**:
```bash
# macOS/Linux
export ANTHROPIC_API_KEY='your-api-key-here'

# Windows PowerShell
$env:ANTHROPIC_API_KEY='your-api-key-here'

# Windows CMD
set ANTHROPIC_API_KEY=your-api-key-here
```

3. **Set Permanently**:
```bash
# macOS/Linux (add to ~/.bashrc or ~/.zshrc)
echo 'export ANTHROPIC_API_KEY="your-api-key"' >> ~/.bashrc
source ~/.bashrc

# Windows PowerShell (permanent)
[System.Environment]::SetEnvironmentVariable('ANTHROPIC_API_KEY', 'your-api-key', 'User')
```

4. **Use .env File**:
```bash
# Install python-dotenv
pip install python-dotenv

# Create .env file
echo 'ANTHROPIC_API_KEY=your-api-key' > .env
```

```python
# Load in Python
from dotenv import load_dotenv
load_dotenv()
```

5. **Verify in Python**:
```python
import os
print(os.environ.get('ANTHROPIC_API_KEY'))
# Should print your API key
```

### Issue 3: Async Runtime Error

**Error**:
```
RuntimeError: asyncio.run() cannot be called from a running event loop
```

**Cause**: Trying to use `asyncio.run()` in an environment with existing event loop (Jupyter, IPython)

**Solutions**:

1. **Use anyio (Recommended)**:
```python
import anyio

async def main():
    # Your async code
    pass

anyio.run(main)  # Works in all environments
```

2. **In Jupyter/IPython**:
```python
# Just use await directly
await main()
# No need for asyncio.run() or anyio.run()
```

3. **Install anyio**:
```bash
pip install anyio
```

4. **Detect Environment**:
```python
import asyncio

async def main():
    # Your code
    pass

try:
    # Try direct await first (Jupyter)
    await main()
except RuntimeError:
    # Fall back to anyio
    import anyio
    anyio.run(main)
```

---

## Runtime Errors

### Issue 4: Permission Denied for Tool

**Error**:
```
Error: Permission denied for tool execution: Write
```

**Cause**: Tool not in allowed list or wrong permission mode

**Solutions**:

1. **Check Allowed Tools**:
```python
options = ClaudeAgentOptions(
    allowed_tools=["Read", "Write", "Bash"],  # Must include tool
    permission_mode='ask'
)
```

2. **Adjust Permission Mode**:
```python
# Option 1: Ask for permission (default)
options = ClaudeAgentOptions(
    permission_mode='ask'
)

# Option 2: Auto-accept file edits
options = ClaudeAgentOptions(
    permission_mode='acceptEdits'
)

# Option 3: Auto-accept all (use with caution)
options = ClaudeAgentOptions(
    permission_mode='acceptAll'
)
```

3. **Check Hook Blocking**:
```python
# Hooks may deny permission
async def permissive_hook(input_data, tool_use_id, context):
    return {}  # Allow (empty response)

options = ClaudeAgentOptions(
    hooks={
        "PreToolUse": [HookMatcher(matcher="*", hooks=[permissive_hook])]
    }
)
```

### Issue 5: Context Length Exceeded

**Error**:
```
Error: Maximum context length exceeded (200000 tokens)
```

**Cause**: Conversation or tool results too large

**Solutions**:

1. **Reduce max_tokens**:
```python
options = ClaudeAgentOptions(
    max_tokens=4096  # Lower response limit
)
```

2. **Limit Conversation Turns**:
```python
options = ClaudeAgentOptions(
    max_turns=20  # Trigger compaction sooner
)
```

3. **Manual Compaction**:
```python
async with ClaudeSDKClient(options=options) as client:
    await client.query("First task")
    # ... many operations ...

    # Force compaction
    await client.query("/compact")

    await client.query("Next task")
```

4. **Design Concise Tools**:
```python
@tool("summary", "Get summary", {"topic": str})
async def get_summary(args):
    full_data = fetch_data(args["topic"])

    # Return summary, not full content
    summary = summarize(full_data)

    return {
        "content": [{
            "type": "text",
            "text": summary
        }]
    }
```

5. **Use Smaller Scope**:
```python
# ❌ Too broad
await client.query("Read all files and analyze")

# ✅ Targeted
await client.query("Read only auth-related files and analyze")
```

### Issue 6: Rate Limit Error

**Error**:
```
RateLimitError: API rate limit exceeded
```

**Cause**: Too many requests in short time

**Solutions**:

1. **Implement Retry with Backoff**:
```python
import asyncio
from claude_agent_sdk.errors import RateLimitError

async def query_with_retry(prompt: str, max_retries: int = 3):
    for attempt in range(max_retries):
        try:
            async with ClaudeSDKClient(options=options) as client:
                await client.query(prompt)

                result = []
                async for msg in client.receive_response():
                    result.append(msg)

                return "".join(result)

        except RateLimitError:
            if attempt < max_retries - 1:
                wait_time = 2 ** attempt  # Exponential backoff
                await asyncio.sleep(wait_time)
                continue
            raise
```

2. **Add Rate Limiting**:
```python
import time

class RateLimiter:
    def __init__(self, requests_per_minute: int = 50):
        self.rpm = requests_per_minute
        self.requests = []

    async def acquire(self):
        now = time.time()
        # Remove old requests
        self.requests = [r for r in self.requests if now - r < 60]

        if len(self.requests) >= self.rpm:
            sleep_time = 60 - (now - self.requests[0])
            await asyncio.sleep(sleep_time)

        self.requests.append(now)

# Usage
limiter = RateLimiter(requests_per_minute=50)
await limiter.acquire()
# Then make request
```

---

## Tool Execution Problems

### Issue 7: File Not Found (Read/Write)

**Error**:
```
FileNotFoundError: [Errno 2] No such file or directory: 'config.json'
```

**Cause**: Relative path used without proper working directory

**Solutions**:

1. **Use Absolute Paths**:
```python
import os

# Get absolute path
file_path = os.path.abspath("config.json")

await client.query(f"Read {file_path}")
```

2. **Set Working Directory**:
```python
options = ClaudeAgentOptions(
    cwd="/path/to/project",  # Set working directory
    allowed_tools=["Read", "Write"]
)
```

3. **Verify File Exists**:
```python
import os

if os.path.exists("config.json"):
    await client.query("Read config.json")
else:
    print("File not found!")
```

### Issue 8: Edit Tool Fails

**Error**:
```
Error: old_string not found in file
```

**Cause**: String mismatch or non-unique match

**Solutions**:

1. **Ensure Exact Match**:
```python
# Read file first to see exact content
await client.query("Read config.py")

# Then edit with exact string
await client.query("""
In config.py, replace:
    DEBUG = False
with:
    DEBUG = True
""")
```

2. **Use Replace All for Multiple Matches**:
```python
# If string appears multiple times
await client.query("""
Replace all occurrences of 'old_value' with 'new_value' in config.py
""")
```

3. **Include More Context**:
```python
# ❌ Ambiguous
await client.query("Change 'value' to 'new_value'")

# ✅ Specific with context
await client.query("""
In section [database], change:
    host = value
to:
    host = new_value
""")
```

### Issue 9: Bash Command Fails

**Error**:
```
bash: command not found: npm
```

**Cause**: Command not available in PATH or wrong environment

**Solutions**:

1. **Verify Command Exists**:
```bash
which npm
# Should show path to npm
```

2. **Use Full Path**:
```python
await client.query("Run /usr/local/bin/npm install")
```

3. **Set Environment Variables**:
```python
options = ClaudeAgentOptions(
    allowed_tools=["Bash"],
    # Note: env not directly supported in ClaudeAgentOptions
    # Use MCP server with env configuration
)
```

4. **Check Working Directory**:
```python
# Set correct directory
options = ClaudeAgentOptions(
    cwd="/path/to/project"
)

await client.query("Run npm install")
```

---

## Performance Issues

### Issue 10: Slow Response Times

**Symptoms**: Queries take > 30 seconds

**Causes & Solutions**:

1. **Large Context**:
```python
# Check context size
# If > 100K tokens, reduce scope

# ✅ Compact context
await client.query("/compact")
```

2. **Complex Model**:
```python
# Switch to faster model
options = ClaudeAgentOptions(
    model="claude-haiku-4"  # Fastest model
)
```

3. **Large Tool Results**:
```python
# ❌ Returns 100K tokens
await client.query("Read all log files")

# ✅ Summarize results
await client.query("Summarize errors from log files")
```

### Issue 11: High Token Usage

**Symptoms**: Unexpected costs, rapid token consumption

**Solutions**:

1. **Use Prompt Caching**:
```python
options = ClaudeAgentOptions(
    system_prompt="""
    <stable_context>
    # Large unchanging context here
    </stable_context>
    """
)
# 90% savings on subsequent requests
```

2. **Optimize Prompts**:
```python
# ❌ Verbose (200 tokens)
await client.query("""
Could you please carefully review the authentication
implementation and let me know if there are any issues...
""")

# ✅ Concise (30 tokens)
await client.query("Review auth implementation for issues")
```

3. **Limit Response Length**:
```python
options = ClaudeAgentOptions(
    max_tokens=1024  # Cap response size
)
```

---

## MCP Server Troubleshooting

### Issue 12: MCP Server Not Found

**Error**:
```
Error: MCP server 'myserver' not found
```

**Cause**: Server not registered in options

**Solutions**:

1. **Register MCP Server**:
```python
from claude_agent_sdk import create_sdk_mcp_server, tool

@tool("mytool", "Description", {"param": str})
async def mytool(args):
    return {"content": [{"type": "text", "text": "Result"}]}

server = create_sdk_mcp_server("myserver", "1.0.0", [mytool])

options = ClaudeAgentOptions(
    mcp_servers={"myserver": server},  # Must register
    allowed_tools=["mcp__myserver__mytool"]
)
```

2. **Check Server Name**:
```python
# Server names must match exactly
mcp_servers={"myserver": server}  # Server name
allowed_tools=["mcp__myserver__mytool"]  # Must use same name
```

### Issue 13: External MCP Server Connection Failed

**Error**:
```
Error: Failed to connect to MCP server
```

**Cause**: External server not running or wrong configuration

**Solutions**:

1. **Verify Server Command**:
```python
options = ClaudeAgentOptions(
    mcp_servers={
        "github": {
            "command": "npx",  # Correct command
            "args": ["-y", "@modelcontextprotocol/server-github"],
            "env": {"GITHUB_TOKEN": os.environ["GITHUB_TOKEN"]}
        }
    }
)
```

2. **Test Server Manually**:
```bash
# Run server command directly to test
npx -y @modelcontextprotocol/server-github

# Should start without errors
```

3. **Check Environment Variables**:
```python
# Verify required env vars exist
if "GITHUB_TOKEN" not in os.environ:
    print("GITHUB_TOKEN not set!")

options = ClaudeAgentOptions(
    mcp_servers={
        "github": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-github"],
            "env": {
                "GITHUB_TOKEN": os.environ.get("GITHUB_TOKEN", "")
            }
        }
    }
)
```

### Issue 14: MCP Tool Not Recognized

**Error**:
```
Error: Tool 'mcp__server__tool' not allowed
```

**Cause**: Tool not in allowed_tools list

**Solutions**:

1. **Add Tool to Allowed List**:
```python
options = ClaudeAgentOptions(
    allowed_tools=[
        "Read",
        "Write",
        "mcp__github__create_issue",  # Must include MCP tools
        "mcp__database__query"
    ]
)
```

2. **Use Wildcard for All Server Tools**:
```python
options = ClaudeAgentOptions(
    allowed_tools=[
        "Read",
        "mcp__github__*"  # Allow all GitHub tools
    ]
)
```

---

## Debugging Techniques

### Hook-Based Debugging

**Log All Tool Executions**:
```python
from claude_agent_sdk import HookMatcher
import json

async def debug_hook(input_data, tool_use_id, context):
    print("=== TOOL EXECUTION ===")
    print(f"Tool: {input_data['tool_name']}")
    print(f"Input: {json.dumps(input_data['tool_input'], indent=2)}")
    print(f"Tool Use ID: {tool_use_id}")
    print("=" * 20)
    return {}

options = ClaudeAgentOptions(
    hooks={
        "PreToolUse": [HookMatcher(matcher="*", hooks=[debug_hook])]
    }
)
```

**Log Tool Results**:
```python
async def result_hook(input_data, tool_use_id, context):
    print("=== TOOL RESULT ===")
    print(f"Tool Use ID: {tool_use_id}")
    print(f"Success: {not context.get('is_error', False)}")
    if context.get('result'):
        print(f"Result: {context['result'][:200]}...")  # First 200 chars
    print("=" * 20)
    return {}

options = ClaudeAgentOptions(
    hooks={
        "PostToolUse": [HookMatcher(matcher="*", hooks=[result_hook])]
    }
)
```

### Response Streaming Debugging

**Capture All Response Chunks**:
```python
async with ClaudeSDKClient(options=options) as client:
    await client.query("Your query here")

    chunks = []
    async for msg in client.receive_response():
        print(f"Chunk: {repr(msg)}")  # Debug each chunk
        chunks.append(msg)

    full_response = "".join(chunks)
    print(f"Full response length: {len(full_response)}")
```

### Error Stack Traces

**Enable Detailed Error Logging**:
```python
import logging

# Set up detailed logging
logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Now errors will show full stack traces
try:
    async with ClaudeSDKClient(options=options) as client:
        await client.query("Your query")
        async for msg in client.receive_response():
            print(msg)
except Exception as e:
    logging.exception("Error occurred:")
    # Shows full stack trace
```

---

## Error Reference

### Authentication Errors

**AuthenticationError**:
```python
from claude_agent_sdk.errors import AuthenticationError

try:
    client = ClaudeSDKClient()
except AuthenticationError:
    print("Invalid API key - check ANTHROPIC_API_KEY")
```

### API Errors

**APIError** (General API failure):
```python
from claude_agent_sdk.errors import APIError

try:
    async for msg in query("Hello"):
        print(msg)
except APIError as e:
    print(f"API Error: {e}")
    # Check API status or retry
```

**RateLimitError** (Too many requests):
```python
from claude_agent_sdk.errors import RateLimitError
import time

try:
    async for msg in query("Hello"):
        print(msg)
except RateLimitError:
    print("Rate limited - waiting 60 seconds")
    time.sleep(60)
    # Retry request
```

**ContextLengthExceededError** (Context too large):
```python
from claude_agent_sdk.errors import ContextLengthExceededError

try:
    async for msg in query("Long prompt..."):
        print(msg)
except ContextLengthExceededError:
    print("Context too long - use compaction or reduce scope")
```

### Tool Errors

**ToolExecutionError** (Tool failed):
```python
# Returned in tool response with isError=True
{
    "content": [{"type": "text", "text": "Error message"}],
    "isError": True
}
```

### Debug Checklist

When encountering issues, verify:

1. **✅ API Key**: `echo $ANTHROPIC_API_KEY` shows valid key
2. **✅ Installation**: `pip list | grep claude-agent-sdk` shows package
3. **✅ Python Version**: `python --version` shows 3.10+
4. **✅ Allowed Tools**: Tools are in `allowed_tools` list
5. **✅ Permission Mode**: Set appropriately for use case
6. **✅ Working Directory**: `cwd` set correctly for file operations
7. **✅ MCP Servers**: Registered in `mcp_servers` dict
8. **✅ Environment**: Virtual environment activated
9. **✅ Hooks**: Not blocking required operations
10. **✅ Context Size**: Not exceeding 200K tokens

### Getting Help

**Resources**:
- GitHub Issues: https://github.com/anthropics/claude-agent-sdk-python/issues
- Discord: https://discord.gg/anthropic
- Documentation: https://docs.claude.com/en/docs/claude-code
- Stack Overflow: Tag `claude-agent-sdk`

**Issue Template**:
```markdown
## Environment
- Python version: 3.11
- claude-agent-sdk version: 1.0.0
- OS: macOS 14.0

## Issue Description
[Clear description of the problem]

## Steps to Reproduce
1. [First step]
2. [Second step]

## Expected Behavior
[What should happen]

## Actual Behavior
[What actually happens]

## Code Sample
```python
# Minimal reproducible example
```

## Error Message
```
[Full error message and stack trace]
```
```

---

## References

[^1]: GitHub. "Claude Agent SDK Issues." Troubleshooting Guide, 2025. https://github.com/anthropics/claude-agent-sdk-python/issues
[^2]: Stack Overflow. "Claude Agent SDK Questions." Community Support, 2025. https://stackoverflow.com/questions/tagged/claude-agent-sdk
[^3]: DataCamp. "Claude Agent SDK Tutorial." Common Issues, 2025. https://www.datacamp.com/tutorial/how-to-use-claude-agent-sdk
[^4]: Anthropic Discord. "Community Support Channel." Real-time Help, 2025. https://discord.gg/anthropic
[^5]: Claude Docs. "Troubleshooting Guide." Official Documentation, 2025. https://docs.claude.com/en/docs/claude-code/troubleshooting

[**→ Complete Bibliography**](references.md)

[← Back to Documentation Index](index.md)
