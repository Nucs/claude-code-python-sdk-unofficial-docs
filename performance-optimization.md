# Performance & Optimization - Claude Agent SDK

> **Benchmarks, cost analysis, and optimization techniques for production performance**

[← Back to Index](INDEX.md)

---

## Table of Contents

1. [Performance Benchmarks](#performance-benchmarks)
2. [Model Comparison](#model-comparison)
3. [Cost Analysis](#cost-analysis)
4. [Context Optimization](#context-optimization)
5. [Token Efficiency](#token-efficiency)
6. [Scaling Performance](#scaling-performance)
7. [Caching Strategies](#caching-strategies)

---

## Performance Benchmarks

Claude Agent SDK demonstrates industry-leading performance across multiple benchmarks.[^1]

### SWE-bench Verified

**Benchmark**: Software engineering tasks requiring code understanding and modification

**Claude Agent SDK Performance**:
- **Score**: 77.2% (Industry leading)
- **Comparison**:
  - Claude Opus: 31% (direct API)
  - GPT-4: 28%
  - Open source models: < 15%

**What This Means**:[^2]
- 77.2% of software engineering tasks completed correctly
- Includes: bug fixing, feature implementation, refactoring
- Real-world codebase scenarios

### Agent Loop Efficiency

**Tool Execution Speed**:
```
Built-in Tools:
- Read: < 50ms (average file)
- Write: < 100ms (average file)
- Edit: < 75ms (exact string replacement)
- Bash: 200ms - 10min (command dependent)
- Grep: < 150ms (single file)
- Glob: < 100ms (directory traversal)

MCP Tools:
- In-process: 50-200ms overhead
- External: 100-500ms overhead (stdio communication)
```

### Context Management Performance

**Compaction Speeds**:[^3]
- **Micro-compact**: 1-3 seconds (tool result compression)
- **Auto-compact**: 5-15 seconds (message summarization)
- **Manual compact**: 10-30 seconds (full conversation compression)

**Context Window Impact**:
```
Context Size → Response Time:
- 10K tokens: 2-4 seconds
- 50K tokens: 5-10 seconds
- 100K tokens: 10-20 seconds
- 200K tokens: 20-40 seconds (max window)
```

---

## Model Comparison

Performance and cost characteristics of Claude models.[^4]

### Model Capabilities Matrix

| Model | Input Price | Output Price | Speed | Best Use Case |
|-------|-------------|--------------|-------|---------------|
| **Claude Sonnet 4.5** | $3/M tokens | $15/M tokens | Fast | Balanced performance/cost |
| **Claude Opus 4** | $15/M tokens | $75/M tokens | Slower | Complex reasoning tasks |
| **Claude Haiku 4** | $0.80/M tokens | $4.00/M tokens | Fastest | Simple, high-volume tasks |

### Model Selection Guidelines

**Use Claude Opus 4** when:
- Complex architectural decisions required
- Multi-step reasoning with high accuracy needed
- Debugging intricate system issues
- Cost is secondary to quality

**Use Claude Sonnet 4.5** when:
- Balanced performance and cost needed (default)
- General development tasks
- Code review and analysis
- Most production scenarios

**Use Claude Haiku 4** when:
- Simple, repetitive tasks
- High-volume processing
- Cost optimization critical
- Quick responses required

### Performance vs Cost Trade-offs

**Example: Code Review Task**

```python
# Opus: Highest quality, 5x cost
options_opus = ClaudeAgentOptions(
    model="claude-opus-4",
    system_prompt="Provide detailed architectural review"
)
# Cost: ~$0.20 per review
# Time: 15-30 seconds
# Quality: Comprehensive

# Sonnet: Balanced
options_sonnet = ClaudeAgentOptions(
    model="claude-sonnet-4-5-20250929",
    system_prompt="Review code for issues and improvements"
)
# Cost: ~$0.04 per review
# Time: 8-15 seconds
# Quality: Very good

# Haiku: Fast and cheap
options_haiku = ClaudeAgentOptions(
    model="claude-haiku-4",
    system_prompt="Check for common code issues"
)
# Cost: ~$0.01 per review
# Time: 3-5 seconds
# Quality: Good for basic checks
```

---

## Cost Analysis

Detailed cost breakdown and optimization strategies.[^5]

### Pricing Structure

**Claude Sonnet 4.5** (Most Common):
- Input: $3 per million tokens
- Output: $15 per million tokens
- Ratio: Output is 5x more expensive than input

**Cost Calculation Formula**:
```python
def calculate_cost(input_tokens: int, output_tokens: int, model: str) -> float:
    pricing = {
        "claude-sonnet-4-5-20250929": {"input": 3.00, "output": 15.00},
        "claude-opus-4": {"input": 15.00, "output": 75.00},
        "claude-haiku-4": {"input": 0.80, "output": 4.00}
    }

    rates = pricing[model]
    input_cost = (input_tokens / 1_000_000) * rates["input"]
    output_cost = (output_tokens / 1_000_000) * rates["output"]

    return input_cost + output_cost

# Example: 10K input, 2K output with Sonnet
cost = calculate_cost(10000, 2000, "claude-sonnet-4-5-20250929")
print(f"${cost:.4f}")  # $0.0600
```

### Real-World Cost Examples

**Scenario 1: Code Analysis** (Typical)
- Input: 15K tokens (codebase context)
- Output: 3K tokens (analysis report)
- Model: Sonnet 4.5
- **Cost**: $0.09 per analysis

**Scenario 2: Feature Implementation** (Complex)
- Input: 50K tokens (large codebase)
- Output: 8K tokens (implementation + tests)
- Model: Sonnet 4.5
- **Cost**: $0.27 per feature

**Scenario 3: Batch Processing** (High Volume)
- Input: 5K tokens per item
- Output: 1K tokens per item
- Model: Haiku 4
- Volume: 1000 items
- **Cost**: $8.00 total ($0.008 per item)

### Monthly Cost Projections

**Development Team** (10 developers):
```
Daily usage per developer:
- 50 queries
- Average 10K input, 2K output
- Model: Sonnet 4.5

Daily cost per developer: $3.00
Monthly cost per developer: $60.00
Team monthly cost: $600.00
```

**CI/CD Pipeline** (Active project):
```
Per PR automated review:
- Input: 20K tokens
- Output: 5K tokens
- Model: Sonnet 4.5

Cost per PR: $0.14
100 PRs/month: $14.00
```

**Production API Service** (High volume):
```
Customer support automation:
- 10,000 requests/day
- Average 3K input, 800 output
- Model: Haiku 4

Daily cost: $56.00
Monthly cost: $1,680.00
```

---

## Context Optimization

Strategies for managing context window efficiently.[^6]

### Context Window Limits

**Maximum Sizes**:
- Claude Opus 4: 200,000 tokens
- Claude Sonnet 4.5: 200,000 tokens
- Claude Haiku 4: 200,000 tokens

**Practical Limits**:
- Recommended: < 100K tokens for best performance
- Cost effective: < 50K tokens
- Optimal: < 25K tokens

### Micro-Compact Strategy

**Automatic Tool Result Compression**:
```python
# Large tool output automatically compressed
await client.query("Read all Python files in src/")

# Claude receives full content initially
# Micro-compact reduces to summary:
# "Read 47 Python files (total 150K tokens) → compressed to 15K"
```

**When Triggered**:
- Tool result > 10K tokens
- Multiple similar tool outputs
- Repetitive data structures

**Compression Rate**: 70-90% reduction

### Auto-Compact Configuration

**Customizing Auto-Compact**:
```python
options = ClaudeAgentOptions(
    max_tokens=8192,  # Lower = more frequent compaction
    max_turns=50      # Compact when approaching limit
)

# Auto-compact triggers at ~75% context usage
# Compresses older messages while preserving recent context
```

**Selective Message Retention**:
- System prompts: Always preserved
- Recent messages: Last 5-10 turns kept
- Tool results: Summarized to key findings
- Code snippets: Compressed or referenced

### Manual Compaction

**Explicit Control**:
```python
async with ClaudeSDKClient(options=options) as client:
    # Long-running session
    await client.query("Analyze module 1")
    # ... many operations ...

    # Force compaction before next phase
    await client.query("/compact")  # Manual compact command

    await client.query("Analyze module 2")
    # Fresh context for new analysis
```

### Context-Aware Prompt Design

**Efficient Prompts**:
```python
# ❌ Inefficient - Repeats context
for file in files:
    await client.query(f"""
    Project standards:
    - Use TypeScript
    - Follow ESLint rules
    - Write tests for all functions

    Review {file}
    """)

# ✅ Efficient - Context in system prompt
options = ClaudeAgentOptions(
    system_prompt="""
    Project standards:
    - Use TypeScript
    - Follow ESLint rules
    - Write tests for all functions
    """
)

for file in files:
    await client.query(f"Review {file}")
    # Standards already in context
```

---

## Token Efficiency

Techniques for minimizing token usage.[^7]

### Prompt Optimization

**Concise Instructions**:
```python
# ❌ Verbose (150 tokens)
await client.query("""
I would like you to please carefully analyze the authentication
system in our application. Could you look at how users are
currently logging in and provide some suggestions on how we
might improve the security? Also, please check if there are
any potential vulnerabilities that we should be aware of.
""")

# ✅ Concise (45 tokens)
await client.query("""
Analyze authentication system:
1. Review login implementation
2. Identify security improvements
3. List potential vulnerabilities
""")
```

**Structured Output Requests**:
```python
# Request specific format to reduce output tokens
await client.query("""
Find TODO comments. Output format:
File | Line | TODO text
""")

# Results in compact table vs verbose explanations
```

### Tool Result Filtering

**Selective Tool Usage**:
```python
# ❌ Over-fetching
await client.query("Read all files and find security issues")
# Reads everything, wastes tokens on irrelevant content

# ✅ Targeted approach
await client.query("""
1. Use Grep to find files with 'password' or 'auth'
2. Read only those files
3. Analyze for security issues
""")
# Reads only relevant files, saves tokens
```

### Response Length Control

**Token Budgeting**:
```python
options = ClaudeAgentOptions(
    max_tokens=1024  # Limit response length
)

# Forces concise responses
# Good for: Simple queries, batch processing
# Avoid for: Complex analysis, code generation
```

### Conversation Turn Optimization

**Batch Related Questions**:
```python
# ❌ Multiple turns (high context overhead)
await client.query("What's in config.py?")
await client.query("Are there security issues?")
await client.query("How can we improve it?")

# ✅ Single comprehensive turn
await client.query("""
For config.py:
1. Summarize contents
2. Identify security issues
3. Suggest improvements
""")
```

---

## Scaling Performance

Performance patterns for high-throughput scenarios.[^8]

### Parallel Execution

**Concurrent Requests**:
```python
import asyncio

async def process_file(file_path: str):
    async with ClaudeSDKClient(options=options) as client:
        await client.query(f"Analyze {file_path}")

        result = []
        async for msg in client.receive_response():
            result.append(msg)

        return "".join(result)

# Process 10 files concurrently
files = ["file1.py", "file2.py", ..., "file10.py"]
results = await asyncio.gather(*[process_file(f) for f in files])

# 10x faster than sequential processing
```

**Throughput Benchmarks**:
- Sequential: 1 request every 5s = 12 requests/min
- Parallel (10 concurrent): 10 requests every 5s = 120 requests/min
- **10x throughput improvement**

### Subagent Parallelization

**Built-in Parallel Processing**:
```python
await client.query("""
Analyze codebase in parallel:
1. Check Python files for bugs
2. Review TypeScript for type issues
3. Scan for security vulnerabilities
4. Validate test coverage
""")

# Claude spawns 4 subagents automatically
# Each with isolated context
# Results merged in main agent
```

**Performance Characteristics**:
- Subagent startup: 1-2 seconds
- Parallel execution: Up to 5 concurrent subagents
- Context isolation: No token sharing between subagents
- **3-5x faster** for independent tasks

### Batch Processing Patterns

**High-Volume Processing**:
```python
from concurrent.futures import ThreadPoolExecutor
import asyncio

async def process_batch(items: list, batch_size: int = 10):
    results = []

    for i in range(0, len(items), batch_size):
        batch = items[i:i + batch_size]

        # Process batch concurrently
        batch_results = await asyncio.gather(*[
            process_item(item) for item in batch
        ])

        results.extend(batch_results)

        # Brief pause to respect rate limits
        await asyncio.sleep(0.1)

    return results

# Process 1000 items in batches of 10
results = await process_batch(items, batch_size=10)

# Throughput: ~600 items/hour (with rate limiting)
```

### Connection Pooling

**Reusable Client Connections**:
```python
class ClientPool:
    def __init__(self, size: int = 5):
        self.size = size
        self.clients = []

    async def initialize(self):
        for _ in range(self.size):
            client = ClaudeSDKClient(options=options)
            await client.__aenter__()
            self.clients.append(client)

    async def execute(self, queries: list):
        results = []

        for i, query in enumerate(queries):
            client = self.clients[i % self.size]
            await client.query(query)

            result = []
            async for msg in client.receive_response():
                result.append(msg)

            results.append("".join(result))

        return results

# Reuse 5 clients for 100 queries
pool = ClientPool(size=5)
await pool.initialize()
results = await pool.execute(queries)

# Avoids client initialization overhead
# 20-30% faster for batch processing
```

---

## Caching Strategies

Leveraging caching for dramatic cost and speed improvements.[^9]

### Prompt Caching (90% Savings)

**How It Works**:
- Cache stable context (system prompts, documentation)
- Pay full price first time
- Pay 10% for cached content on subsequent requests

**Implementation**:
```python
options = ClaudeAgentOptions(
    system_prompt="""
    <STABLE_CONTEXT>
    # Project Documentation (50K tokens)
    - Architecture overview
    - Coding standards
    - API references
    - Common patterns
    </STABLE_CONTEXT>
    """,
    model="claude-sonnet-4-5-20250929"
)

# First query: Full cost (~$0.15 for 50K context)
# Subsequent queries: 90% discount (~$0.015 for same context)
```

**Cost Comparison**:
```
Without Caching:
- 100 queries × 50K context × $3/M = $15.00

With Caching:
- 1st query: 50K × $3/M = $0.15
- 99 queries: 50K × $0.30/M = $1.49
- Total: $1.64
- Savings: $13.36 (89% reduction)
```

### Response Caching

**Application-Level Caching**:
```python
import hashlib
import json
from typing import Optional

class ResponseCache:
    def __init__(self):
        self.cache = {}

    def get_cache_key(self, query: str, options: dict) -> str:
        content = json.dumps({"query": query, "options": options}, sort_keys=True)
        return hashlib.md5(content.encode()).hexdigest()

    async def get_or_compute(
        self,
        query: str,
        options: ClaudeAgentOptions
    ) -> str:
        cache_key = self.get_cache_key(query, vars(options))

        if cache_key in self.cache:
            print("Cache hit!")
            return self.cache[cache_key]

        print("Cache miss, computing...")
        async with ClaudeSDKClient(options=options) as client:
            await client.query(query)

            result = []
            async for msg in client.receive_response():
                result.append(msg)

            response = "".join(result)
            self.cache[cache_key] = response
            return response

# Usage
cache = ResponseCache()

# First call: Executes query
result1 = await cache.get_or_compute("Analyze auth.py", options)

# Second call: Returns cached result
result2 = await cache.get_or_compute("Analyze auth.py", options)
# Instant response, zero cost
```

### Tool Result Caching

**MCP Server Caching**:
```python
from functools import lru_cache
from mcp.server import Server

server = Server("cached-server")

@lru_cache(maxsize=100)
def expensive_computation(param: str) -> str:
    # Expensive operation (database query, API call, etc.)
    return perform_expensive_work(param)

@server.call_tool()
async def call_tool(name: str, arguments: dict):
    if name == "compute":
        # Results cached for repeated calls
        result = expensive_computation(arguments["param"])

        return [{"type": "text", "text": result}]
```

**Benefits**:
- Avoid redundant tool executions
- Faster response times
- Reduced external API costs

### Semantic Caching

**Vector-Based Similarity Matching**:
```python
from sentence_transformers import SentenceTransformer
import numpy as np

class SemanticCache:
    def __init__(self, similarity_threshold: float = 0.95):
        self.model = SentenceTransformer('all-MiniLM-L6-v2')
        self.threshold = similarity_threshold
        self.cache = []  # [(embedding, query, response), ...]

    async def get_or_compute(self, query: str, compute_fn):
        # Compute query embedding
        query_embedding = self.model.encode([query])[0]

        # Check for similar cached queries
        for cached_emb, cached_query, cached_response in self.cache:
            similarity = np.dot(query_embedding, cached_emb) / (
                np.linalg.norm(query_embedding) * np.linalg.norm(cached_emb)
            )

            if similarity >= self.threshold:
                print(f"Semantic cache hit! (similarity: {similarity:.2f})")
                return cached_response

        # Compute new response
        response = await compute_fn(query)

        # Cache for future
        self.cache.append((query_embedding, query, response))

        return response

# Usage
semantic_cache = SemanticCache(similarity_threshold=0.95)

# Matches semantically similar queries
await semantic_cache.get_or_compute("Review authentication code", compute)
await semantic_cache.get_or_compute("Analyze auth implementation", compute)
# Second query hits cache (95% similar)
```

### Cache Invalidation Strategies

**Time-Based Expiration**:
```python
import time
from typing import Tuple, Optional

class TTLCache:
    def __init__(self, ttl_seconds: int = 3600):
        self.ttl = ttl_seconds
        self.cache = {}  # key: (value, timestamp)

    def get(self, key: str) -> Optional[str]:
        if key in self.cache:
            value, timestamp = self.cache[key]
            if time.time() - timestamp < self.ttl:
                return value
            else:
                del self.cache[key]  # Expired
        return None

    def set(self, key: str, value: str):
        self.cache[key] = (value, time.time())

# Cache results for 1 hour
cache = TTLCache(ttl_seconds=3600)
```

**Event-Based Invalidation**:
```python
class EventCache:
    def __init__(self):
        self.cache = {}
        self.dependencies = {}  # key: [dependent_keys]

    def invalidate_on_file_change(self, file_path: str):
        # Invalidate all cached results that depend on this file
        if file_path in self.dependencies:
            for dependent_key in self.dependencies[file_path]:
                if dependent_key in self.cache:
                    del self.cache[dependent_key]

# Invalidate when files change
cache.invalidate_on_file_change("auth.py")
```

---

## References

[^1]: Anthropic. "Claude Code Performance Benchmarks." Technical Report, 2025. https://www.anthropic.com/news/claude-code-performance
[^2]: Anthropic. "SWE-bench Verified Results." Benchmark Analysis, 2025. https://www.anthropic.com/news/swe-bench-sonnet
[^3]: Anthropic. "Context Management in Claude Agent SDK." Technical Documentation, 2025. https://docs.anthropic.com/en/docs/claude-code/sdk/context-management
[^4]: Anthropic. "Model Comparison Guide." Pricing and Performance, 2025. https://docs.anthropic.com/en/docs/about-claude/models
[^5]: Anthropic. "API Pricing." Cost Structure, 2025. https://docs.anthropic.com/en/api/pricing
[^6]: DataCamp. "Claude Agent SDK Tutorial." Context Optimization, 2025. https://www.datacamp.com/tutorial/how-to-use-claude-agent-sdk
[^7]: Anthropic. "Token Efficiency Best Practices." Optimization Guide, 2025. https://docs.anthropic.com/en/docs/build-with-claude/optimize-tokens
[^8]: AWS. "Scaling AI Applications." Architecture Patterns, 2025. https://aws.amazon.com/blogs/machine-learning/scaling-ai-applications
[^9]: Anthropic. "Prompt Caching." Cost Reduction Techniques, 2025. https://docs.anthropic.com/en/docs/build-with-claude/prompt-caching

[**→ Complete Bibliography**](references.md)

[← Back to Index](INDEX.md)
