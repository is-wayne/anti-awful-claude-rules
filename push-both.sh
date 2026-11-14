#!/usr/bin/env bash
# 提交并同时推送到 GitHub 与 Gitea（任一远程失败不阻断另一个）
# 用法: ./push-both.sh "提交说明"
set -uo pipefail
cd "$(dirname "$0")"
msg="${1:-update: $(date '+%Y-%m-%d %H:%M:%S')}"

git add -A
if git diff --cached --quiet; then
  echo "[i] 没有需要提交的变更"
else
  git commit -m "$msg" || { echo "[x] 提交失败"; exit 1; }
fi

rc=0
echo "[>] 推送到 GitHub..."
if git push github main; then echo "  ✓ GitHub OK"; else echo "  ! GitHub 推送失败（见上）"; rc=1; fi

echo "[>] 推送到 Gitea..."
if git -c credential.helper=osxkeychain push gitea main; then echo "  ✓ Gitea OK"; else echo "  ! Gitea 推送失败（见上）"; rc=1; fi

# 标签（可选，失败不阻断）
git push github --tags 2>/dev/null || true
git -c credential.helper=osxkeychain push gitea --tags 2>/dev/null || true

if [ "$rc" = 0 ]; then echo "[✓] 已同步到 GitHub 和 Gitea"; else echo "[!] 部分远程未同步，请检查上面输出"; fi
exit $rc
