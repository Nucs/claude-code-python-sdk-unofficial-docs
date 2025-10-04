# 🚀 Advanced Features Guide

Your documentation now includes advanced features for professional documentation management!

## ✨ What's New

### 1. 📄 PDF Export (NEW!)

**Automatically generate downloadable PDF** of entire documentation.

**Features:**
- ✅ Complete documentation in single PDF
- ✅ Professional formatting with cover page
- ✅ Table of contents with page numbers
- ✅ Syntax-highlighted code blocks
- ✅ Clickable internal links
- ✅ 127 sources, 28 case studies included

**Generate PDF:**
```bash
# Run PDF generation script
./build-pdf.sh

# Or manually with environment variable
export ENABLE_PDF_EXPORT=1
mkdocs build
```

**Download Location:**
- Live site: `https://Nucs.github.io/claude-code-python-sdk-unofficial-docs/pdf/claude-agent-sdk-documentation.pdf`
- Local: `./claude-agent-sdk-docs.pdf`

---

### 2. 📚 GitHub Wiki Auto-Sync (NEW!)

**Automatically sync documentation to GitHub Wiki** for easy community editing.

**How it works:**
- ✅ Every push to `main` triggers wiki sync
- ✅ All markdown files from `docs/` copied to wiki
- ✅ Automatic sidebar navigation created
- ✅ Footer with last update time added

**Access Your Wiki:**
- URL: `https://github.com/Nucs/claude-code-python-sdk-unofficial-docs/wiki`

**Benefits:**
- 🌐 GitHub Pages: Beautiful, searchable main docs
- ✏️ GitHub Wiki: Easy browser-based editing for contributors
- 🔄 Always in sync automatically

**Manual trigger:**
```bash
# Go to GitHub Actions → Sync to GitHub Wiki → Run workflow
```

---

### 3. 📦 Version Management (NEW!)

**Manage multiple documentation versions** with mike.

**Commands:**

```bash
# Deploy version 1.0 as 'latest'
./manage-versions.sh deploy 1.0 latest

# Deploy version 2.0
./manage-versions.sh deploy 2.0

# List all versions
./manage-versions.sh list

# Set default version
./manage-versions.sh set-default latest

# Delete version
./manage-versions.sh delete 1.0

# Preview all versions locally
./manage-versions.sh serve
```

**Version URLs:**
- Latest: `https://Nucs.github.io/claude-code-python-sdk-unofficial-docs/latest/`
- Version 1.0: `https://Nucs.github.io/claude-code-python-sdk-unofficial-docs/1.0/`

**Use Cases:**
- 📌 Maintain docs for older SDK versions
- 🚀 Beta/RC documentation
- 📚 Historical reference

---

### 4. 📊 Git Revision Info (NEW!)

**Automatic timestamps and contributor attribution.**

**Features:**
- ✅ "Last updated: X days ago" on every page
- ✅ "Created: date" for new pages
- ✅ Show contributors with line counts
- ✅ Contribution statistics

**Visible at:**
- Bottom of each page
- Contributor list in footer

---

### 5. 🔍 Enhanced Search (NEW!)

**Improved search with:**
- ✅ Better tokenization
- ✅ Fuzzy matching
- ✅ Result highlighting
- ✅ Search suggestions
- ✅ Multi-language support

**Try searching for:**
- Partial words: "auth" finds "authentication"
- Code snippets: "ClaudeSDKClient"
- Metrics: "79% faster"

---

### 6. 📈 Analytics Ready (OPTIONAL)

**Google Analytics 4 integration** - just uncomment in `mkdocs.yml`:

```yaml
extra:
  analytics:
    provider: google
    property: G-XXXXXXXXXX  # Your GA4 ID
    feedback:
      title: Was this page helpful?
      ratings:
        - icon: material/emoticon-happy-outline
          name: This page was helpful
```

**Track:**
- 📊 Page views
- 🔍 Search queries
- 📥 PDF downloads
- 👍 User feedback

---

### 7. 🔄 Auto-Redirects (NEW!)

**Automatic URL redirection** for renamed pages.

**Configured in `mkdocs.yml`:**
```yaml
plugins:
  - redirects:
      redirect_maps:
        'old-page.md': 'new-page.md'
```

**Prevents:**
- ❌ Broken links
- ❌ 404 errors
- ❌ Lost SEO rankings

---

### 8. 🎨 Dynamic Variables (NEW!)

**Use variables in markdown** with macros:

```markdown
Total verified sources: {{ vars.total_sources }}
Enterprise users: {{ vars.enterprise_users }}
```

**Available variables:**
- `total_sources` = 127
- `total_case_studies` = 28
- `total_examples` = 10
- `github_stars` = "1.6k+"
- `enterprise_users` = "57,000+"

---

## 🚀 Quick Start

### First-Time Setup

1. **Deploy to GitHub** (if not done):
   ```bash
   ./deploy.ps1  # or ./deploy.sh
   ```

2. **Enable GitHub Pages**:
   - Settings → Pages → Source: GitHub Actions

3. **Enable Wiki**:
   - Settings → Check ✅ "Wikis"

4. **Wait for workflows** (~2-3 minutes):
   - Docs deployment
   - Wiki sync
   - PDF generation

