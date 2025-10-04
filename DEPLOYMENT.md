# Deployment Guide - Claude Agent SDK Documentation

This guide will help you deploy your documentation to GitHub Pages.

## Prerequisites

- Git installed
- Python 3.11+ installed
- GitHub account
- Repository created on GitHub

## Step-by-Step Deployment

### 1. Prepare Your Repository

```bash
# Navigate to your documentation directory
cd C:\Users\ELI\.claude\claudedocs\claude-agent-sdk-wiki

# Initialize git if not already done
git init

# Add all files
git add .

# Create initial commit
git commit -m "feat: Initial Claude Agent SDK documentation setup"
```

### 2. Connect to GitHub

```bash
# Add your GitHub repository as remote (replace with your username/repo)
git remote add origin https://github.com/yourusername/claude-agent-sdk-wiki.git

# Push to GitHub
git branch -M main
git push -u origin main
```

### 3. Enable GitHub Pages

1. Go to your repository on GitHub
2. Click **Settings** → **Pages**
3. Under **Source**, select **GitHub Actions**
4. The workflow will automatically deploy when you push changes

### 4. Configure Your Site

Edit `mkdocs.yml` and update these lines with your information:

```yaml
site_url: https://yourusername.github.io/claude-agent-sdk-wiki/
repo_name: yourusername/claude-agent-sdk-wiki
repo_url: https://github.com/yourusername/claude-agent-sdk-wiki
```

Commit and push changes:

```bash
git add mkdocs.yml
git commit -m "chore: Update site configuration"
git push
```

### 5. Wait for Deployment

1. Go to **Actions** tab in your GitHub repository
2. Watch the "Deploy Documentation" workflow run
3. Once complete (green checkmark), your site is live!

### 6. Access Your Documentation

Your documentation will be available at:
```
https://yourusername.github.io/claude-agent-sdk-wiki/
```

## Local Development

### Install Dependencies

```bash
pip install -r requirements.txt
```

### Preview Locally

```bash
mkdocs serve
```

Then open http://localhost:8000 in your browser.

### Build Static Site

```bash
mkdocs build
```

This creates a `site/` directory with the static HTML files.

## Manual Deployment (Alternative)

If you prefer manual deployment instead of GitHub Actions:

```bash
# Build and deploy in one command
mkdocs gh-deploy --force
```

This will:
1. Build the documentation
2. Push to `gh-pages` branch
3. Make it available on GitHub Pages

## Customization

### Change Colors

Edit `mkdocs.yml`:

```yaml
theme:
  palette:
    - scheme: default
      primary: indigo      # Your primary color
      accent: pink        # Your accent color
```

### Add Logo

1. Place your logo at `docs/assets/logo.png`
2. Update `mkdocs.yml`:

```yaml
theme:
  logo: assets/logo.png
  favicon: assets/favicon.png
```

### Add Google Analytics

In `mkdocs.yml`:

```yaml
extra:
  analytics:
    provider: google
    property: G-XXXXXXXXXX  # Your GA4 measurement ID
```

## Troubleshooting

### Build Fails in GitHub Actions

**Error: Python version too old**
- The workflow requires Python 3.11+
- Check `.github/workflows/docs.yml` and ensure it's set to `python-version: '3.11'`

**Error: Module not found**
- Ensure all dependencies are in `requirements.txt`
- Run `pip freeze > requirements.txt` to capture all dependencies

**Error: Permission denied**
- Go to Settings → Actions → General
- Under "Workflow permissions", select "Read and write permissions"
- Save changes and re-run the workflow

### Site Not Updating

1. Check the Actions tab for failed workflows
2. Clear browser cache (Ctrl+F5)
3. Wait a few minutes (GitHub Pages can take 1-2 minutes to update)

### Links Not Working

- Ensure all internal links use relative paths
- MkDocs automatically handles `.md` → `.html` conversion
- Links should be: `[Text](page.md)` not `[Text](page.html)`

### Search Not Working

- Search requires the site to be fully built
- Run `mkdocs build` and check for errors
- Ensure `search` plugin is in `mkdocs.yml`

## Continuous Deployment

Every time you push to the `main` branch:

1. GitHub Actions automatically runs
2. Builds the documentation
3. Deploys to GitHub Pages
4. Your site updates within 1-2 minutes

To deploy:

```bash
# Make changes to markdown files in docs/
# Commit and push
git add .
git commit -m "docs: Update documentation"
git push
```

## Advanced Configuration

### Custom Domain

1. Add a `CNAME` file in `docs/`:
   ```
   docs.yourdomain.com
   ```

2. Configure DNS with your domain provider:
   ```
   Type: CNAME
   Name: docs (or your subdomain)
   Value: yourusername.github.io
   ```

3. In GitHub Settings → Pages:
   - Add your custom domain
   - Enable "Enforce HTTPS"

### Multiple Versions

Use `mike` for version management:

```bash
# Install mike
pip install mike

# Deploy version
mike deploy 1.0 latest
mike set-default latest

# Push to GitHub
git push
```

## Getting Help

- **MkDocs Docs**: https://www.mkdocs.org
- **Material Theme**: https://squidfunk.github.io/mkdocs-material/
- **GitHub Pages**: https://docs.github.com/en/pages
- **Issues**: Create an issue in your repository

---

**Ready to deploy?** Follow the steps above and your documentation will be live in minutes!
