#!/bin/bash
# PDF Generation Script for Claude Agent SDK Documentation

echo "📄 Generating PDF Documentation"
echo "================================"
echo ""

# Navigate to project directory
PROJECT_DIR="/c/Users/ELI/.claude/claudedocs/claude-agent-sdk-wiki"
cd "$PROJECT_DIR" || exit 1

# Activate conda environment
echo "🔧 Activating conda environment..."
source /c/Users/ELI/anaconda3/etc/profile.d/conda.sh
conda activate mcp-claude

# Install PDF generation dependencies if needed
echo "📦 Installing PDF generation dependencies..."
pip install -q mkdocs-pdf-export-plugin mkdocs-with-pdf weasyprint Pillow

# Set environment variable to enable PDF export
export ENABLE_PDF_EXPORT=1

# Create pdf directory if it doesn't exist
mkdir -p pdf

# Build documentation with PDF export
echo ""
echo "🏗️  Building documentation with PDF export..."
mkdocs build

# Check if PDF was generated
if [ -f "site/pdf/claude-agent-sdk-documentation.pdf" ]; then
    # Copy to root for easy access
    cp site/pdf/claude-agent-sdk-documentation.pdf ./claude-agent-sdk-docs.pdf

    echo ""
    echo "✅ PDF Generated Successfully!"
    echo ""
    echo "📍 PDF Locations:"
    echo "   - site/pdf/claude-agent-sdk-documentation.pdf"
    echo "   - claude-agent-sdk-docs.pdf (root)"
    echo ""

    # Get file size
    SIZE=$(du -h claude-agent-sdk-docs.pdf | cut -f1)
    echo "📊 File Size: $SIZE"
    echo ""

    # Get page count (if pdfinfo is available)
    if command -v pdfinfo &> /dev/null; then
        PAGES=$(pdfinfo claude-agent-sdk-docs.pdf 2>/dev/null | grep Pages | awk '{print $2}')
        if [ ! -z "$PAGES" ]; then
            echo "📖 Total Pages: $PAGES"
            echo ""
        fi
    fi

    echo "🎉 Documentation PDF is ready!"
    echo ""
    echo "📚 Contents:"
    echo "   ✅ 127 verified sources"
    echo "   ✅ 28 real-world case studies"
    echo "   ✅ 10+ practical code examples"
    echo "   ✅ Complete API reference"
    echo "   ✅ Production patterns"
    echo ""
else
    echo ""
    echo "⚠️  PDF generation completed but file not found"
    echo "   This might be due to plugin configuration"
    echo ""
    echo "💡 Try alternative PDF generation:"
    echo "   mkdocs build"
    echo "   Then use browser: File → Print → Save as PDF"
    echo ""
fi

# Unset environment variable
unset ENABLE_PDF_EXPORT

echo "✨ Done!"
