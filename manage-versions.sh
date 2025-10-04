#!/bin/bash
# Version Management Script using mike

echo "📚 Claude Agent SDK Documentation - Version Manager"
echo "===================================================="
echo ""

# Navigate to project directory
PROJECT_DIR="/c/Users/ELI/.claude/claudedocs/claude-agent-sdk-wiki"
cd "$PROJECT_DIR" || exit 1

# Activate conda environment
source /c/Users/ELI/anaconda3/etc/profile.d/conda.sh
conda activate mcp-claude

# Install mike if not installed
if ! command -v mike &> /dev/null; then
    echo "📦 Installing mike for version management..."
    pip install -q mike
fi

# Function to display usage
usage() {
    echo "Usage: $0 <command> [version] [alias]"
    echo ""
    echo "Commands:"
    echo "  deploy <version> [alias]  - Deploy a new version"
    echo "  list                      - List all versions"
    echo "  set-default <version>     - Set default version"
    echo "  delete <version>          - Delete a version"
    echo "  serve                     - Preview all versions locally"
    echo ""
    echo "Examples:"
    echo "  $0 deploy 1.0 latest      - Deploy version 1.0 as 'latest'"
    echo "  $0 deploy 2.0             - Deploy version 2.0"
    echo "  $0 set-default latest     - Set 'latest' as default"
    echo "  $0 list                   - Show all versions"
    echo ""
}

# Get command
COMMAND=$1

case "$COMMAND" in
    deploy)
        VERSION=$2
        ALIAS=$3

        if [ -z "$VERSION" ]; then
            echo "❌ Error: Version required"
            usage
            exit 1
        fi

        if [ ! -z "$ALIAS" ]; then
            echo "🚀 Deploying version $VERSION with alias '$ALIAS'..."
            mike deploy --push --update-aliases $VERSION $ALIAS
        else
            echo "🚀 Deploying version $VERSION..."
            mike deploy --push $VERSION
        fi

        echo ""
        echo "✅ Version $VERSION deployed!"
        echo ""
        echo "📍 Access at: https://Nucs.github.io/claude-code-python-sdk-unofficial-docs/$VERSION/"
        ;;

    list)
        echo "📋 Available versions:"
        echo ""
        mike list
        echo ""
        ;;

    set-default)
        VERSION=$2

        if [ -z "$VERSION" ]; then
            echo "❌ Error: Version required"
            usage
            exit 1
        fi

        echo "🔄 Setting $VERSION as default..."
        mike set-default --push $VERSION

        echo ""
        echo "✅ Default version set to $VERSION"
        ;;

    delete)
        VERSION=$2

        if [ -z "$VERSION" ]; then
            echo "❌ Error: Version required"
            usage
            exit 1
        fi

        echo "🗑️  Deleting version $VERSION..."
        mike delete --push $VERSION

        echo ""
        echo "✅ Version $VERSION deleted"
        ;;

    serve)
        echo "🌐 Starting version preview server..."
        echo ""
        echo "📍 Open: http://localhost:8000"
        echo "   (Use version selector in top bar)"
        echo ""
        mike serve
        ;;

    *)
        echo "❌ Unknown command: $COMMAND"
        echo ""
        usage
        exit 1
        ;;
esac
