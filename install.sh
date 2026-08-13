#!/bin/sh
# seudesign sdp skill — universal installer
#
#   curl -fsSL https://raw.githubusercontent.com/SeuPut0705/seudesign/main/install.sh | sh
#
# Default: installs to ~/.claude/skills/sdp (Claude Code and any agent reading a skills dir).
# Custom path: DEST=/path/to/skills sh install.sh

set -eu

REPO="SeuPut0705/seudesign"
DEST="${DEST:-$HOME/.claude/skills}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "Installing the seudesign sdp skill"
echo "  target: $DEST/sdp"

curl -fsSL "https://codeload.github.com/$REPO/tar.gz/refs/heads/main" | tar -xz -C "$TMP"

mkdir -p "$DEST"
rm -rf "$DEST/sdp"
cp -R "$TMP"/seudesign-main/skills/sdp "$DEST/sdp"

echo "  done: $(find "$DEST/sdp" -name '*.md' | wc -l | tr -d ' ') documents installed"
echo ""
echo "Agents with plugin support should prefer:"
echo "  Claude Code : /plugin marketplace add $REPO  →  /plugin install seudesign@seudesign"
echo "  Codex       : codex plugin marketplace add $REPO && codex plugin add seudesign@seudesign"
echo "  Copilot CLI : copilot plugin marketplace add $REPO && copilot plugin install seudesign@seudesign"
