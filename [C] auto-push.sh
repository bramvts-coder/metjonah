#!/bin/bash
# Auto-push companion for the metjonah scheduled task.
# Loaded by ~/Library/LaunchAgents/com.bramvts.metjonah-autopush.plist
# Runs hourly. Does nothing if there's nothing to push.

set -e
export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

REPO="/Users/bramglo/Desktop/Cowork homebase/02 Projects/Jonah"
cd "$REPO"

# 1) Clean stale lock files left behind by sandbox runs that crashed mid-commit.
rm -f .git/index.lock .git/HEAD.lock 2>/dev/null || true

# 2) Stage any working-tree changes (typically just index.html after a refresh).
git add -A

# 3) Commit if there are staged changes.
if ! git diff --cached --quiet; then
  git -c user.email="bramvts@gmail.com" -c user.name="Bram" \
    commit -m "auto-update: refresh binnenkort events $(date -I)"
fi

# 4) Push if local is ahead of origin (covers commits the sandbox managed to make
#    but couldn't push, plus the commit we just made).
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse '@{u}' 2>/dev/null || echo "")
if [ -n "$REMOTE" ] && [ "$LOCAL" != "$REMOTE" ]; then
  git push
fi
