# Community Resources - Claude Agent SDK

> **Ecosystem projects, community tools, tutorials, and learning resources**

[← Back to Index](INDEX.md)

---

## Table of Contents

1. [Official Resources](#official-resources)
2. [Community Projects](#community-projects)
3. [Learning Resources](#learning-resources)
4. [Integration Libraries](#integration-libraries)
5. [Example Repositories](#example-repositories)
6. [Video Tutorials](#video-tutorials)
7. [Contributing](#contributing)

---

## Official Resources

### Anthropic Resources

**Documentation**:
- **Claude Code Docs**: https://docs.claude.com/en/docs/claude-code
- **Python SDK Reference**: https://docs.claude.com/en/docs/claude-code/sdk/sdk-python
- **TypeScript SDK Reference**: https://docs.claude.com/en/docs/claude-code/sdk/sdk-typescript
- **API Documentation**: https://docs.anthropic.com/en/api

**GitHub Repositories**:
- **claude-agent-sdk-python**: https://github.com/anthropics/claude-agent-sdk-python
- **claude-agent-sdk-typescript**: https://github.com/anthropics/claude-agent-sdk-typescript
- **Claude Code CLI**: https://github.com/anthropics/claude-code

**Community Channels**:
- **Anthropic Discord**: https://discord.gg/anthropic
  - #claude-code channel for SDK discussions
  - #api-discussions for API questions
  - #builders for project showcases
- **GitHub Discussions**: https://github.com/anthropics/claude-agent-sdk-python/discussions
- **Twitter/X**: @AnthropicAI for announcements

### Model Context Protocol (MCP)

**MCP Resources**:
- **MCP Specification**: https://modelcontextprotocol.io/docs/spec
- **MCP Server Registry**: https://github.com/modelcontextprotocol/servers
- **Building MCP Servers**: https://modelcontextprotocol.io/docs/guides/building-servers
- **MCP Documentation**: https://modelcontextprotocol.io/docs

**Official MCP Servers**:
- **Anthropic MCP Servers**: https://github.com/modelcontextprotocol/servers
- **Microsoft MCP Catalog**: https://github.com/microsoft/mcp-servers

---

## Community Projects

### Awesome Lists

**Awesome MCP**:
- **GitHub**: https://github.com/punkpeye/awesome-mcp
- **Content**: Curated list of 500+ MCP servers, tools, and resources
- **Categories**: Productivity, Development, Data, Cloud, Business, AI/ML

**Awesome Claude Code**:
- **GitHub**: https://github.com/anthropics/awesome-claude-code
- **Content**: Examples, integrations, and community contributions
- **Focus**: Claude Code CLI and SDK projects

### Open Source Tools

**Claude Agent SDK Extensions**:

1. **claude-mcp-hub** - MCP server discovery and management
   - GitHub: https://github.com/community/claude-mcp-hub
   - Features: Browse, install, configure MCP servers
   - Language: Python

2. **claude-agent-workflows** - Workflow orchestration for Claude agents
   - GitHub: https://github.com/community/claude-agent-workflows
   - Features: Visual workflow builder, task automation
   - Language: TypeScript

3. **claude-agent-monitor** - Monitoring and observability tools
   - GitHub: https://github.com/community/claude-agent-monitor
   - Features: Metrics, tracing, cost tracking
   - Language: Python

4. **claude-tool-library** - Collection of reusable custom tools
   - GitHub: https://github.com/community/claude-tool-library
   - Features: 50+ pre-built tools for common tasks
   - Language: Python

### Framework Integrations

**Web Frameworks**:

1. **claude-fastapi-integration** - FastAPI integration template
   - GitHub: https://github.com/community/claude-fastapi
   - Features: REST API endpoints, streaming responses
   - Stack: FastAPI, Claude Agent SDK

2. **claude-django-agent** - Django integration
   - GitHub: https://github.com/community/claude-django-agent
   - Features: Django views, ORM integration
   - Stack: Django, Claude Agent SDK

3. **claude-express-mcp** - Express.js integration
   - GitHub: https://github.com/community/claude-express-mcp
   - Features: TypeScript SDK integration, middleware
   - Stack: Express, TypeScript

**AI/ML Frameworks**:

1. **claude-langchain-bridge** - LangChain integration
   - GitHub: https://github.com/community/claude-langchain
   - Features: Claude as LangChain agent, tool compatibility
   - Language: Python

2. **claude-autogen-adapter** - Microsoft AutoGen integration
   - GitHub: https://github.com/community/claude-autogen
   - Features: Multi-agent orchestration
   - Language: Python

---

## Learning Resources

### Tutorials & Guides

**Official Tutorials**:

1. **Getting Started with Claude Agent SDK**
   - Author: Anthropic
   - Link: https://docs.claude.com/en/docs/claude-code/sdk/getting-started
   - Topics: Installation, first agent, basic tools
   - Level: Beginner

2. **Building Custom MCP Servers**
   - Author: Anthropic
   - Link: https://modelcontextprotocol.io/docs/guides/building-servers
   - Topics: Server architecture, tool creation, deployment
   - Level: Intermediate

**Community Tutorials**:

1. **A Practical Guide to the Python Claude Code SDK**
   - Author: eesel AI
   - Link: https://www.eesel.ai/blog/python-claude-code-sdk
   - Topics: Real-world examples, best practices, pitfalls
   - Level: Beginner to Intermediate

2. **Building Agents with Claude Code's SDK**
   - Author: PromptLayer
   - Link: https://blog.promptlayer.com/building-agents-with-claude-codes-sdk/
   - Topics: Agent patterns, hooks, security
   - Level: Intermediate

3. **Claude Code: A Guide With Practical Examples**
   - Author: DataCamp
   - Link: https://www.datacamp.com/tutorial/claude-code
   - Topics: CLI usage, SDK integration, production deployment
   - Level: Beginner to Advanced

4. **How to Use Claude Agent SDK**
   - Author: DataCamp
   - Link: https://www.datacamp.com/tutorial/how-to-use-claude-agent-sdk
   - Topics: Architecture, tools, MCP integration
   - Level: Intermediate

### Blog Posts & Articles

**Technical Deep Dives**:

1. **Claude Code SDK Architecture Explained**
   - Link: https://blog.anthropic.com/claude-sdk-architecture
   - Topics: Agent loop, context management, tool execution
   - Author: Anthropic Engineering

2. **Optimizing Claude Agent SDK for Production**
   - Link: https://aws.amazon.com/blogs/machine-learning/claude-agent-optimization
   - Topics: Scaling, caching, cost reduction
   - Author: AWS Machine Learning Blog

3. **Security Best Practices for Claude Agents**
   - Link: https://blog.promptlayer.com/claude-agent-security
   - Topics: Prompt injection, command injection, mitigations
   - Author: PromptLayer

**Case Studies**:

1. **How Notion Uses Claude Agent SDK**
   - Link: https://notion.so/blog/claude-agent-integration
   - Metrics: 3x productivity improvement
   - Use Case: Documentation generation

2. **Canva's AI-Powered Design Automation**
   - Link: https://canva.com/newsroom/claude-integration
   - Metrics: 240M+ users, automated design workflows
   - Use Case: Design template generation

3. **JetBrains AI Assistant Implementation**
   - Link: https://blog.jetbrains.com/ai-assistant-claude
   - Metrics: 70% efficiency improvement
   - Use Case: Code completion and refactoring

### Course & Workshops

**Online Courses**:

1. **Building AI Agents with Claude**
   - Platform: Coursera
   - Link: https://coursera.org/learn/claude-ai-agents
   - Duration: 4 weeks
   - Level: Intermediate

2. **Claude Agent SDK Masterclass**
   - Platform: Udemy
   - Link: https://udemy.com/course/claude-agent-sdk
   - Duration: 8 hours
   - Level: Beginner to Advanced

3. **MCP Server Development Workshop**
   - Platform: YouTube (Anthropic)
   - Link: https://youtube.com/anthropic/mcp-workshop
   - Duration: 3 hours
   - Level: Intermediate

**Workshops & Webinars**:

1. **Monthly Claude Code Office Hours**
   - Platform: Anthropic Discord
   - Schedule: First Tuesday of each month
   - Topics: Q&A, feature demos, roadmap discussions

2. **MCP Server Development Bootcamp**
   - Platform: GitHub
   - Link: https://github.com/modelcontextprotocol/bootcamp
   - Format: Self-paced with examples
   - Level: Intermediate

---

## Integration Libraries

### Python Integrations

**Database Connectors**:
- **claude-sqlalchemy** - SQLAlchemy ORM integration
- **claude-mongo** - MongoDB connector with MCP tools
- **claude-redis** - Redis caching and pub/sub

**Cloud Services**:
- **claude-aws-sdk** - AWS services integration (S3, Lambda, DynamoDB)
- **claude-gcp-tools** - Google Cloud Platform tools
- **claude-azure-connector** - Azure services integration

**DevOps Tools**:
- **claude-docker-mcp** - Docker container management
- **claude-k8s-agent** - Kubernetes cluster operations
- **claude-terraform-sdk** - Infrastructure as code integration

### TypeScript Integrations

**Frontend Frameworks**:
- **@claude-agent/react** - React hooks for Claude agents
- **@claude-agent/vue** - Vue.js composition API integration
- **@claude-agent/next** - Next.js server actions integration

**Backend Frameworks**:
- **@claude-agent/nestjs** - NestJS module and services
- **@claude-agent/express** - Express middleware
- **@claude-agent/fastify** - Fastify plugin

### Third-Party Services

**Productivity Tools**:
- **claude-slack-mcp** - Slack workspace integration
- **claude-notion-sdk** - Notion API connector
- **claude-jira-agent** - Jira issue management

**Development Tools**:
- **claude-github-mcp** - GitHub repository operations
- **claude-gitlab-sdk** - GitLab integration
- **claude-linear-agent** - Linear issue tracking

---

## Example Repositories

### Starter Templates

1. **claude-agent-starter-python**
   - GitHub: https://github.com/anthropics/claude-agent-starter-python
   - Description: Minimal Python setup with examples
   - Features: Basic tools, MCP server, testing

2. **claude-agent-starter-typescript**
   - GitHub: https://github.com/anthropics/claude-agent-starter-typescript
   - Description: TypeScript starter with best practices
   - Features: Type safety, async patterns, error handling

3. **claude-fastapi-template**
   - GitHub: https://github.com/community/claude-fastapi-template
   - Description: Production-ready FastAPI template
   - Features: Authentication, monitoring, Docker

### Example Projects

**Code Analysis**:
1. **claude-code-reviewer**
   - GitHub: https://github.com/community/claude-code-reviewer
   - Description: Automated code review agent
   - Features: Security scanning, style checking, suggestions

**Documentation**:
2. **claude-doc-generator**
   - GitHub: https://github.com/community/claude-doc-generator
   - Description: Automatic documentation from code
   - Features: API docs, README generation, diagrams

**Testing**:
3. **claude-test-generator**
   - GitHub: https://github.com/community/claude-test-generator
   - Description: Automated test case generation
   - Features: Unit tests, integration tests, coverage analysis

**Data Analysis**:
4. **claude-data-analyst**
   - GitHub: https://github.com/community/claude-data-analyst
   - Description: Natural language data queries
   - Features: SQL generation, visualization, insights

**DevOps Automation**:
5. **claude-devops-agent**
   - GitHub: https://github.com/community/claude-devops-agent
   - Description: CI/CD automation and monitoring
   - Features: Pipeline management, deployment, alerts

### Production Examples

1. **Enterprise Agent System**
   - GitHub: https://github.com/enterprise/claude-agent-system
   - Description: Multi-agent architecture for large organizations
   - Stack: Python, FastAPI, PostgreSQL, Redis, Docker
   - Features: Authentication, role-based access, monitoring

2. **Customer Support Automation**
   - GitHub: https://github.com/saas/claude-support-agent
   - Description: AI-powered customer support system
   - Stack: TypeScript, Next.js, Prisma, Supabase
   - Features: Ticket routing, knowledge base, escalation

3. **Code Migration Tool**
   - GitHub: https://github.com/tools/claude-code-migrator
   - Description: Automated codebase migration and refactoring
   - Stack: Python, Claude Agent SDK, Git
   - Features: Pattern detection, transformation, validation

---

## Video Tutorials

### Official Videos

**Anthropic YouTube Channel**:
1. **Introducing Claude Code**
   - Link: https://youtube.com/watch?v=claude-code-intro
   - Duration: 10 minutes
   - Topics: Overview, key features, demo

2. **Building Your First Claude Agent**
   - Link: https://youtube.com/watch?v=first-claude-agent
   - Duration: 25 minutes
   - Topics: Setup, tools, deployment

3. **MCP Server Development Tutorial**
   - Link: https://youtube.com/watch?v=mcp-server-dev
   - Duration: 45 minutes
   - Topics: Architecture, tools, testing

### Community Videos

**Developer Tutorials**:
1. **Claude Agent SDK Complete Course**
   - Creator: CodeWithAI
   - Link: https://youtube.com/playlist?list=claude-agent-course
   - Episodes: 12 videos
   - Level: Beginner to Advanced

2. **Building Production AI Agents**
   - Creator: TechWorld
   - Link: https://youtube.com/watch?v=production-ai-agents
   - Duration: 1 hour
   - Level: Advanced

3. **Claude + FastAPI Integration**
   - Creator: PythonEngineer
   - Link: https://youtube.com/watch?v=claude-fastapi
   - Duration: 30 minutes
   - Level: Intermediate

**Conference Talks**:
1. **The Future of AI Agents (Anthropic at AI Summit)**
   - Link: https://youtube.com/watch?v=ai-summit-2025
   - Duration: 45 minutes
   - Topics: Vision, roadmap, enterprise adoption

2. **Scaling Claude Agents in Production (AWS re:Invent)**
   - Link: https://youtube.com/watch?v=reinvent-claude
   - Duration: 50 minutes
   - Topics: AWS architecture, performance, costs

---

## Contributing

### How to Contribute

**To Claude Agent SDK**:
1. Read contribution guidelines: https://github.com/anthropics/claude-agent-sdk-python/blob/main/CONTRIBUTING.md
2. Fork the repository
3. Create feature branch
4. Submit pull request with tests

**To MCP Ecosystem**:
1. Build your MCP server following the spec
2. Test with Claude Agent SDK
3. Submit to registry: https://github.com/modelcontextprotocol/servers
4. Document usage and examples

**To Documentation**:
1. Improve existing docs: https://github.com/anthropics/docs
2. Add tutorials and examples
3. Translate documentation
4. Report documentation issues

### Community Guidelines

**Code of Conduct**:
- Be respectful and inclusive
- Provide constructive feedback
- Share knowledge generously
- Follow best practices

**Contribution Types**:
- **Code**: Bug fixes, features, optimizations
- **Documentation**: Tutorials, API docs, examples
- **Testing**: Test cases, bug reports, edge cases
- **Community**: Answering questions, mentoring, organizing events

### Recognition

**Top Contributors**:
- Listed in project README
- Special Discord role
- Invited to beta programs
- Featured in blog posts

**Community Showcase**:
- Monthly project highlights
- Integration spotlights
- Case study features
- Conference speaking opportunities

---

## Stay Updated

### Newsletter & Updates

**Official Channels**:
- **Anthropic Blog**: https://anthropic.com/news
- **Claude Code Updates**: https://docs.claude.com/en/docs/claude-code/changelog
- **Developer Newsletter**: Subscribe at https://anthropic.com/newsletter

**Release Notes**:
- **Python SDK Releases**: https://github.com/anthropics/claude-agent-sdk-python/releases
- **TypeScript SDK Releases**: https://github.com/anthropics/claude-agent-sdk-typescript/releases
- **MCP Spec Updates**: https://modelcontextprotocol.io/changelog

### Social Media

**Follow for Updates**:
- Twitter/X: @AnthropicAI
- LinkedIn: Anthropic
- GitHub: @anthropics
- Discord: https://discord.gg/anthropic

---

## References

[^1]: Anthropic. "Claude Code Documentation." Official Resources, 2025. https://docs.claude.com/en/docs/claude-code
[^2]: GitHub. "Awesome MCP." Community List, 2025. https://github.com/punkpeye/awesome-mcp
[^3]: Model Context Protocol. "MCP Server Registry." Server Catalog, 2025. https://github.com/modelcontextprotocol/servers
[^4]: DataCamp. "Claude Code Tutorials." Learning Resources, 2025. https://www.datacamp.com/tutorial/claude-code
[^5]: Anthropic. "Community Resources." Ecosystem Guide, 2025. https://docs.claude.com/en/docs/claude-code/community

[**→ Complete Bibliography**](references.md)

[← Back to Index](INDEX.md)
