#!/usr/bin/env bash
# 提交并同时推送到 GitHub 与 Gitea
# 用法: ./push-both.sh "提交说明"
set -euo pipefail
cd "$(dirname "$0")"
msg="${1:-update: $(date '+%Y-%m-%d %H:%M:%S')}"

git add -A
if git diff --cached --quiet; then
  echo "[i] 没有需要提交的变更"
else
  git commit -m "$msg"
fi

echo "[>] 推送到 GitHub..."
git push github main
echo "[>] 推送到 Gitea..."
git -c credential.helper=osxkeychain push gitea main

# 标签（可选，失败不阻断）
git push github --tags 2>/dev/null || true
git -c credential.helper=osxkeychain push gitea --tags 2>/dev/null || true

echo "[✓] 已同步到 GitHub 和 Gitea"
