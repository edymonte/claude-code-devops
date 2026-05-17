#!/bin/bash

# Auto-Sync Script - Keep fork in sync with upstream
# Usage: bash auto-sync.sh
# Syncs every 30 minutes until manually stopped (Ctrl+C)

set -e

UPSTREAM_URL="https://github.com/veronez-io/claude-code-devops"
SYNC_INTERVAL=1800  # 30 minutes in seconds
BRANCH="main"

echo "================================"
echo "🔄 Auto-Sync with Upstream"
echo "================================"
echo ""
echo "📍 Upstream: $UPSTREAM_URL"
echo "📍 Branch: $BRANCH"
echo "⏱️  Sync interval: 30 minutes"
echo ""
echo "⚠️  Press Ctrl+C to stop syncing"
echo ""
echo "================================"
echo ""

# Initial setup - add upstream remote
git remote remove upstream 2>/dev/null || true
git remote add upstream "$UPSTREAM_URL"

echo "✅ Upstream remote added"
echo ""

# Sync loop
SYNC_COUNT=0
while true; do
  SYNC_COUNT=$((SYNC_COUNT + 1))
  TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📦 Sync #$SYNC_COUNT at $TIMESTAMP"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  # Fetch from upstream
  if git fetch upstream "$BRANCH" 2>&1 | grep -q "fatal"; then
    echo "❌ Failed to fetch from upstream"
  else
    echo "✅ Fetched from upstream"

    # Merge into local branch
    if git merge "upstream/$BRANCH" --no-edit 2>&1 | grep -q "Already up to date"; then
      echo "✅ Already up to date (no new commits)"
    elif git merge "upstream/$BRANCH" --no-edit 2>&1 | grep -q "fatal"; then
      echo "⚠️  Merge conflict or error - manual intervention needed"
    else
      echo "✅ Merged new commits"

      # Push to origin
      if git push origin "$BRANCH" 2>&1 | grep -q "error"; then
        echo "⚠️  Failed to push to origin"
      else
        echo "✅ Pushed to origin"
      fi
    fi
  fi

  # Calculate next sync time
  NEXT_SYNC=$((SYNC_INTERVAL / 60))
  echo ""
  echo "⏰ Next sync in $NEXT_SYNC minutes..."
  echo ""

  sleep $SYNC_INTERVAL
done
