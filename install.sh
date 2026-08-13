#!/bin/sh
# seudesign sdp 스킬 범용 설치 스크립트
#
#   curl -fsSL https://raw.githubusercontent.com/SeuPut0705/seudesign/main/install.sh | sh
#
# 기본: ~/.claude/skills/sdp 에 설치 (Claude Code 및 스킬 디렉토리 호환 에이전트).
# 다른 경로: DEST=/path/to/skills sh install.sh

set -eu

REPO="SeuPut0705/seudesign"
DEST="${DEST:-$HOME/.claude/skills}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "seudesign sdp 스킬 설치"
echo "  대상: $DEST/sdp"

curl -fsSL "https://codeload.github.com/$REPO/tar.gz/refs/heads/main" | tar -xz -C "$TMP"

mkdir -p "$DEST"
rm -rf "$DEST/sdp"
cp -R "$TMP"/seudesign-main/skills/sdp "$DEST/sdp"

echo "  완료: $(find "$DEST/sdp" -name '*.md' | wc -l | tr -d ' ')개 문서 설치됨"
echo ""
echo "플러그인 방식을 지원하는 에이전트는 그쪽을 권장:"
echo "  Claude Code : /plugin marketplace add $REPO  →  /plugin install sdp@seudesign"
echo "  Codex       : codex plugin marketplace add $REPO && codex plugin add sdp@seudesign"
echo "  Copilot CLI : copilot plugin marketplace add $REPO && copilot plugin install sdp@seudesign"
