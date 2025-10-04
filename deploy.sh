#!/bin/bash
# Bash Deployment Script for Claude Agent SDK Documentation
# Repository: https://github.com/Nucs/claude-code-python-sdk-unofficial-docs

echo "🚀 Deploying Claude Agent SDK Documentation"
echo "================================================"
echo ""

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "❌ Git is not installed. Please install Git first."
    exit 1
fi

# Navigate to project directory
PROJECT_DIR="/c/Users/ELI/.claude/claudedocs/claude-agent-sdk-wiki"
cd "$PROJECT_DIR" || exit 1

echo "📁 Current directory: $PROJECT_DIR"
echo ""

# Check if this is already a git repository
if [ -d ".git" ]; then
    echo "✅ Git repository already initialized"
else
    echo "📦 Initializing Git repository..."
    git init
    echo "✅ Git repository initialized"
fi

echo ""

# Add all files
echo "📝 Staging all files..."
git add .

# Create commit
echo "💾 Creating commit..."
git commit -m "feat: Initial Claude Agent SDK documentation setup

- Added comprehensive documentation with 127 verified sources
- Included 28 real-world case studies
- Set up MkDocs with Material theme
- Configured GitHub Actions for auto-deployment
- Added custom styling and JavaScript enhancements"

echo "✅ Commit created"
echo ""

# Check if remote already exists
if git remote | grep -q "origin"; then
    echo "✅ Remote 'origin' already configured"
else
    echo "🔗 Adding GitHub remote..."
    git remote add origin https://github.com/Nucs/claude-code-python-sdk-unofficial-docs.git
    echo "✅ Remote added"
fi

echo ""

# Set main branch
echo "🌿 Setting main branch..."
git branch -M main

echo ""
echo "🚀 Pushing to GitHub..."
echo "⚠️  You will be prompted for GitHub credentials"
echo ""

# Push to GitHub
if git push -u origin main; then
    echo ""
    echo "✅ Successfully pushed to GitHub!"
    echo ""
    echo "================================================"
    echo "🎉 DEPLOYMENT COMPLETE!"
    echo "================================================"
    echo ""
    echo "📚 Next Steps:"
    echo ""
    echo "1. Enable GitHub Pages:"
    echo "   - Go to: https://github.com/Nucs/claude-code-python-sdk-unofficial-docs/settings/pages"
    echo "   - Under 'Source', select: 'GitHub Actions'"
    echo ""
    echo "2. Wait for deployment (1-2 minutes)"
    echo "   - Check progress: https://github.com/Nucs/claude-code-python-sdk-unofficial-docs/actions"
    echo ""
    echo "3. Your documentation will be live at:"
    echo "   🌐 https://Nucs.github.io/claude-code-python-sdk-unofficial-docs/"
    echo ""
else
    echo ""
    echo "❌ Push failed. Please check your GitHub credentials."
    echo ""
    echo "💡 Tips:"
    echo "- Make sure you have access to the repository"
    echo "- You may need to use a Personal Access Token instead of password"
    echo "- Create a token at: https://github.com/settings/tokens"
    echo ""
    exit 1
fi
