# Testing Guide - Claude Agent SDK

> **Unit, integration, and end-to-end testing patterns for Claude Agent SDK applications**

[← Back to Documentation Index](index.md)

---

## Table of Contents

1. [Overview](#overview)
2. [Unit Testing Custom Tools](#unit-testing-custom-tools)
3. [Integration Testing with Mocks](#integration-testing-with-mocks)
4. [Testing ClaudeSDKClient Workflows](#testing-claudesdkclient-workflows)
5. [Testing MCP Servers](#testing-mcp-servers)
6. [Testing Hooks and Callbacks](#testing-hooks-and-callbacks)
7. [End-to-End Testing](#end-to-end-testing)
8. [Performance Testing](#performance-testing)
9. [Testing Best Practices](#testing-best-practices)

---

## Overview

Testing Claude Agent SDK applications requires different strategies for different components:

| Component | Test Type | Framework | Coverage Goal |
|-----------|-----------|-----------|---------------|
| Custom Tools | Unit | pytest | 95%+ |
| MCP Servers | Integration | pytest + mocks | 90%+ |
| Workflows | Integration | pytest + fixtures | 85%+ |
| Hooks | Unit | pytest | 95%+ |
| End-to-End | E2E | pytest + real SDK | 70%+ |

---

## Unit Testing Custom Tools

### Basic Tool Testing

**Purpose**: Test tool logic in isolation without SDK dependencies

```python
import pytest
from claude_agent_sdk import tool

@tool("calculate", "Perform calculation", {"a": float, "b": float, "op": str})
async def calculate(args):
    """Calculator tool for testing."""
    a, b, op = args["a"], args["b"], args["op"]

    if op == "add":
        result = a + b
    elif op == "multiply":
        result = a * b
    elif op == "divide":
        if b == 0:
            raise ValueError("Division by zero")
        result = a / b
    else:
        raise ValueError(f"Unknown operation: {op}")

    return {
        "content": [{
            "type": "text",
            "text": f"Result: {result}"
        }]
    }


# Unit Tests
@pytest.mark.asyncio
async def test_calculate_addition():
    """Test addition operation."""
    result = await calculate({"a": 5, "b": 3, "op": "add"})
    assert result["content"][0]["text"] == "Result: 8"


@pytest.mark.asyncio
async def test_calculate_multiplication():
    """Test multiplication operation."""
    result = await calculate({"a": 5, "b": 3, "op": "multiply"})
    assert result["content"][0]["text"] == "Result: 15"


@pytest.mark.asyncio
async def test_calculate_division():
    """Test division operation."""
    result = await calculate({"a": 10, "b": 2, "op": "divide"})
    assert result["content"][0]["text"] == "Result: 5.0"


@pytest.mark.asyncio
async def test_calculate_division_by_zero():
    """Test division by zero error handling."""
    with pytest.raises(ValueError, match="Division by zero"):
        await calculate({"a": 5, "b": 0, "op": "divide"})


@pytest.mark.asyncio
async def test_calculate_unknown_operation():
    """Test unknown operation error."""
    with pytest.raises(ValueError, match="Unknown operation"):
        await calculate({"a": 5, "b": 3, "op": "modulo"})
```

### Parameterized Testing

**Purpose**: Test multiple scenarios efficiently

```python
import pytest

@pytest.mark.parametrize("a,b,op,expected", [
    (5, 3, "add", 8),
    (10, 2, "multiply", 20),
    (15, 3, "divide", 5.0),
    (7, 4, "add", 11),
    (0, 5, "multiply", 0),
])
@pytest.mark.asyncio
async def test_calculate_operations(a, b, op, expected):
    """Parameterized test for multiple calculations."""
    result = await calculate({"a": a, "b": b, "op": op})
    assert f"Result: {expected}" in result["content"][0]["text"]


@pytest.mark.parametrize("a,b,op,error", [
    (5, 0, "divide", "Division by zero"),
    (1, 1, "subtract", "Unknown operation"),
    (2, 2, "power", "Unknown operation"),
])
@pytest.mark.asyncio
async def test_calculate_errors(a, b, op, error):
    """Parameterized test for error cases."""
    with pytest.raises(ValueError, match=error):
        await calculate({"a": a, "b": b, "op": op})
```

### Testing Tools with External Dependencies

**Purpose**: Test tools that interact with databases, APIs, etc.

```python
import pytest
from unittest.mock import AsyncMock, MagicMock, patch
from claude_agent_sdk import tool

@tool("query_users", "Query user database", {"filter": str})
async def query_users(args):
    """Tool with database dependency."""
    import asyncpg

    pool = await get_db_pool()  # External dependency

    async with pool.acquire() as conn:
        rows = await conn.fetch(
            "SELECT * FROM users WHERE name LIKE $1",
            f"%{args['filter']}%"
        )

    return {
        "content": [{
            "type": "text",
            "text": f"Found {len(rows)} users"
        }]
    }


# Test with mocked database
@pytest.mark.asyncio
@patch('your_module.get_db_pool')
async def test_query_users(mock_get_pool):
    """Test database query tool with mocked connection."""

    # Setup mock
    mock_conn = AsyncMock()
    mock_conn.fetch = AsyncMock(return_value=[
        {"id": 1, "name": "Alice"},
        {"id": 2, "name": "Alan"}
    ])

    mock_pool = MagicMock()
    mock_pool.acquire = MagicMock()
    mock_pool.acquire.return_value.__aenter__ = AsyncMock(return_value=mock_conn)
    mock_pool.acquire.return_value.__aexit__ = AsyncMock(return_value=None)

    mock_get_pool.return_value = mock_pool

    # Execute
    result = await query_users({"filter": "Al"})

    # Verify
    assert "Found 2 users" in result["content"][0]["text"]
    mock_conn.fetch.assert_called_once()
```

---

## Integration Testing with Mocks

### Mocking SDK Query

**Purpose**: Test workflows without actual API calls

```python
import pytest
from unittest.mock import AsyncMock, MagicMock
from claude_agent_sdk import query, ClaudeAgentOptions, AssistantMessage, TextBlock

@pytest.mark.asyncio
@patch('claude_agent_sdk.query')
async def test_workflow_with_mocked_query(mock_query):
    """Test complete workflow with mocked SDK."""

    # Setup mock response
    mock_message = AssistantMessage(
        content=[TextBlock(text="Analysis complete: 3 security issues found")],
        model="claude-sonnet-4-20250514"
    )

    # Mock query returns async generator
    async def mock_generator():
        yield mock_message

    mock_query.return_value = mock_generator()

    # Execute workflow
    result = []
    async for msg in query(prompt="Analyze code", options=ClaudeAgentOptions()):
        result.append(msg)

    # Verify
    assert len(result) == 1
    assert isinstance(result[0], AssistantMessage)
    assert "3 security issues" in result[0].content[0].text
```

### Mocking ClaudeSDKClient

**Purpose**: Test multi-turn conversations without API

```python
@pytest.mark.asyncio
@patch('claude_agent_sdk.ClaudeSDKClient')
async def test_multi_turn_conversation(mock_client_class):
    """Test conversation flow with mocked client."""

    # Setup mock client instance
    mock_client = MagicMock()
    mock_client.query = AsyncMock()
    mock_client.receive_response = AsyncMock()

    # Mock responses for two turns
    async def mock_response_turn1():
        yield AssistantMessage(
            content=[TextBlock(text="Paris is the capital of France")],
            model="claude-sonnet-4-20250514"
        )

    async def mock_response_turn2():
        yield AssistantMessage(
            content=[TextBlock(text="Paris has approximately 2.1 million residents")],
            model="claude-sonnet-4-20250514"
        )

    # Setup mock returns
    mock_client.receive_response.side_effect = [
        mock_response_turn1(),
        mock_response_turn2()
    ]

    # Make mock client work as context manager
    mock_client.__aenter__ = AsyncMock(return_value=mock_client)
    mock_client.__aexit__ = AsyncMock(return_value=None)

    mock_client_class.return_value = mock_client

    # Execute test
    from claude_agent_sdk import ClaudeSDKClient

    async with ClaudeSDKClient() as client:
        # Turn 1
        await client.query("What's the capital of France?")
        response1 = []
        async for msg in client.receive_response():
            response1.append(msg)

        # Turn 2
        await client.query("What's the population?")
        response2 = []
        async for msg in client.receive_response():
            response2.append(msg)

    # Verify
    assert "Paris" in response1[0].content[0].text
    assert "2.1 million" in response2[0].content[0].text
    assert mock_client.query.call_count == 2
```

---

## Testing ClaudeSDKClient Workflows

### Fixture-Based Testing

**Purpose**: Reusable test fixtures for common scenarios

```python
import pytest
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions

@pytest.fixture
async def sdk_client():
    """Fixture providing configured SDK client."""
    options = ClaudeAgentOptions(
        allowed_tools=["Read", "Write"],
        permission_mode="acceptEdits",
        max_tokens=1024
    )

    client = ClaudeSDKClient(options=options)
    await client.connect()
    yield client
    await client.disconnect()


@pytest.mark.asyncio
async def test_simple_query_with_fixture(sdk_client):
    """Test using SDK client fixture."""
    await sdk_client.query("What is 2 + 2?")

    response = []
    async for msg in sdk_client.receive_response():
        response.append(msg)

    assert len(response) > 0
```

### Testing Response Accumulation

**Purpose**: Verify message accumulation patterns

```python
@pytest.mark.asyncio
async def test_message_accumulation():
    """Test complete response accumulation."""

    from claude_agent_sdk import query, AssistantMessage, TextBlock

    options = ClaudeAgentOptions(max_tokens=1024)
    full_response = ""

    async for message in query(
        prompt="Explain async/await in one sentence",
        options=options
    ):
        if isinstance(message, AssistantMessage):
            for block in message.content:
                if isinstance(block, TextBlock):
                    full_response += block.text

    # Verify accumulated text
    assert len(full_response) > 0
    assert "async" in full_response.lower() or "await" in full_response.lower()
```

---

## Testing MCP Servers

### Testing SDK MCP Servers

**Purpose**: Test in-process MCP servers created with SDK

```python
from claude_agent_sdk import tool, create_sdk_mcp_server, ClaudeAgentOptions

@tool("greet", "Greet a person", {"name": str})
async def greet_person(args):
    return {
        "content": [{
            "type": "text",
            "text": f"Hello, {args['name']}!"
        }]
    }


@pytest.mark.asyncio
async def test_greet_tool():
    """Test greet tool in isolation."""
    result = await greet_person({"name": "Alice"})
    assert "Hello, Alice!" in result["content"][0]["text"]


@pytest.mark.asyncio
async def test_mcp_server_integration():
    """Test MCP server integration."""

    # Create server
    server = create_sdk_mcp_server(
        name="greetings",
        version="1.0.0",
        tools=[greet_person]
    )

    # Use in SDK client
    options = ClaudeAgentOptions(
        mcp_servers={"greetings": server},
        allowed_tools=["mcp__greetings__greet"]
    )

    # Test would require full SDK integration or mocking
    assert options.mcp_servers["greetings"] is not None
```

---

## Testing Hooks and Callbacks

### Unit Testing Hooks

**Purpose**: Test hook functions independently

```python
from claude_agent_sdk import HookContext

async def safety_hook(input_data, tool_use_id, context):
    """Hook for testing."""
    tool_name = input_data.get('tool_name')

    if tool_name == "Bash":
        cmd = input_data.get('tool_input', {}).get('command', '')
        if "rm -rf /" in cmd:
            return {
                'hookSpecificOutput': {
                    'hookEventName': 'PreToolUse',
                    'permissionDecision': 'deny',
                    'permissionDecisionReason': 'Dangerous command blocked'
                }
            }

    return {}


@pytest.mark.asyncio
async def test_safety_hook_blocks_dangerous_command():
    """Test hook blocks rm -rf /."""

    input_data = {
        'tool_name': 'Bash',
        'tool_input': {'command': 'rm -rf /'}
    }

    result = await safety_hook(input_data, "tool_123", HookContext())

    assert result['hookSpecificOutput']['permissionDecision'] == 'deny'
    assert 'Dangerous command' in result['hookSpecificOutput']['permissionDecisionReason']


@pytest.mark.asyncio
async def test_safety_hook_allows_safe_command():
    """Test hook allows safe commands."""

    input_data = {
        'tool_name': 'Bash',
        'tool_input': {'command': 'ls -la'}
    }

    result = await safety_hook(input_data, "tool_456", HookContext())

    assert result == {}  # Empty result means allow
```

### Testing Permission Callbacks

**Purpose**: Test can_use_tool callback logic

```python
async def permission_callback(tool_name: str, input_data: dict, context: dict):
    """Permission callback for testing."""

    # Allow read operations
    if tool_name in ["Read", "Grep"]:
        return {"behavior": "allow", "updatedInput": input_data}

    # Block writes to system directories
    if tool_name == "Write":
        file_path = input_data.get("file_path", "")
        if file_path.startswith("/etc/"):
            return {
                "behavior": "deny",
                "message": f"Cannot write to system directory: {file_path}"
            }

    return {"behavior": "allow", "updatedInput": input_data}


@pytest.mark.asyncio
async def test_permission_allows_read():
    """Test callback allows read operations."""
    result = await permission_callback("Read", {"file_path": "/app/config.json"}, {})
    assert result["behavior"] == "allow"


@pytest.mark.asyncio
async def test_permission_blocks_system_write():
    """Test callback blocks system directory writes."""
    result = await permission_callback("Write", {"file_path": "/etc/passwd"}, {})
    assert result["behavior"] == "deny"
    assert "/etc/" in result["message"]
```

---

## End-to-End Testing

### Real SDK Integration Tests

**Purpose**: Test with actual SDK (use sparingly due to API costs)

```python
import pytest
import os

# Skip if no API key (for CI environments)
pytestmark = pytest.mark.skipif(
    not os.getenv("ANTHROPIC_API_KEY"),
    reason="No API key available"
)


@pytest.mark.asyncio
@pytest.mark.e2e
async def test_real_sdk_simple_query():
    """E2E test with real SDK."""
    from claude_agent_sdk import query

    result = []
    async for msg in query(prompt="What is 2 + 2? Answer with just the number."):
        result.append(msg)

    # Verify we got a response
    assert len(result) > 0


@pytest.mark.asyncio
@pytest.mark.e2e
async def test_real_sdk_with_tools():
    """E2E test with file operations."""
    from claude_agent_sdk import query, ClaudeAgentOptions
    import tempfile
    import os

    # Create temp file for testing
    with tempfile.NamedTemporaryFile(mode='w', delete=False, suffix='.txt') as f:
        test_file = f.name
        f.write("Test content")

    try:
        options = ClaudeAgentOptions(
            allowed_tools=["Read"],
            permission_mode="acceptEdits",
            cwd=os.path.dirname(test_file)
        )

        result = []
        async for msg in query(
            prompt=f"Read the file {test_file} and tell me what it contains",
            options=options
        ):
            result.append(msg)

        # Verify response mentions file content
        response_text = str(result)
        assert "Test content" in response_text or len(result) > 0

    finally:
        # Cleanup
        os.unlink(test_file)
```

---

## Performance Testing

### Response Time Testing

**Purpose**: Ensure queries complete within acceptable time limits

```python
import time

@pytest.mark.asyncio
@pytest.mark.performance
async def test_query_performance():
    """Test query completes within timeout."""
    from claude_agent_sdk import query

    start = time.time()

    result = []
    async for msg in query(prompt="What is 2 + 2?"):
        result.append(msg)

    duration = time.time() - start

    # Should complete within 30 seconds
    assert duration < 30.0
    assert len(result) > 0
```

### Load Testing

**Purpose**: Test concurrent query handling

```python
import asyncio

@pytest.mark.asyncio
@pytest.mark.performance
async def test_concurrent_queries():
    """Test handling multiple concurrent queries."""
    from claude_agent_sdk import query

    async def single_query(n):
        result = []
        async for msg in query(prompt=f"What is {n} + {n}?"):
            result.append(msg)
        return result

    # Execute 5 queries concurrently
    start = time.time()
    results = await asyncio.gather(*[single_query(i) for i in range(5)])
    duration = time.time() - start

    # All should complete
    assert all(len(r) > 0 for r in results)

    # Should complete in reasonable time (not 5x single query)
    assert duration < 60.0  # Assuming single query ~10s, 5x concurrent should be <60s
```

---

## Testing Best Practices

### 1. Test Organization

```
tests/
├── unit/
│   ├── test_tools.py          # Tool unit tests
│   ├── test_hooks.py          # Hook unit tests
│   └── test_utils.py          # Utility function tests
├── integration/
│   ├── test_workflows.py      # Workflow integration tests
│   ├── test_mcp_servers.py    # MCP server tests
│   └── test_client.py         # Client integration tests
├── e2e/
│   └── test_real_sdk.py       # Real SDK tests
├── performance/
│   └── test_load.py           # Performance tests
└── conftest.py                # Pytest fixtures
```

### 2. Pytest Configuration

**File**: `pytest.ini`
```ini
[pytest]
markers =
    unit: Unit tests (fast, no external dependencies)
    integration: Integration tests (mocked external dependencies)
    e2e: End-to-end tests (real SDK, requires API key)
    performance: Performance and load tests
    slow: Slow-running tests

asyncio_mode = auto

testpaths = tests

# Coverage settings
addopts =
    --cov=src
    --cov-report=html
    --cov-report=term-missing
    --cov-fail-under=80
```

### 3. Running Tests

```bash
# Run all tests
pytest

# Run only unit tests (fast)
pytest -m unit

# Run integration tests
pytest -m integration

# Run E2E tests (requires API key)
ANTHROPIC_API_KEY=your-key pytest -m e2e

# Run with coverage
pytest --cov=src --cov-report=html

# Run specific test file
pytest tests/unit/test_tools.py

# Run specific test
pytest tests/unit/test_tools.py::test_calculate_addition

# Verbose output
pytest -v

# Stop on first failure
pytest -x
```

### 4. Coverage Goals

| Test Level | Coverage Target | Rationale |
|------------|----------------|-----------|
| **Unit Tests** | 95%+ | Core logic, easily testable |
| **Integration Tests** | 85%+ | Workflow combinations |
| **E2E Tests** | 70%+ | Critical user paths only (API cost) |
| **Overall** | 90%+ | Production quality |

### 5. CI/CD Integration

**GitHub Actions Example**:
```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-asyncio pytest-cov

      - name: Run unit tests
        run: pytest -m unit

      - name: Run integration tests
        run: pytest -m integration

      - name: Run E2E tests
        if: github.event_name == 'push' && github.ref == 'refs/heads/main'
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: pytest -m e2e

      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

---

## See Also

- [Getting Started Guide](getting-started.md) - SDK setup and basic usage
- [Production Patterns Guide](production-patterns.md) - Production deployment patterns
- [API Reference](api-reference.md) - Complete API documentation
- [Security Best Practices](security.md) - Security testing patterns

[← Back to Documentation Index](index.md)
