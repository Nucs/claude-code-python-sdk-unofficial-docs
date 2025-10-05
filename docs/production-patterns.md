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
