#!/usr/bin/env bash
set -e

AZTEC_VERSION="4.1.0"

echo "==> Configuring git..."
git config --global --add safe.directory '*'

echo "==> Installing Claude Code..."
curl -fsSL https://claude.ai/install.sh | bash

echo "==> Installing Aztec toolchain (v${AZTEC_VERSION})..."
VERSION=${AZTEC_VERSION} bash -i <(curl -sL "https://install.aztec.network/${AZTEC_VERSION}")

# Ensure aztec/nargo are on PATH for this script and future shells
export PATH="$HOME/.aztec/current/bin:$HOME/.aztec/current/node_modules/.bin:$HOME/.nargo/bin:$PATH"
if ! grep -q '.aztec/current' "$HOME/.bashrc" 2>/dev/null; then
  echo 'export PATH="$HOME/.aztec/current/bin:$HOME/.aztec/current/node_modules/.bin:$HOME/.nargo/bin:$PATH"' >> "$HOME/.bashrc"
fi

echo "==> Installing Aztec Claude plugin..."
claude plugin marketplace add critesjosh/aztec-claude-plugin

echo "==> Adding Noir MCP server..."
claude mcp add noir -- npx noir-mcp-server@latest

echo "==> Adding 'yolo' command..."
cat > "$HOME/.local/bin/yolo" << 'SCRIPT'
#!/usr/bin/env bash
exec claude --dangerously-skip-permissions "$@"
SCRIPT
chmod +x "$HOME/.local/bin/yolo"

echo "==> Setup complete!"
echo "    Aztec version: ${AZTEC_VERSION}"
echo "    Run 'claude' to start Claude Code, or 'yolo' to skip all permission prompts."
echo "    Log in with 'claude login' or set ANTHROPIC_API_KEY."
