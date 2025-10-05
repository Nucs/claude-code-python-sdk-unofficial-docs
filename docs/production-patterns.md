# Production Patterns - Claude Agent SDK

> **Enterprise deployment strategies, scaling patterns, production best practices, and SuperClaude framework integration**

[← Back to Documentation Index](index.md)

---

## Table of Contents

1. [Enterprise Deployment Models](#enterprise-deployment-models)
2. [SuperClaude Framework Production Integration](#superclaude-framework-production-integration)
3. [CLAUDE.md Multi-Level Deployment](#claudemd-multi-level-deployment)
4. [Security Configurations](#security-configurations)
5. [Headless Mode Automation](#headless-mode-automation)
6. [CI/CD Integration](#cicd-integration)
7. [Monitoring & Observability](#monitoring--observability)
8. [Cost Management](#cost-management)
9. [Scaling Architectures](#scaling-architectures)

---

## Enterprise Deployment Models

Four primary patterns for production Claude Agent SDK deployment.[^1]

```
                    Production Deployment Architecture

┌─────────────────────────────────────────────────────────────────────┐
│                          Load Balancer                              │
└────────────────────────────┬────────────────────────────────────────┘
                             │
            ┌────────────────┼────────────────┐
            │                │                │
   ┌────────▼────────┐  ┌───▼────────┐  ┌───▼─────────┐
   │  Pattern 1:     │  │ Pattern 2: │  │  Pattern 3: │
   │  Direct API     │  │  Web App   │  │  Worker     │
   │  Integration    │  │ Integration│  │  Queue      │
   └────────┬────────┘  └─────┬──────┘  └──────┬──────┘
            │                 │                 │
            │        ┌────────▼────────┐        │
            │        │  Claude SDK     │        │
            └───────▶│  Client Pool    │◄───────┘
                     └────────┬────────┘
                              │
                  ┌───────────┼───────────┐
                  │           │           │
         ┌────────▼──────┐ ┌─▼────────┐ ┌▼────────────┐
         │ Claude API    │ │ MCP      │ │ Monitoring  │
         │ (Anthropic)   │ │ Servers  │ │ & Logging   │
         └───────────────┘ └──────────┘ └─────────────┘
```

### Pattern 1: Direct API Integration

**Use Case**: Backend services, automation pipelines, scheduled tasks

**Architecture**:
```python
# Production service with Claude Agent SDK
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions
import asyncio

class ProductionService:
    def __init__(self):
        self.options = ClaudeAgentOptions(
            system_prompt="You are a production assistant",
            max_tokens=4096,
            allowed_tools=["Read", "Bash", "mcp__database__query"],
            permission_mode='acceptAll',  # Automated environment
            mcp_servers={
                "database": {
                    "command": "python",
                    "args": ["/opt/mcp/database_server.py"]
                }
            }
        )

    async def process_request(self, user_query: str) -> str:
        async with ClaudeSDKClient(options=self.options) as client:
            await client.query(user_query)

            result = []
            async for msg in client.receive_response():
                result.append(msg)

            return "".join(result)

# Deploy as containerized service
if __name__ == "__main__":
    service = ProductionService()
    asyncio.run(service.process_request("Analyze database performance"))
```

**Deployment**: Docker container, Kubernetes pod, AWS Lambda

**Considerations**:
- API key management via secrets (AWS Secrets Manager, Azure Key Vault)
- Error handling and retry logic
- Rate limit management
- Response validation

### Pattern 2: Web Application Integration

**Use Case**: User-facing applications with Claude-powered features

**Architecture (FastAPI)**:
```python
from fastapi import FastAPI, HTTPException
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions
from pydantic import BaseModel

app = FastAPI()

class QueryRequest(BaseModel):
    prompt: str
    context: dict = {}

@app.post("/api/claude/query")
async def claude_query(request: QueryRequest):
    try:
        options = ClaudeAgentOptions(
            allowed_tools=["Read", "WebFetch"],
            permission_mode='acceptAll',
            max_tokens=2048,
            cwd="/app/workspace"
        )

        async with ClaudeSDKClient(options=options) as client:
            await client.query(request.prompt)

            response_text = []
            async for msg in client.receive_response():
                response_text.append(msg)

            return {
                "status": "success",
                "response": "".join(response_text)
            }

    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Production deployment with uvicorn
# uvicorn main:app --host 0.0.0.0 --port 8000 --workers 4
```

**Load Balancing**:
- Horizontal scaling with multiple app instances
- Session affinity for stateful conversations
- Response streaming for long operations

### Pattern 3: Workflow Automation

**Use Case**: CI/CD pipelines, scheduled automation, event-driven processing

**Architecture (GitHub Actions)**:
```yaml
# .github/workflows/claude-automation.yml
name: Claude Code Review

on:
  pull_request:
    types: [opened, synchronize]

jobs:
  code-review:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Install dependencies
        run: |
          pip install claude-agent-sdk

      - name: Run Claude Code Review
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          python automation/code_review.py \
            --pr-number ${{ github.event.pull_request.number }} \
            --repo ${{ github.repository }}
```

**Automation Script**:
```python
# automation/code_review.py
import asyncio
import sys
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions

async def review_pr(pr_number: int, repo: str):
    options = ClaudeAgentOptions(
        system_prompt="You are an expert code reviewer",
        allowed_tools=["Read", "Grep", "mcp__github__get_pr"],
        permission_mode='acceptAll',
        mcp_servers={
            "github": {
                "command": "npx",
                "args": ["-y", "@modelcontextprotocol/server-github"],
                "env": {"GITHUB_TOKEN": os.environ["GITHUB_TOKEN"]}
            }
        }
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query(f"""
        Review pull request #{pr_number} in {repo}:
        1. Analyze code changes
        2. Check for security issues
        3. Verify test coverage
        4. Provide improvement suggestions
        """)

        async for msg in client.receive_response():
            print(msg)

if __name__ == "__main__":
    pr_number = int(sys.argv[1].split("=")[1])
    repo = sys.argv[2].split("=")[1]
    asyncio.run(review_pr(pr_number, repo))
```

### Pattern 4: Microservices Architecture

**Use Case**: Distributed systems with specialized Claude agents

**Architecture**:
```python
# Service 1: Data Analysis Agent
class DataAnalysisAgent:
    async def analyze(self, data_path: str):
        options = ClaudeAgentOptions(
            allowed_tools=["Read", "Bash", "mcp__database__query"],
            permission_mode='acceptAll'
        )
        # Analysis logic

# Service 2: Code Generation Agent
class CodeGenerationAgent:
    async def generate(self, specification: str):
        options = ClaudeAgentOptions(
            allowed_tools=["Read", "Write", "Bash"],
            permission_mode='acceptEdits'
        )
        # Generation logic

# Service 3: Documentation Agent
class DocumentationAgent:
    async def document(self, codebase_path: str):
        options = ClaudeAgentOptions(
            allowed_tools=["Read", "Glob", "Grep", "Write"],
            permission_mode='acceptEdits'
        )
        # Documentation logic

# Orchestrator
class AgentOrchestrator:
    def __init__(self):
        self.analysis_agent = DataAnalysisAgent()
        self.code_agent = CodeGenerationAgent()
        self.docs_agent = DocumentationAgent()

    async def execute_workflow(self, task: dict):
        # Coordinate agents based on task type
        if task["type"] == "analysis":
            return await self.analysis_agent.analyze(task["data"])
        elif task["type"] == "generate":
            return await self.code_agent.generate(task["spec"])
        elif task["type"] == "document":
            return await self.docs_agent.document(task["path"])
```

**Deployment**: Kubernetes with service mesh (Istio, Linkerd)

---

## SuperClaude Framework Production Integration

Production patterns for SuperClaude framework deployment with enterprise-grade reliability. **See**: [Claude Configuration](../../../CLAUDE.md)

### Framework-Aware Production Service

**Purpose**: Deploy Claude Agent SDK with full SuperClaude framework support in production

**Architecture**:
```python
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions, HookMatcher
import asyncio
import logging

class SuperClaudeProductionService:
    def __init__(self, environment: str = "production"):
        self.environment = environment
        self.logger = logging.getLogger(__name__)

        self.options = ClaudeAgentOptions(
            # Load framework instructions from project
            setting_sources=["project"],

            # Activate production-optimized modes
            system_prompt={
                "type": "preset",
                "preset": "claude_code",
                "append": "--orchestrate --think-hard --token-efficient"
            },

            # Enable framework MCP servers
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
                },
                "context7": {
                    "type": "stdio",
                    "command": "npx",
                    "args": ["-y", "@context7/mcp-server"]
                }
            },

            # Production tool allowlist
            allowed_tools=[
                "Read", "Grep", "Glob",
                "mcp__sequential__sequentialthinking",
                "mcp__serena__write_memory",
                "mcp__serena__read_memory",
                "mcp__context7__get_library_docs",
                "mcp__database__query"
            ],

            # Automated execution
            permission_mode='acceptAll',

            # Framework Rules enforcement via hooks
            hooks={
                'PreToolUse': [
                    HookMatcher(matcher='Bash', hooks=[self._enforce_safety_rules])
                ],
                'PostToolUse': [
                    HookMatcher(matcher='*', hooks=[self._log_tool_execution])
                ]
            },

            # Performance tuning
            max_tokens=8192,
            max_turns=30
        )

    async def _enforce_safety_rules(self, input_data, tool_use_id, context):
        """Implement Framework Rules safety enforcement"""
        # See Framework Rules for production safety standards
        tool_name = input_data.get('tool_name')

        if tool_name == 'Bash':
            cmd = input_data.get('tool_input', {}).get('command', '')

            # Framework Rules: Never force push to production branches
            if 'push --force' in cmd and any(branch in cmd for branch in ['main', 'master', 'production']):
                return {
                    'hookSpecificOutput': {
                        'permissionDecision': 'deny',
                        'permissionDecisionReason': 'Force push to protected branches blocked (Framework Rules)'
                    }
                }

        return {}

    async def _log_tool_execution(self, input_data, tool_use_id, context):
        """Log all tool executions for audit trail"""
        self.logger.info({
            "event": "tool_execution",
            "tool": input_data.get('tool_name'),
            "environment": self.environment,
            "tool_use_id": tool_use_id
        })
        return {}

    async def process_request(self, request: dict) -> dict:
        """Process request with framework integration"""
        async with ClaudeSDKClient(options=self.options) as client:
            # Load context from Serena if available
            await client.query("read_memory('production_context')")

            # Process main request with framework orchestration
            await client.query(request['prompt'])

            result = []
            async for msg in client.receive_response():
                result.append(msg)

            # Store session context for future requests
            await client.query(f"write_memory('production_context', '{result}')")

            return {
                "status": "success",
                "response": "".join(result),
                "environment": self.environment
            }

# Production deployment
if __name__ == "__main__":
    service = SuperClaudeProductionService(environment="production")
    asyncio.run(service.process_request({
        "prompt": "Analyze system performance using Sequential MCP for deep analysis"
    }))
```

**Framework Benefits in Production**:
- **Orchestration Mode**: Automatic tool selection optimization [Orchestration Mode](../../../MODE_Orchestration.md)
- **Sequential MCP**: Deep analysis for complex production issues [Sequential Thinking MCP](../../../MCP_Sequential.md)
- **Serena MCP**: Cross-session context preservation [Serena Memory MCP](../../../MCP_Serena.md)
- **RULES.md Enforcement**: Production safety standards [Framework Rules](../../../RULES.md)
- **Token Efficiency**: Optimized production costs [Token Efficiency Mode](../../../MODE_Token_Efficiency.md)

### Cross-Session Production Continuity

**Purpose**: Maintain production context across sessions using Serena MCP

**Architecture**:
```python
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions
import asyncio

class ContinuousProductionService:
    def __init__(self):
        self.options = ClaudeAgentOptions(
            setting_sources=["project"],

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
                "mcp__serena__list_memories",
                "TodoWrite",
                "Read", "Write"
            ],

            system_prompt={
                "type": "preset",
                "preset": "claude_code",
                "append": "--task-manage"
            },

            permission_mode='acceptAll'
        )

    async def start_session(self):
        """Initialize new production session with context loading"""
        async with ClaudeSDKClient(options=self.options) as client:
            # Load production state from previous session
            await client.query("""
            Production Session Initialization:
            1. list_memories() - Show all stored context
            2. read_memory('deployment_state') - Current deployment status
            3. read_memory('active_tasks') - In-progress tasks
            4. think_about_collected_information() - Understand current state
            """)

            async for msg in client.receive_response():
                print(msg)

    async def end_session(self, status: str):
        """Save production state for next session"""
        async with ClaudeSDKClient(options=self.options) as client:
            await client.query(f"""
            Production Session End:
            1. think_about_whether_you_are_done() - Assess completion
            2. write_memory('deployment_state', '{status}')
            3. write_memory('session_summary', 'outcomes')
            4. delete_memory() for completed temporary items
            """)

            async for msg in client.receive_response():
                print(msg)

# Usage
service = ContinuousProductionService()

# Session 1: Deploy feature
asyncio.run(service.start_session())
# ... deployment work ...
asyncio.run(service.end_session("feature_deployed"))

# Session 2: Monitor (hours later)
asyncio.run(service.start_session())
# Claude retrieves deployment_state automatically
```

**Production Benefits**:
- **Zero Context Loss**: Full state preservation across sessions
- **Deployment Continuity**: Track deployments across multiple sessions
- **Incident Response**: Historical context for debugging
- **Team Handoffs**: Complete context transfer between shifts

**See**: [Serena Memory MCP](../../../MCP_Serena.md), [Task Management Mode](../../../MODE_Task_Management.md)

### CI/CD with Framework Integration

**Purpose**: Production-grade CI/CD with SuperClaude framework capabilities

**GitHub Actions Workflow**:
```yaml
# .github/workflows/superclaude-cicd.yml
name: SuperClaude Production Pipeline

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  framework-analysis:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v3

      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'

      - name: Setup Node.js (for MCP servers)
        uses: actions/setup-node@v3
        with:
          node-version: '18'

      - name: Install Dependencies
        run: |
          pip install claude-agent-sdk
          # MCP servers available via npx

      - name: SuperClaude Framework Analysis
        env:
          ANTHROPIC_API_KEY: ${{ secrets.ANTHROPIC_API_KEY }}
        run: |
          python ci/superclaude_pipeline.py \
            --mode production \
            --enable-sequential \
            --enable-serena \
            --enforce-rules
```

**Pipeline Script**:
```python
# ci/superclaude_pipeline.py
import asyncio
import sys
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions, HookMatcher

async def production_pipeline(mode: str, enable_sequential: bool, enable_serena: bool, enforce_rules: bool):
    mcp_servers = {}

    if enable_sequential:
        mcp_servers["sequential"] = {
            "type": "stdio",
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
        }

    if enable_serena:
        mcp_servers["serena"] = {
            "type": "stdio",
            "command": "npx",
            "args": ["-y", "@serena/mcp-server"]
        }

    hooks = {}
    if enforce_rules:
        async def enforce_production_rules(input_data, tool_use_id, context):
            # RULES.md enforcement logic
            pass

        hooks = {
            'PreToolUse': [HookMatcher(matcher='*', hooks=[enforce_production_rules])]
        }

    options = ClaudeAgentOptions(
        setting_sources=["project"],  # Load CLAUDE.md

        system_prompt={
            "type": "preset",
            "preset": "claude_code",
            "append": "--orchestrate --think-hard --validate"
        },

        mcp_servers=mcp_servers,

        allowed_tools=[
            "Read", "Grep", "Bash",
            "mcp__sequential__sequentialthinking" if enable_sequential else None,
            "mcp__serena__write_memory" if enable_serena else None
        ],

        hooks=hooks,
        permission_mode='acceptAll'
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query(f"""
        Production Pipeline Analysis (Mode: {mode}):
        1. Grep: Find all test files
        2. Bash: Run test suite
        3. Sequential: Analyze test results for patterns
        4. Serena: Store pipeline results for tracking
        5. Report: Generate deployment readiness assessment

        Fail pipeline if: tests fail OR security issues found
        """)

        pipeline_passed = True
        async for msg in client.receive_response():
            print(msg)
            if "FAIL" in msg or "ERROR" in msg:
                pipeline_passed = False

        if not pipeline_passed:
            sys.exit(1)  # Fail CI/CD

if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--mode', default='production')
    parser.add_argument('--enable-sequential', action='store_true')
    parser.add_argument('--enable-serena', action='store_true')
    parser.add_argument('--enforce-rules', action='store_true')
    args = parser.parse_args()

    asyncio.run(production_pipeline(
        args.mode,
        args.enable_sequential,
        args.enable_serena,
        args.enforce_rules
    ))
```

**Pipeline Features**:
- **Sequential MCP**: Deep analysis of test results and code changes
- **Serena MCP**: Track pipeline history across builds
- **RULES.md Enforcement**: Production safety standards
- **Orchestration Mode**: Intelligent tool routing for efficiency
- **Framework-Aware**: Loads CLAUDE.md project instructions

**See**: [getting-started.md](getting-started.md), [tools-and-mcp.md](tools-and-mcp.md)

---

## CLAUDE.md Multi-Level Deployment

CLAUDE.md files enable hierarchical configuration for enterprise environments.[^2]

### Global Configuration

**Location**: `~/.claude/CLAUDE.md`

**Purpose**: Organization-wide defaults and policies

```markdown
# Global Enterprise Configuration

## Security Policy
- All agents must use `permission_mode='ask'` in production
- MCP servers must be from approved registry only
- API keys via corporate secrets manager

## Standard MCP Servers
- Database: `mcp__postgres__*` (corporate PostgreSQL)
- Auth: `mcp__okta__*` (SSO integration)
- Monitoring: `mcp__datadog__*` (observability)

## Compliance Requirements
- GDPR: Data residency in EU
- SOC 2: Audit trail for all tool executions
- HIPAA: PHI redaction in logs
```

### Project Configuration

**Location**: `<project-root>/CLAUDE.md`

**Purpose**: Project-specific tools and workflows

```markdown
# Project: Customer Analytics Platform

## Architecture
- FastAPI backend with Claude Agent SDK
- PostgreSQL database for analytics
- Redis for caching
- Deployed on AWS EKS

## Available Tools
- `mcp__postgres__query` - Analytics queries
- `mcp__redis__cache` - Cache operations
- `mcp__aws__s3` - Report storage

## Deployment Workflow
1. Run tests: `pytest tests/`
2. Build container: `docker build -t analytics:latest .`
3. Push to ECR: `aws ecr push`
4. Deploy to EKS: `kubectl apply -f deployment.yaml`
```

### Team Configuration

**Location**: `<project-root>/teams/<team-name>/CLAUDE.md`

**Purpose**: Team-specific overrides and specializations

```markdown
# Team: Data Science

## Specialized MCP Servers
- `mcp__jupyter__*` - Notebook operations
- `mcp__mlflow__*` - Model tracking
- `mcp__snowflake__*` - Data warehouse

## Custom Tools
- `analyze_dataset` - Statistical analysis
- `train_model` - ML model training
- `generate_report` - Automated reporting

## Team Standards
- All analysis documented in Jupyter notebooks
- Models versioned in MLflow
- Results stored in Snowflake
```

### Cascading Configuration Priority

**Resolution Order**:
1. User-level: `~/.claude/CLAUDE.md` (lowest priority)
2. Project-level: `<project>/CLAUDE.md`
3. Team-level: `<project>/teams/<team>/CLAUDE.md`
4. Task-level: Inline `ClaudeAgentOptions` (highest priority)

**Example**:
```python
# Global CLAUDE.md sets: permission_mode='ask'
# Project CLAUDE.md sets: permission_mode='acceptEdits'
# Inline code sets: permission_mode='acceptAll'

# Result: 'acceptAll' wins (highest priority)
options = ClaudeAgentOptions(permission_mode='acceptAll')
```

---

## Security Configurations

Production security patterns for enterprise deployment.[^3]

### Advanced Permission Callbacks

**Pattern**: Dynamic permission control with context-aware decisions

#### Path Redirection for Sandboxing

```python
from claude_agent_sdk import ClaudeAgentOptions
import os

async def sandbox_permission_handler(
    tool_name: str,
    input_data: dict,
    context: dict
):
    """Redirect sensitive operations to sandbox directories."""

    # Block writes to system directories
    if tool_name == "Write" and input_data.get("file_path", "").startswith("/system/"):
        return {
            "behavior": "deny",
            "message": "System directory write not allowed",
            "interrupt": True
        }

    # Redirect config files to sandbox
    if tool_name in ["Write", "Edit"]:
        file_path = input_data.get("file_path", "")

        # Redirect /etc/ writes to sandbox
        if file_path.startswith("/etc/"):
            sandbox_path = f"/opt/sandbox{file_path}"
            os.makedirs(os.path.dirname(sandbox_path), exist_ok=True)

            return {
                "behavior": "allow",
                "updatedInput": {
                    **input_data,
                    "file_path": sandbox_path
                },
                "systemMessage": f"Redirected to sandbox: {sandbox_path}"
            }

        # Redirect sensitive directories
        sensitive_prefixes = ["/var/log/", "/root/", "~/.ssh/"]
        for prefix in sensitive_prefixes:
            if file_path.startswith(prefix):
                sandbox_path = f"/opt/sandbox{file_path}"
                os.makedirs(os.path.dirname(sandbox_path), exist_ok=True)

                return {
                    "behavior": "allow",
                    "updatedInput": {**input_data, "file_path": sandbox_path}
                }

    return {"behavior": "allow", "updatedInput": input_data}


# Usage
options = ClaudeAgentOptions(
    can_use_tool=sandbox_permission_handler,
    allowed_tools=["Read", "Write", "Edit", "Bash"]
)
```

#### Multi-Layer Permission Strategy

```python
from typing import Callable
import logging

logger = logging.getLogger(__name__)

class PermissionLayer:
    """Layered permission system with different strategies."""

    def __init__(self):
        self.layers = []

    def add_layer(self, name: str, handler: Callable):
        """Add a permission layer."""
        self.layers.append({"name": name, "handler": handler})

    async def check_permission(
        self,
        tool_name: str,
        input_data: dict,
        context: dict
    ):
        """Check all permission layers in order."""

        for layer in self.layers:
            try:
                result = await layer["handler"](tool_name, input_data, context)

                # If any layer denies, stop and deny
                if result.get("behavior") == "deny":
                    logger.warning(
                        f"Permission denied by layer '{layer['name']}': "
                        f"{result.get('message', 'No reason provided')}"
                    )
                    return result

                # If layer modified input, use modified version for next layer
                if "updatedInput" in result:
                    input_data = result["updatedInput"]

            except Exception as e:
                logger.error(f"Error in permission layer '{layer['name']}': {e}")
                # Fail closed - deny on error
                return {
                    "behavior": "deny",
                    "message": f"Permission check failed: {e}",
                    "interrupt": True
                }

        # All layers passed
        return {"behavior": "allow", "updatedInput": input_data}


# Define permission layers

async def sensitive_data_protection(tool_name: str, input_data: dict, context: dict):
    """Block access to sensitive data patterns."""

    if tool_name == "Read":
        file_path = input_data.get("file_path", "")

        # Block credential files
        sensitive_files = [
            ".env", "credentials.json", ".aws/credentials",
            ".ssh/id_rsa", "secrets.yaml"
        ]

        if any(pattern in file_path for pattern in sensitive_files):
            return {
                "behavior": "deny",
                "message": f"Access to sensitive file blocked: {file_path}"
            }

    if tool_name == "Bash":
        cmd = input_data.get("command", "")

        # Block commands that might expose secrets
        if any(keyword in cmd for keyword in ["cat .env", "echo $AWS", "printenv"]):
            return {
                "behavior": "deny",
                "message": "Command may expose sensitive environment variables"
            }

    return {"behavior": "allow", "updatedInput": input_data}


async def rate_limiting(tool_name: str, input_data: dict, context: dict):
    """Rate limit expensive operations."""
    import time

    # Track operation counts
    if not hasattr(rate_limiting, "counts"):
        rate_limiting.counts = {}
        rate_limiting.window_start = time.time()

    # Reset window every 60 seconds
    if time.time() - rate_limiting.window_start > 60:
        rate_limiting.counts = {}
        rate_limiting.window_start = time.time()

    # Count operations
    rate_limiting.counts[tool_name] = rate_limiting.counts.get(tool_name, 0) + 1

    # Bash commands limited to 10/minute
    if tool_name == "Bash" and rate_limiting.counts[tool_name] > 10:
        return {
            "behavior": "deny",
            "message": "Rate limit exceeded for Bash operations (10/min)"
        }

    # Write operations limited to 20/minute
    if tool_name in ["Write", "Edit"] and rate_limiting.counts.get("Write", 0) + rate_limiting.counts.get("Edit", 0) > 20:
        return {
            "behavior": "deny",
            "message": "Rate limit exceeded for file write operations (20/min)"
        }

    return {"behavior": "allow", "updatedInput": input_data}


async def audit_logging(tool_name: str, input_data: dict, context: dict):
    """Log all operations for audit trail."""
    import json
    from datetime import datetime

    audit_entry = {
        "timestamp": datetime.now().isoformat(),
        "tool": tool_name,
        "input": input_data,
        "context": context
    }

    # Write to audit log
    with open("/var/log/claude-agent-audit.log", "a") as f:
        f.write(json.dumps(audit_entry) + "\n")

    return {"behavior": "allow", "updatedInput": input_data}


# Assemble permission layers
permission_system = PermissionLayer()
permission_system.add_layer("sensitive_data", sensitive_data_protection)
permission_system.add_layer("rate_limiting", rate_limiting)
permission_system.add_layer("audit", audit_logging)

# Use in SDK
options = ClaudeAgentOptions(
    can_use_tool=permission_system.check_permission,
    allowed_tools=["Read", "Write", "Bash"]
)
```

#### Role-Based Access Control (RBAC)

```python
from enum import Enum

class Role(Enum):
    ADMIN = "admin"
    DEVELOPER = "developer"
    ANALYST = "analyst"
    VIEWER = "viewer"


class RBACPermissionHandler:
    """Role-based access control for SDK operations."""

    def __init__(self, user_role: Role):
        self.role = user_role

        # Define permissions per role
        self.permissions = {
            Role.ADMIN: {
                "allowed_tools": ["Read", "Write", "Edit", "Bash", "Grep", "Glob"],
                "allowed_paths": ["*"],
                "allowed_commands": ["*"]
            },
            Role.DEVELOPER: {
                "allowed_tools": ["Read", "Write", "Edit", "Grep", "Glob"],
                "allowed_paths": ["/src/**", "/tests/**", "/docs/**"],
                "allowed_commands": ["git*", "npm*", "pytest*"]
            },
            Role.ANALYST: {
                "allowed_tools": ["Read", "Grep", "Glob"],
                "allowed_paths": ["/data/**", "/reports/**"],
                "allowed_commands": ["git status", "git log"]
            },
            Role.VIEWER: {
                "allowed_tools": ["Read", "Grep"],
                "allowed_paths": ["/docs/**", "/README.md"],
                "allowed_commands": []
            }
        }

    async def check_permission(
        self,
        tool_name: str,
        input_data: dict,
        context: dict
    ):
        """Check permission based on user role."""

        role_perms = self.permissions[self.role]

        # Check tool access
        if tool_name not in role_perms["allowed_tools"]:
            return {
                "behavior": "deny",
                "message": f"Role '{self.role.value}' not authorized for tool '{tool_name}'"
            }

        # Check path access for file operations
        if tool_name in ["Read", "Write", "Edit"]:
            file_path = input_data.get("file_path", "")

            if not any(
                self._match_pattern(file_path, pattern)
                for pattern in role_perms["allowed_paths"]
            ):
                return {
                    "behavior": "deny",
                    "message": f"Role '{self.role.value}' not authorized to access '{file_path}'"
                }

        # Check command access for Bash
        if tool_name == "Bash":
            cmd = input_data.get("command", "")

            if not any(
                self._match_pattern(cmd, pattern)
                for pattern in role_perms["allowed_commands"]
            ):
                return {
                    "behavior": "deny",
                    "message": f"Role '{self.role.value}' not authorized to run command"
                }

        return {"behavior": "allow", "updatedInput": input_data}

    def _match_pattern(self, value: str, pattern: str) -> bool:
        """Simple pattern matching with wildcards."""
        if pattern == "*":
            return True

        import fnmatch
        return fnmatch.fnmatch(value, pattern)


# Usage
async def main():
    # Developer role - limited access
    rbac_handler = RBACPermissionHandler(Role.DEVELOPER)

    options = ClaudeAgentOptions(
        can_use_tool=rbac_handler.check_permission,
        allowed_tools=["Read", "Write", "Bash", "Grep"]
    )

    async with ClaudeSDKClient(options=options) as client:
        # Allowed: read source files
        await client.query("Read /src/main.py")

        # Denied: write to system files
        await client.query("Write to /etc/config")

        # Denied: dangerous bash commands
        await client.query("Run: rm -rf /")
```

**Benefits**:
- **Granular Control**: Per-operation permission decisions
- **Security Layers**: Multiple security checks in sequence
- **Audit Trail**: Complete operation logging
- **Dynamic Policies**: Runtime permission adjustment
- **Role Separation**: User-based access control

### OAuth 2.1 Authentication

**MCP Server with OAuth**:
```python
options = ClaudeAgentOptions(
    mcp_servers={
        "salesforce": {
            "command": "python",
            "args": ["/opt/mcp/salesforce_server.py"],
            "env": {
                "OAUTH_CLIENT_ID": os.environ["SF_CLIENT_ID"],
                "OAUTH_CLIENT_SECRET": os.environ["SF_CLIENT_SECRET"],
                "OAUTH_REFRESH_TOKEN": os.environ["SF_REFRESH_TOKEN"]
            }
        }
    }
)
```

**OAuth Flow in MCP Server**:
```python
# salesforce_server.py
import httpx
from mcp.server import Server

async def refresh_access_token():
    response = await httpx.post(
        "https://login.salesforce.com/services/oauth2/token",
        data={
            "grant_type": "refresh_token",
            "client_id": os.environ["OAUTH_CLIENT_ID"],
            "client_secret": os.environ["OAUTH_CLIENT_SECRET"],
            "refresh_token": os.environ["OAUTH_REFRESH_TOKEN"]
        }
    )
    return response.json()["access_token"]

# Use token in API calls
access_token = await refresh_access_token()
```

### VPC Isolation

**AWS Deployment**:
```yaml
# CloudFormation template
Resources:
  ClaudeAgentVPC:
    Type: AWS::EC2::VPC
    Properties:
      CidrBlock: 10.0.0.0/16
      EnableDnsHostnames: true

  PrivateSubnet:
    Type: AWS::EC2::Subnet
    Properties:
      VpcId: !Ref ClaudeAgentVPC
      CidrBlock: 10.0.1.0/24

  ClaudeAgentSecurityGroup:
    Type: AWS::EC2::SecurityGroup
    Properties:
      GroupDescription: Claude Agent API access
      VpcId: !Ref ClaudeAgentVPC
      SecurityGroupIngress:
        - IpProtocol: tcp
          FromPort: 443
          ToPort: 443
          CidrIp: 10.0.0.0/16  # Internal only

  ClaudeAgentService:
    Type: AWS::ECS::Service
    Properties:
      NetworkConfiguration:
        AwsvpcConfiguration:
          Subnets:
            - !Ref PrivateSubnet
          SecurityGroups:
            - !Ref ClaudeAgentSecurityGroup
```

### Secrets Management

**AWS Secrets Manager Integration**:
```python
import boto3
import json
from claude_agent_sdk import ClaudeAgentOptions

def get_secret(secret_name: str) -> dict:
    client = boto3.client('secretsmanager', region_name='us-east-1')
    response = client.get_secret_value(SecretId=secret_name)
    return json.loads(response['SecretString'])

# Retrieve secrets
anthropic_secret = get_secret('prod/claude/api-key')
github_secret = get_secret('prod/github/token')

options = ClaudeAgentOptions(
    mcp_servers={
        "github": {
            "command": "npx",
            "args": ["-y", "@modelcontextprotocol/server-github"],
            "env": {"GITHUB_TOKEN": github_secret['token']}
        }
    }
)

# API key from secrets
os.environ['ANTHROPIC_API_KEY'] = anthropic_secret['api_key']
```

### SAML/OIDC Integration

**Enterprise SSO Pattern**:
```python
from authlib.integrations.flask_client import OAuth

oauth = OAuth(app)
oauth.register(
    name='okta',
    client_id=os.environ['OKTA_CLIENT_ID'],
    client_secret=os.environ['OKTA_CLIENT_SECRET'],
    server_metadata_url=f'{os.environ["OKTA_DOMAIN"]}/.well-known/openid-configuration',
    client_kwargs={'scope': 'openid profile email'}
)

@app.route('/api/claude/query')
@require_auth  # OIDC authentication required
async def claude_query(request):
    user = request.user  # From OIDC token

    options = ClaudeAgentOptions(
        system_prompt=f"You are assisting {user.name} from {user.organization}",
        # User-specific permissions
    )

    async with ClaudeSDKClient(options=options) as client:
        # Process request
        pass
```

---

## Headless Mode Automation

Running Claude Agent SDK without user interaction.[^4]

### Fully Automated Execution

**Configuration**:
```python
options = ClaudeAgentOptions(
    permission_mode='acceptAll',  # No prompts
    allowed_tools=[
        "Read", "Write", "Bash",
        "mcp__database__query",
        "mcp__slack__post"
    ],
    max_turns=50  # Prevent infinite loops
)
```

**Automated Pipeline**:
```python
import asyncio
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions

async def automated_pipeline():
    options = ClaudeAgentOptions(
        system_prompt="""
        You are an automated CI/CD assistant.
        Execute tasks without asking for confirmation.
        Report results clearly.
        """,
        permission_mode='acceptAll',
        allowed_tools=["Read", "Bash", "Write", "mcp__slack__post"],
        mcp_servers={
            "slack": {
                "command": "npx",
                "args": ["-y", "@modelcontextprotocol/server-slack"],
                "env": {"SLACK_TOKEN": os.environ["SLACK_TOKEN"]}
            }
        }
    )

    async with ClaudeSDKClient(options=options) as client:
        await client.query("""
        1. Run test suite: pytest tests/ --cov
        2. If tests pass, build Docker image
        3. Push to registry
        4. Notify #engineering on Slack with results
        """)

        async for msg in client.receive_response():
            print(msg)

# Run in production
asyncio.run(automated_pipeline())
```

### Error Handling in Automation

**Robust Error Recovery**:
```python
from claude_agent_sdk.errors import (
    APIError,
    RateLimitError,
    ContextLengthExceededError
)
import asyncio

async def run_with_retry(query: str, max_retries: int = 3):
    for attempt in range(max_retries):
        try:
            async with ClaudeSDKClient(options=options) as client:
                await client.query(query)

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

        except ContextLengthExceededError:
            # Reduce scope and retry
            query = simplify_query(query)
            continue

        except APIError as e:
            # Log and notify
            await notify_error(e)
            raise

    raise Exception("Max retries exceeded")
```

---

## CI/CD Integration

Integrating Claude Agent SDK into continuous integration pipelines.[^5]

### Jenkins Pipeline

```groovy
// Jenkinsfile
pipeline {
    agent any

    environment {
        ANTHROPIC_API_KEY = credentials('anthropic-api-key')
    }

    stages {
        stage('Code Analysis') {
            steps {
                script {
                    sh '''
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install claude-agent-sdk
                    python ci/claude_analysis.py
                    '''
                }
            }
        }

        stage('Review Results') {
            steps {
                script {
                    def analysis = readFile('analysis_results.json')
                    def results = new groovy.json.JsonSlurper().parseText(analysis)

                    if (results.issues_found > 0) {
                        currentBuild.result = 'UNSTABLE'
                        echo "Found ${results.issues_found} issues"
                    }
                }
            }
        }
    }

    post {
        always {
            archiveArtifacts artifacts: 'analysis_results.json', fingerprint: true
        }
    }
}
```

### GitLab CI/CD

```yaml
# .gitlab-ci.yml
stages:
  - analyze
  - deploy

claude_analysis:
  stage: analyze
  image: python:3.11
  script:
    - pip install claude-agent-sdk
    - python ci/analysis.py
  artifacts:
    reports:
      junit: analysis_report.xml
  only:
    - merge_requests

production_deploy:
  stage: deploy
  script:
    - python ci/deploy_with_claude.py --environment production
  only:
    - main
  when: manual
```

### CircleCI Configuration

```yaml
# .circleci/config.yml
version: 2.1

orbs:
  python: circleci/python@2.1.1

jobs:
  claude-review:
    docker:
      - image: cimg/python:3.11
    steps:
      - checkout
      - python/install-packages:
          pkg-manager: pip
          pip-dependency-file: requirements.txt
      - run:
          name: Run Claude Analysis
          command: python ci/claude_review.py
      - store_artifacts:
          path: review_results.json

workflows:
  version: 2
  build-and-review:
    jobs:
      - claude-review
```

---

## Monitoring & Observability

Production monitoring patterns for Claude Agent SDK.[^6]

### Logging Integration

**Structured Logging**:
```python
import logging
import json
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions, HookMatcher

# Configure structured logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger('claude_agent')

async def log_tool_execution(input_data, tool_use_id, context):
    logger.info(json.dumps({
        "event": "tool_execution",
        "tool_name": input_data["tool_name"],
        "tool_use_id": tool_use_id,
        "input": input_data["tool_input"],
        "timestamp": context.get("timestamp")
    }))
    return {}

async def log_results(input_data, tool_use_id, context):
    logger.info(json.dumps({
        "event": "tool_result",
        "tool_use_id": tool_use_id,
        "success": not context.get("is_error", False)
    }))
    return {}

options = ClaudeAgentOptions(
    hooks={
        "PreToolUse": [HookMatcher(matcher="*", hooks=[log_tool_execution])],
        "PostToolUse": [HookMatcher(matcher="*", hooks=[log_results])]
    }
)
```

### Metrics Collection

**Prometheus Integration**:
```python
from prometheus_client import Counter, Histogram, Gauge
import time

# Define metrics
claude_requests = Counter('claude_requests_total', 'Total Claude SDK requests')
claude_duration = Histogram('claude_request_duration_seconds', 'Request duration')
claude_active = Gauge('claude_active_sessions', 'Active Claude sessions')

async def monitored_query(query: str):
    claude_requests.inc()
    claude_active.inc()

    start_time = time.time()
    try:
        async with ClaudeSDKClient(options=options) as client:
            await client.query(query)

            result = []
            async for msg in client.receive_response():
                result.append(msg)

            return "".join(result)
    finally:
        duration = time.time() - start_time
        claude_duration.observe(duration)
        claude_active.dec()
```

### Distributed Tracing

**OpenTelemetry Integration**:
```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.jaeger.thrift import JaegerExporter

# Configure tracing
trace.set_tracer_provider(TracerProvider())
jaeger_exporter = JaegerExporter(
    agent_host_name='jaeger',
    agent_port=6831,
)
trace.get_tracer_provider().add_span_processor(
    BatchSpanProcessor(jaeger_exporter)
)

tracer = trace.get_tracer(__name__)

async def traced_query(query: str):
    with tracer.start_as_current_span("claude_query") as span:
        span.set_attribute("query.text", query)

        async with ClaudeSDKClient(options=options) as client:
            await client.query(query)

            result = []
            async for msg in client.receive_response():
                result.append(msg)

            response = "".join(result)
            span.set_attribute("response.length", len(response))

            return response
```

---

## Error Handling & Resilience

Production-ready error handling patterns for robust SDK deployments.

### Exponential Backoff for Rate Limits

**Pattern**: Retry with increasing delays to handle rate limits gracefully

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions, ProcessError
import logging

logger = logging.getLogger(__name__)

async def query_with_retry(
    prompt: str,
    options: ClaudeAgentOptions | None = None,
    max_retries: int = 3,
    base_delay: float = 1.0
):
    """Production-ready query with exponential backoff for rate limits."""

    for attempt in range(max_retries):
        try:
            response = []
            async for message in query(prompt=prompt, options=options):
                response.append(message)
            return response

        except ProcessError as e:
            # Check if rate limit error
            if "rate_limit" in str(e).lower() or "429" in str(e):
                if attempt < max_retries - 1:
                    # Exponential backoff: 1s, 2s, 4s, 8s...
                    wait_time = base_delay * (2 ** attempt)
                    logger.warning(
                        f"Rate limited (attempt {attempt + 1}/{max_retries}). "
                        f"Retrying in {wait_time}s..."
                    )
                    await asyncio.sleep(wait_time)
                else:
                    logger.error(f"Failed after {max_retries} retries due to rate limit")
                    raise
            else:
                # Non-rate-limit error, re-raise immediately
                logger.error(f"Query failed with non-rate-limit error: {e}")
                raise

    raise Exception(f"Failed after {max_retries} retries")


# Usage
async def main():
    result = await query_with_retry(
        prompt="Analyze authentication.py",
        max_retries=5,
        base_delay=1.0
    )
```

**Benefits**:
- Automatically handles temporary rate limits
- Exponential backoff prevents thundering herd
- Configurable retry attempts and delays
- Distinguishes rate limits from other errors

### Graceful Degradation

**Pattern**: Fallback to simpler functionality when full SDK unavailable

```python
from claude_agent_sdk import (
    ClaudeSDKClient,
    ClaudeAgentOptions,
    CLIConnectionError,
    ProcessError,
    query
)

async def resilient_code_analysis(file_path: str):
    """Multi-tier fallback for code analysis."""

    # Tier 1: Full SDK with tools (best quality)
    try:
        options = ClaudeAgentOptions(
            allowed_tools=["Read", "Grep", "Bash"],
            permission_mode="acceptEdits",
            max_tokens=4096
        )

        async with ClaudeSDKClient(options=options) as client:
            await client.query(f"Deep analysis of {file_path} with tools")

            result = []
            async for msg in client.receive_response():
                result.append(msg)

            logger.info("Tier 1: Full analysis successful")
            return {"tier": 1, "result": result}

    except CLIConnectionError:
        logger.warning("Tier 1 failed: Claude CLI not available, falling back to Tier 2")

    # Tier 2: Simple query without tools (medium quality)
    try:
        result = []
        async for msg in query(prompt=f"Quick summary of {file_path}"):
            result.append(msg)

        logger.info("Tier 2: Simple query successful")
        return {"tier": 2, "result": result}

    except ProcessError:
        logger.warning("Tier 2 failed: Process error, falling back to Tier 3")

    # Tier 3: Static analysis fallback (basic quality)
    logger.warning("All SDK tiers failed, using static analysis")
    return {
        "tier": 3,
        "result": f"Static analysis of {file_path} (SDK unavailable)"
    }


# Usage
async def main():
    result = await resilient_code_analysis("/src/auth.py")
    print(f"Analysis completed using Tier {result['tier']}")
```

**Tiers**:
1. **Full SDK**: All tools, highest quality
2. **Simple Query**: No tools, medium quality
3. **Fallback**: Static analysis or cached data

### Circuit Breaker Pattern

**Pattern**: Prevent cascading failures by temporarily disabling failing operations

```python
from datetime import datetime, timedelta
from enum import Enum

class CircuitState(Enum):
    CLOSED = "closed"      # Normal operation
    OPEN = "open"          # Failing, reject requests
    HALF_OPEN = "half_open"  # Testing recovery

class CircuitBreaker:
    """Circuit breaker for SDK operations."""

    def __init__(
        self,
        failure_threshold: int = 5,
        timeout: float = 60.0,
        success_threshold: int = 2
    ):
        self.failure_threshold = failure_threshold
        self.timeout = timeout
        self.success_threshold = success_threshold

        self.failure_count = 0
        self.success_count = 0
        self.last_failure_time = None
        self.state = CircuitState.CLOSED

    def _should_attempt(self) -> bool:
        """Check if request should be attempted."""

        if self.state == CircuitState.CLOSED:
            return True

        if self.state == CircuitState.OPEN:
            # Check if timeout elapsed
            if self.last_failure_time:
                elapsed = (datetime.now() - self.last_failure_time).total_seconds()
                if elapsed >= self.timeout:
                    self.state = CircuitState.HALF_OPEN
                    return True
            return False

        # HALF_OPEN state
        return True

    async def call(self, operation):
        """Execute operation with circuit breaker protection."""

        if not self._should_attempt():
            raise Exception("Circuit breaker OPEN - request rejected")

        try:
            result = await operation()

            # Success handling
            if self.state == CircuitState.HALF_OPEN:
                self.success_count += 1
                if self.success_count >= self.success_threshold:
                    self.state = CircuitState.CLOSED
                    self.failure_count = 0
                    self.success_count = 0
                    logger.info("Circuit breaker CLOSED - recovered")

            return result

        except Exception as e:
            # Failure handling
            self.failure_count += 1
            self.last_failure_time = datetime.now()

            if self.failure_count >= self.failure_threshold:
                self.state = CircuitState.OPEN
                logger.error(f"Circuit breaker OPEN - {self.failure_count} failures")

            raise


# Usage
circuit_breaker = CircuitBreaker(
    failure_threshold=5,
    timeout=60.0,
    success_threshold=2
)

async def analyze_with_circuit_breaker(file_path: str):
    """Code analysis with circuit breaker protection."""

    async def operation():
        result = []
        async for msg in query(prompt=f"Analyze {file_path}"):
            result.append(msg)
        return result

    try:
        return await circuit_breaker.call(operation)
    except Exception as e:
        logger.error(f"Circuit breaker prevented call: {e}")
        return None
```

**Benefits**:
- Prevents cascading failures
- Automatic recovery detection
- Configurable thresholds and timeouts
- Protects downstream systems

### Timeout Management

**Pattern**: Set appropriate timeouts for different operation types

```python
import asyncio
from claude_agent_sdk import query, ClaudeAgentOptions

async def query_with_timeout(
    prompt: str,
    timeout_seconds: float = 30.0,
    options: ClaudeAgentOptions | None = None
):
    """Execute query with timeout protection."""

    try:
        result = await asyncio.wait_for(
            _execute_query(prompt, options),
            timeout=timeout_seconds
        )
        return result

    except asyncio.TimeoutError:
        logger.error(f"Query timed out after {timeout_seconds}s")
        raise


async def _execute_query(prompt: str, options: ClaudeAgentOptions | None):
    """Internal query execution."""
    result = []
    async for msg in query(prompt=prompt, options=options):
        result.append(msg)
    return result


# Usage with different timeout strategies
async def main():
    # Short timeout for simple queries
    quick_result = await query_with_timeout(
        "What is 2 + 2?",
        timeout_seconds=10.0
    )

    # Longer timeout for complex analysis
    analysis_result = await query_with_timeout(
        "Perform deep code analysis",
        timeout_seconds=120.0
    )
```

**Timeout Recommendations**:
- **Simple queries**: 10-30 seconds
- **Code analysis**: 60-120 seconds
- **Multi-file operations**: 120-300 seconds
- **Tool-heavy workflows**: 300-600 seconds

### Error Categorization

**Pattern**: Classify and handle different error types appropriately

```python
from claude_agent_sdk import (
    CLIConnectionError,
    CLINotFoundError,
    ProcessError,
    CLIJSONDecodeError
)

class ErrorCategory(Enum):
    TRANSIENT = "transient"      # Retry possible
    PERMANENT = "permanent"      # Don't retry
    CONFIGURATION = "configuration"  # Fix config

def categorize_error(error: Exception) -> ErrorCategory:
    """Categorize error for appropriate handling."""

    if isinstance(error, CLINotFoundError):
        return ErrorCategory.CONFIGURATION  # Claude CLI not installed

    if isinstance(error, ProcessError):
        if "rate_limit" in str(error).lower():
            return ErrorCategory.TRANSIENT  # Rate limit - retry
        if "context length" in str(error).lower():
            return ErrorCategory.PERMANENT  # Too long - can't retry
        return ErrorCategory.TRANSIENT  # Other process errors - retry

    if isinstance(error, CLIJSONDecodeError):
        return ErrorCategory.TRANSIENT  # Might be temporary

    return ErrorCategory.PERMANENT


async def handle_categorized_error(error: Exception) -> str:
    """Handle error based on category."""

    category = categorize_error(error)

    if category == ErrorCategory.TRANSIENT:
        logger.warning(f"Transient error: {error}. Retry recommended.")
        return "retry"

    elif category == ErrorCategory.CONFIGURATION:
        logger.error(f"Configuration error: {error}. Fix required.")
        return "fix_config"

    else:  # PERMANENT
        logger.error(f"Permanent error: {error}. Cannot retry.")
        return "fail"


# Usage
async def robust_operation():
    """Operation with categorized error handling."""

    try:
        result = await query_with_retry("Analyze code")
        return result

    except Exception as e:
        action = await handle_categorized_error(e)

        if action == "retry":
            # Already handled by query_with_retry
            pass
        elif action == "fix_config":
            raise Exception("Please install Claude CLI: npm install -g @anthropic-ai/claude-code")
        else:  # fail
            raise
```

---

## Cost Management

Strategies for optimizing API costs in production.[^7]

### Token Usage Tracking

**Cost Calculation**:
```python
from claude_agent_sdk import ClaudeAgentOptions

# Model pricing (per million tokens)
PRICING = {
    "claude-sonnet-4-5-20250929": {"input": 3.00, "output": 15.00},
    "claude-opus-4": {"input": 15.00, "output": 75.00},
    "claude-haiku-4": {"input": 0.80, "output": 4.00}
}

class CostTracker:
    def __init__(self, model: str):
        self.model = model
        self.input_tokens = 0
        self.output_tokens = 0

    def calculate_cost(self) -> float:
        pricing = PRICING[self.model]
        input_cost = (self.input_tokens / 1_000_000) * pricing["input"]
        output_cost = (self.output_tokens / 1_000_000) * pricing["output"]
        return input_cost + output_cost

    async def tracked_query(self, query: str):
        # Estimate input tokens (rough: 4 chars ≈ 1 token)
        self.input_tokens += len(query) // 4

        async with ClaudeSDKClient(
            options=ClaudeAgentOptions(model=self.model)
        ) as client:
            await client.query(query)

            result = []
            async for msg in client.receive_response():
                result.append(msg)
                self.output_tokens += len(msg) // 4

            return "".join(result)

# Usage
tracker = CostTracker("claude-sonnet-4-5-20250929")
await tracker.tracked_query("Analyze this codebase")
print(f"Cost: ${tracker.calculate_cost():.4f}")
```

### Prompt Caching

**90% Cost Reduction** with prompt caching:[^8]
```python
options = ClaudeAgentOptions(
    system_prompt="""
    <large stable context that rarely changes>
    - Coding standards
    - Architecture documentation
    - API references
    </large stable context>
    """,
    model="claude-sonnet-4-5-20250929"
)

# First request: Full cost
# Subsequent requests: 90% cheaper for cached content
```

### Dynamic Model Routing

**70% Cost Reduction** by using cheaper models when appropriate:
```python
async def smart_query(query: str, complexity: str = "auto"):
    # Auto-detect complexity
    if complexity == "auto":
        complexity = detect_complexity(query)

    # Route to appropriate model
    if complexity == "simple":
        model = "claude-haiku-4"  # Cheapest
    elif complexity == "medium":
        model = "claude-sonnet-4-5-20250929"  # Balanced
    else:
        model = "claude-opus-4"  # Most capable

    options = ClaudeAgentOptions(model=model)

    async with ClaudeSDKClient(options=options) as client:
        await client.query(query)
        # Process response

def detect_complexity(query: str) -> str:
    # Simple heuristics
    if len(query) < 100 and "?" in query:
        return "simple"
    elif any(word in query.lower() for word in ["analyze", "design", "architect"]):
        return "complex"
    else:
        return "medium"
```

---

## Scaling Architectures

Patterns for scaling Claude Agent SDK to handle high load.[^9]

### Horizontal Scaling

**Load Balanced Architecture**:
```python
# Multiple worker processes
from multiprocessing import Process, Queue
import asyncio

def worker(queue: Queue, worker_id: int):
    async def process_tasks():
        options = ClaudeAgentOptions(
            permission_mode='acceptAll',
            max_tokens=4096
        )

        while True:
            task = queue.get()
            if task is None:
                break

            async with ClaudeSDKClient(options=options) as client:
                await client.query(task["query"])

                result = []
                async for msg in client.receive_response():
                    result.append(msg)

                task["callback"]("".join(result))

    asyncio.run(process_tasks())

# Start worker pool
num_workers = 4
queue = Queue()
workers = [
    Process(target=worker, args=(queue, i))
    for i in range(num_workers)
]

for w in workers:
    w.start()

# Submit tasks
queue.put({"query": "Task 1", "callback": lambda r: print(r)})
queue.put({"query": "Task 2", "callback": lambda r: print(r)})
```

### Async Task Queue

**Celery Integration**:
```python
from celery import Celery
import asyncio
from claude_agent_sdk import ClaudeSDKClient, ClaudeAgentOptions

app = Celery('claude_tasks', broker='redis://localhost:6379/0')

@app.task
def process_with_claude(query: str) -> str:
    async def run_query():
        options = ClaudeAgentOptions(
            allowed_tools=["Read", "WebFetch"],
            permission_mode='acceptAll'
        )

        async with ClaudeSDKClient(options=options) as client:
            await client.query(query)

            result = []
            async for msg in client.receive_response():
                result.append(msg)

            return "".join(result)

    return asyncio.run(run_query())

# Submit tasks
result = process_with_claude.delay("Analyze market trends")
print(result.get(timeout=300))
```

### Connection Pooling

**Reusable Client Pattern**:
```python
from contextlib import asynccontextmanager
import asyncio

class ClaudeClientPool:
    def __init__(self, pool_size: int = 10):
        self.pool_size = pool_size
        self.clients = asyncio.Queue(maxsize=pool_size)
        self.options = ClaudeAgentOptions(
            permission_mode='acceptAll',
            max_tokens=4096
        )

    async def initialize(self):
        for _ in range(self.pool_size):
            client = ClaudeSDKClient(options=self.options)
            await client.__aenter__()
            await self.clients.put(client)

    @asynccontextmanager
    async def get_client(self):
        client = await self.clients.get()
        try:
            yield client
        finally:
            await self.clients.put(client)

    async def close(self):
        while not self.clients.empty():
            client = await self.clients.get()
            await client.__aexit__(None, None, None)

# Usage
pool = ClaudeClientPool(pool_size=5)
await pool.initialize()

async with pool.get_client() as client:
    await client.query("Process this task")
    # Use client
```

### Rate Limit Management

**Intelligent Rate Limiting**:
```python
import asyncio
from datetime import datetime, timedelta

class RateLimiter:
    def __init__(self, requests_per_minute: int = 50):
        self.rpm = requests_per_minute
        self.requests = []

    async def acquire(self):
        now = datetime.now()
        # Remove requests older than 1 minute
        self.requests = [
            req for req in self.requests
            if now - req < timedelta(minutes=1)
        ]

        if len(self.requests) >= self.rpm:
            # Wait until oldest request is 1 minute old
            sleep_time = 60 - (now - self.requests[0]).total_seconds()
            await asyncio.sleep(sleep_time)

        self.requests.append(now)

# Usage with rate limiting
limiter = RateLimiter(requests_per_minute=50)

async def rate_limited_query(query: str):
    await limiter.acquire()

    async with ClaudeSDKClient(options=options) as client:
        await client.query(query)
        # Process response
```

---

## References

[^1]: Anthropic. "Claude Agent SDK Production Deployment." Enterprise Documentation, 2025. https://docs.anthropic.com/en/docs/claude-code/sdk/production
[^2]: Claude Docs. "CLAUDE.md Configuration." Multi-level Setup, 2025. https://docs.claude.com/en/docs/claude-code/claudemd
[^3]: PromptLayer. "Building Agents with Claude Code's SDK." Security Patterns, 2025. https://blog.promptlayer.com/building-agents-with-claude-codes-sdk/
[^4]: DataCamp. "Claude Agent SDK Tutorial." Headless Automation, 2025. https://www.datacamp.com/tutorial/how-to-use-claude-agent-sdk
[^5]: Anthropic. "CI/CD Integration Patterns." Automation Guide, 2025. https://docs.anthropic.com/en/docs/claude-code/cicd
[^6]: New Relic. "Monitoring AI Agents." Observability Best Practices, 2025. https://newrelic.com/blog/how-to-relic/monitoring-ai-agents
[^7]: Anthropic. "Pricing and Cost Optimization." Claude API Docs, 2025. https://docs.anthropic.com/en/api/pricing
[^8]: Anthropic. "Prompt Caching." Cost Optimization, 2025. https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching
[^9]: AWS. "Scaling AI Applications." Architecture Patterns, 2025. https://aws.amazon.com/blogs/machine-learning/scaling-ai-applications

[**→ Complete Bibliography**](references.md)

[← Back to Documentation Index](index.md)
