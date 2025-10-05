# Claude Agent SDK Documentation

> **Comprehensive guide to building AI agents with Claude Agent SDK**

[![Deploy Documentation](https://github.com/Nucs/claude-code-python-sdk-unofficial-docs/actions/workflows/docs.yml/badge.svg)](https://github.com/Nucs/claude-code-python-sdk-unofficial-docs/actions/workflows/docs.yml)
[![Documentation](https://img.shields.io/badge/docs-live-success)](https://Nucs.github.io/claude-code-python-sdk-unofficial-docs/)
[![MkDocs](https://img.shields.io/badge/built%20with-MkDocs%20Material-blue)](https://squidfunk.github.io/mkdocs-material/)

## 📚 About

This is a comprehensive, community-driven documentation for the Claude Agent SDK (formerly Claude Code SDK). It includes:

- **127 verified sources** from official docs, research papers, and community projects
- **28 real-world case studies** with metrics and implementation details
- **10+ practical code examples** from basic to advanced usage
- **Complete API reference** for Python and TypeScript SDKs
- **Production patterns** for enterprise deployment
- **Security best practices** and optimization guides

## 🚀 Quick Start

### View Documentation Online

Visit the live documentation: **[https://Nucs.github.io/claude-code-python-sdk-unofficial-docs/](https://Nucs.github.io/claude-code-python-sdk-unofficial-docs/)**

### Run Locally

1. **Clone the repository**
   ```bash
   git clone https://github.com/Nucs/claude-code-python-sdk-unofficial-docs.git
   cd claude-code-python-sdk-unofficial-docs
   ```

2. **Install dependencies**
   ```bash
   pip install -r requirements.txt
   ```

3. **Serve locally**
   ```bash
   mkdocs serve
   ```

4. **Open in browser**
   Navigate to `http://localhost:8000`

## 📖 Documentation Structure

```
docs/
├── index.md                    # Home page
├── overview.md                 # SDK overview
├── getting-started.md          # Quick start guide
├── architecture.md             # Agent loop & internals
├── api-reference.md           # Complete API docs
├── tools-and-mcp.md           # Custom tools & MCP
├── real-world-use-cases.md    # 28 case studies
├── production-patterns.md      # Enterprise deployment
├── security.md                # Security best practices
├── performance-optimization.md # Performance tuning
├── troubleshooting.md         # Common issues & fixes
├── community-resources.md      # Community & learning
└── references.md              # 127 verified sources
```

## 🌐 Deploy to GitHub Pages

### Option 1: Automatic Deployment (Recommended)

1. **Push to GitHub**
   ```bash
   git add .
   git commit -m "Initial documentation setup"
   git push origin main
   ```

2. **Enable GitHub Pages**
   - Go to repository **Settings** → **Pages**
   - Source: **GitHub Actions**
   - Wait for deployment workflow to complete

3. **Access your site**
   - URL: `https://Nucs.github.io/claude-code-python-sdk-unofficial-docs/`

### Option 2: Manual Deployment

```bash
# Build the documentation
mkdocs build

# Deploy to GitHub Pages
mkdocs gh-deploy --force
```

## 🛠️ Configuration

### Update Repository Information

Edit `mkdocs.yml`:

```yaml
# Update these values
site_url: https://Nucs.github.io/claude-code-python-sdk-unofficial-docs/
repo_name: Nucs/claude-code-python-sdk-unofficial-docs
repo_url: https://github.com/Nucs/claude-code-python-sdk-unofficial-docs
```

### Customize Theme

**Colors** - Edit in `mkdocs.yml`:
```yaml
theme:
  palette:
    - scheme: default
      primary: deep purple  # Change this
      accent: amber        # Change this
```

**Logo** - Add your logo:
1. Place logo in `docs/assets/logo.png`
2. Update `mkdocs.yml`:
   ```yaml
   theme:
     logo: assets/logo.png
   ```

### Add Google Analytics (Optional)

In `mkdocs.yml`:
```yaml
extra:
  analytics:
    provider: google
    property: G-XXXXXXXXXX  # Your GA4 ID
```

## 📝 Content Updates

### Edit Documentation

1. Edit markdown files in `docs/` directory
2. Preview changes: `mkdocs serve`
3. Commit and push to trigger auto-deployment

### Add New Pages

1. Create new `.md` file in `docs/`
2. Add to navigation in `mkdocs.yml`:
   ```yaml
   nav:
     - New Section:
       - New Page: new-page.md
   ```

### Update Styling

- **CSS**: Edit `docs/stylesheets/extra.css`
- **JavaScript**: Edit `docs/javascripts/extra.js`

## 🎨 Features

- **🎯 Material Design** - Modern, responsive theme
- **🔍 Full-text Search** - Instant search with suggestions
- **🌓 Dark Mode** - Automatic theme switching
- **📱 Mobile-Friendly** - Optimized for all devices
- **💻 Code Highlighting** - Syntax highlighting for 100+ languages
- **📊 Tables & Diagrams** - Enhanced tables with Mermaid support
- **🔗 Auto-linking** - Smart cross-references
- **📋 Copy Buttons** - One-click code copying
- **⚡ Fast Loading** - Optimized assets with minification
- **🏷️ NEW Badges** - Automatic highlighting of new content

## 🤝 Contributing

Contributions are welcome! Here's how:

1. **Fork the repository**
2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature
   ```
3. **Make your changes**
4. **Test locally**
   ```bash
   mkdocs serve
   ```
5. **Submit a pull request**

### Content Guidelines

- Use clear, concise language
- Include code examples where appropriate
- Add citations for external sources
- Follow existing markdown structure
- Test all links and code snippets

## 📊 Statistics

- **Total Sources**: 127 verified references
- **Case Studies**: 28 real-world implementations
- **Code Examples**: 10+ practical examples
- **Performance Metrics**: 50+ verified benchmarks
- **GitHub Stars**: 1.6k+ (VoltAgent subagents)
- **Enterprise Users**: 57,000+ (TELUS deployment)

## 🔧 Troubleshooting

### Build Fails

```bash
# Clear cache and rebuild
mkdocs build --clean
```

### Missing Dependencies

```bash
# Reinstall all dependencies
pip install --force-reinstall -r requirements.txt
```

### GitHub Actions Failing

1. Check Python version (needs 3.11+)
2. Verify `requirements.txt` is complete
3. Check workflow permissions in repo settings

## 📚 Resources

- **Claude Agent SDK Python**: https://github.com/anthropics/claude-agent-sdk-python
- **Claude Agent SDK TypeScript**: https://github.com/anthropics/claude-agent-sdk-typescript
- **MkDocs Documentation**: https://www.mkdocs.org
- **Material Theme**: https://squidfunk.github.io/mkdocs-material/

## 📄 License

This documentation is community-maintained and follows the licensing of the Claude Agent SDK.

## 🙏 Acknowledgments

- **Anthropic** - For the Claude Agent SDK
- **Community Contributors** - For real-world examples and case studies
- **MkDocs Material** - For the excellent documentation framework

## 📮 Support

- **Issues**: [GitHub Issues](https://github.com/Nucs/claude-code-python-sdk-unofficial-docs/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Nucs/claude-code-python-sdk-unofficial-docs/discussions)
- **Discord**: [Anthropic Discord](https://discord.gg/anthropic)

---

**Built with ❤️ by the Claude Agent SDK Community**
