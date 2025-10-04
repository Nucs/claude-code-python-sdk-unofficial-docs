# PowerShell Deployment Script for Claude Agent SDK Documentation
# Repository: https://github.com/Nucs/claude-code-python-sdk-unofficial-docs

Write-Host "🚀 Deploying Claude Agent SDK Documentation" -ForegroundColor Cyan
Write-Host "================================================" -ForegroundColor Cyan
Write-Host ""

# Check if git is installed
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Git is not installed. Please install Git first." -ForegroundColor Red
    exit 1
}

# Navigate to project directory
$projectDir = "C:\Users\ELI\.claude\claudedocs\claude-agent-sdk-wiki"
Set-Location $projectDir

Write-Host "📁 Current directory: $projectDir" -ForegroundColor Green
Write-Host ""

# Check if this is already a git repository
if (Test-Path ".git") {
    Write-Host "✅ Git repository already initialized" -ForegroundColor Green
} else {
    Write-Host "📦 Initializing Git repository..." -ForegroundColor Yellow
    git init
    Write-Host "✅ Git repository initialized" -ForegroundColor Green
}

Write-Host ""

# Add all files
Write-Host "📝 Staging all files..." -ForegroundColor Yellow
git add .

# Create commit
Write-Host "💾 Creating commit..." -ForegroundColor Yellow
git commit -m "feat: Initial Claude Agent SDK documentation setup

- Added comprehensive documentation with 127 verified sources
- Included 28 real-world case studies
- Set up MkDocs with Material theme
- Configured GitHub Actions for auto-deployment
- Added custom styling and JavaScript enhancements"

Write-Host "✅ Commit created" -ForegroundColor Green
Write-Host ""

# Check if remote already exists
$remoteExists = git remote | Select-String "origin"

if ($remoteExists) {
    Write-Host "✅ Remote 'origin' already configured" -ForegroundColor Green
} else {
    Write-Host "🔗 Adding GitHub remote..." -ForegroundColor Yellow
    git remote add origin https://github.com/Nucs/claude-code-python-sdk-unofficial-docs.git
    Write-Host "✅ Remote added" -ForegroundColor Green
}

Write-Host ""

# Set main branch
Write-Host "🌿 Setting main branch..." -ForegroundColor Yellow
git branch -M main

Write-Host ""
Write-Host "🚀 Pushing to GitHub..." -ForegroundColor Yellow
Write-Host "⚠️  You will be prompted for GitHub credentials" -ForegroundColor Cyan
Write-Host ""

# Push to GitHub
git push -u origin main

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "✅ Successfully pushed to GitHub!" -ForegroundColor Green
    Write-Host ""
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host "🎉 DEPLOYMENT COMPLETE!" -ForegroundColor Green
    Write-Host "================================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📚 Next Steps:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "1. Enable GitHub Pages:" -ForegroundColor White
    Write-Host "   - Go to: https://github.com/Nucs/claude-code-python-sdk-unofficial-docs/settings/pages" -ForegroundColor Cyan
    Write-Host "   - Under 'Source', select: 'GitHub Actions'" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "2. Wait for deployment (1-2 minutes)" -ForegroundColor White
    Write-Host "   - Check progress: https://github.com/Nucs/claude-code-python-sdk-unofficial-docs/actions" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "3. Your documentation will be live at:" -ForegroundColor White
    Write-Host "   🌐 https://Nucs.github.io/claude-code-python-sdk-unofficial-docs/" -ForegroundColor Green
    Write-Host ""
} else {
    Write-Host ""
    Write-Host "❌ Push failed. Please check your GitHub credentials." -ForegroundColor Red
    Write-Host ""
    Write-Host "💡 Tips:" -ForegroundColor Yellow
    Write-Host "- Make sure you have access to the repository" -ForegroundColor White
    Write-Host "- You may need to use a Personal Access Token instead of password" -ForegroundColor White
    Write-Host "- Create a token at: https://github.com/settings/tokens" -ForegroundColor Cyan
    Write-Host ""
}
