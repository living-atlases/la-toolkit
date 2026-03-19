#!/bin/bash
# Update Knowledge Base from KB VM
# Usage: ./scripts/update-kb.sh [target-user@target-host]
# Example: ./scripts/update-kb.sh ubuntu@la-toolkit-kb-dev-2026

set -e

# Default values
KB_USER_HOST="${1:-ubuntu@la-toolkit-kb-dev-2026}"
KB_REMOTE_PATH="/opt/la-toolkit-kb/data/chromadb/"
KB_LOCAL_PATH="/data/la-toolkit/kb-data"

echo "🔄 Updating Knowledge Base from $KB_USER_HOST..."
echo "   Remote path: $KB_REMOTE_PATH"
echo "   Local path: $KB_LOCAL_PATH"

# Ensure local directory exists
mkdir -p "$KB_LOCAL_PATH"

# Create backup before sync
BACKUP_PATH="$KB_LOCAL_PATH.backup.$(date +%Y%m%d_%H%M%S)"
if [ -d "$KB_LOCAL_PATH" ] && [ "$(ls -A "$KB_LOCAL_PATH")" ]; then
    echo "📦 Creating backup: $BACKUP_PATH"
    cp -r "$KB_LOCAL_PATH" "$BACKUP_PATH"
fi

# Sync KB data
echo "📡 Starting rsync..."
rsync -avz --delete \
    "$KB_USER_HOST:$KB_REMOTE_PATH" \
    "$KB_LOCAL_PATH/"

echo "✅ Knowledge Base updated successfully!"
echo ""
echo "📊 KB Statistics:"
du -sh "$KB_LOCAL_PATH"

# Verify ChromaDB structure
if [ -f "$KB_LOCAL_PATH/chroma.sqlite3" ]; then
    echo "✓ ChromaDB database found"
    ls -1d "$KB_LOCAL_PATH"/*/ 2>/dev/null | wc -l | xargs echo "✓ Collections:"
else
    echo "❌ Warning: chroma.sqlite3 not found!"
    exit 1
fi

echo ""
echo "📝 Next steps:"
echo "   1. Restart la-toolkit: docker restart la-toolkit"
echo "   2. Or for full restart: docker compose restart"
echo "   3. Check logs: docker logs la-toolkit"