### Daily Usage

**Update documentation:**
```bash
# Edit markdown in docs/
# Commit and push
git add docs/
git commit -m "docs: Update content"
git push
```

**Automatic magic happens:**
- ✅ Site rebuilds
- ✅ Wiki syncs
- ✅ PDF regenerates
- ✅ Version updated

**Generate PDF locally:**
```bash
./build-pdf.sh
```

**Create new version:**
```bash
./manage-versions.sh deploy 2.0 latest
```

---

## 📁 File Structure

```
claude-agent-sdk-wiki/
├── .github/workflows/
│   ├── docs.yml              # Basic deployment
│   ├── docs-with-pdf.yml     # Deployment with PDF ⭐
│   └── wiki-sync.yml         # Auto wiki sync ⭐
│
├── docs/                     # Documentation content
│   └── *.md                  # Your markdown files
│
├── pdf/                      # Generated PDFs ⭐
│   └── claude-agent-sdk-documentation.pdf
│
├── build-pdf.sh             # PDF generation script ⭐
├── manage-versions.sh       # Version management ⭐
├── deploy.ps1               # Windows deployment
├── deploy.sh                # Unix deployment
│
├── mkdocs.yml               # Configuration with advanced plugins ⭐
└── requirements.txt         # All dependencies including PDF tools ⭐
```

---

## 🔧 Configuration

### Enable/Disable Features

**PDF Export:**
```yaml
# In mkdocs.yml
plugins:
  - pdf-export:
      enabled_if_env: ENABLE_PDF_EXPORT  # Set env var to enable
```

**Wiki Sync:**
```yaml
# In .github/workflows/wiki-sync.yml
on:
  push:
    paths:
      - 'docs/**'  # Only sync when docs change
```

**Version Management:**
```yaml
# In mkdocs.yml
extra:
  version:
    provider: mike
    default: latest  # Set default version
```

---

## 📊 Comparison: Before vs After

| Feature | Before | After |
|---------|--------|-------|
| **Deployment** | Manual | ✅ Auto |
| **Wiki** | Separate | ✅ Auto-synced |
| **PDF** | None | ✅ Auto-generated |
| **Versions** | Single | ✅ Multi-version |
| **Git Info** | None | ✅ Timestamps + authors |
| **Search** | Basic | ✅ Enhanced |
| **Analytics** | None | ✅ Ready |
| **Redirects** | Manual | ✅ Automatic |

---

## 🎯 URLs Reference

### Main Documentation
- **Live Site**: https://Nucs.github.io/claude-code-python-sdk-unofficial-docs/
- **Latest Version**: https://Nucs.github.io/claude-code-python-sdk-unofficial-docs/latest/

### Downloads
- **PDF**: https://Nucs.github.io/claude-code-python-sdk-unofficial-docs/pdf/claude-agent-sdk-documentation.pdf

### Community
- **GitHub Wiki**: https://github.com/Nucs/claude-code-python-sdk-unofficial-docs/wiki
- **Repository**: https://github.com/Nucs/claude-code-python-sdk-unofficial-docs

### Workflows
- **Actions**: https://github.com/Nucs/claude-code-python-sdk-unofficial-docs/actions
- **Settings**: https://github.com/Nucs/claude-code-python-sdk-unofficial-docs/settings

---

## 🆘 Troubleshooting

### PDF Not Generating

```bash
# Install PDF dependencies
pip install mkdocs-pdf-export-plugin mkdocs-with-pdf weasyprint Pillow

# Enable and build
export ENABLE_PDF_EXPORT=1
mkdocs build
```

### Wiki Not Syncing

1. Check GitHub Actions workflow ran
2. Verify wiki is enabled in Settings
3. Check workflow permissions (read/write)

### Version Not Working

```bash
# Install mike
pip install mike

# Deploy with proper syntax
mike deploy --push 1.0 latest
mike set-default --push latest
```

---

## 💡 Best Practices

### PDF Generation
- ✅ Generate PDF before major releases
- ✅ Keep PDF in git for offline access
- ✅ Link to PDF from main docs

### Versioning
- ✅ Use semantic versioning (1.0, 2.0, etc.)
- ✅ Always have a 'latest' alias
- ✅ Set 'latest' as default

### Wiki Usage
- ✅ Use for quick community edits
- ✅ Main docs are source of truth
- ✅ Wiki auto-syncs, don't edit directly

### Analytics
- ✅ Add GA4 for usage insights
- ✅ Enable user feedback
- ✅ Track PDF downloads

---

## 🎉 What's Next?

**Already implemented:**
- ✅ GitHub Wiki auto-sync
- ✅ PDF export
- ✅ Version management
- ✅ Git revision dates
- ✅ Enhanced search
- ✅ Auto-redirects
- ✅ Dynamic variables

**Optional additions:**
- 🔄 Custom domain (docs.yoursite.com)
- 🌍 Multi-language support (i18n)
- 🔌 API documentation integration
- 📱 Progressive Web App (PWA)
- 🎨 Custom branding/themes

---

**🚀 Your documentation is now enterprise-grade!**

Run `./deploy.ps1` to deploy everything, including all advanced features!
