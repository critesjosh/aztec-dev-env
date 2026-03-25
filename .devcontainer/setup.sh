#!/usr/bin/env bash
set -e

AZTEC_VERSION="4.1.0"

echo "==> Configuring git..."
git config --global --add safe.directory '*'

echo "==> Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash

echo "==> Installing Aztec toolchain (v${AZTEC_VERSION})..."
echo y | VERSION=${AZTEC_VERSION} bash <(curl -sL "https://install.aztec.network/${AZTEC_VERSION}")

# Ensure aztec/nargo are on PATH for this script and future shells
export PATH="$HOME/.aztec/current/bin:$HOME/.aztec/current/node_modules/.bin:$HOME/.nargo/bin:$PATH"
if ! grep -q '.aztec/current' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.aztec/current/bin:$HOME/.aztec/current/node_modules/.bin:$HOME/.nargo/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "==> Verifying Aztec installation..."
aztec --version || { echo "ERROR: Aztec installation failed"; exit 1; }

echo "==> Adding Aztec MCP server..."
claude mcp add aztec-mcp -- npx --prefer-online -y @aztec/mcp-server@latest

echo "==> Adding 'yolo' command..."
mkdir -p "$HOME/.local/bin"
CLAUDE_BIN=$(which claude 2>/dev/null || echo "$HOME/.claude/bin/claude")
cat > "$HOME/.local/bin/yolo" << SCRIPT
#!/usr/bin/env bash
exec $CLAUDE_BIN --dangerously-skip-permissions "\$@"
SCRIPT
chmod +x "$HOME/.local/bin/yolo"
if ! grep -q '\.local/bin' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "==> Setup complete!"
echo "    Aztec version: ${AZTEC_VERSION}"
echo "    Run 'claude' to start Claude Code, or 'yolo' to skip all permission prompts."
echo "    Log in with 'claude login' or set ANTHROPIC_API_KEY."
