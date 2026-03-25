# Aztec Dev Environment

A development environment for building [Aztec](https://aztec.network) smart contracts with [Claude Code](https://claude.ai/code). Opens in a devcontainer with all tooling pre-installed and Claude Code pre-configured for approval-free operation.

## What's Included

- **Aztec CLI & nargo** (v4.1.0, testnet) — compile, test, and deploy contracts
- **Claude Code** — AI-assisted development, pre-configured with full permissions
- **Aztec MCP Server** — search Aztec docs, code, and examples from within Claude Code

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (Docker Desktop or Docker Engine)
- The [`devcontainer` CLI](https://github.com/devcontainers/cli): `npm install -g @devcontainers/cli`

> **Note:** VS Code's Dev Containers extension and GitHub Codespaces are not currently supported. The base image includes a git-lfs feature whose postCreateCommand fails on repos without LFS objects, blocking all subsequent setup. The `./dev` script works around this by using `--skip-post-create`. See [#1](#) if you'd like to help fix this.

## Getting Started

```bash
# Clone the template (or click "Use this template" on GitHub first)
git clone https://github.com/YOUR_USERNAME/aztec-dev-env.git
cd aztec-dev-env

# Start the container (first run takes a few minutes to install tooling)
./dev
```

This builds the devcontainer, installs Aztec + Claude Code + the MCP server, and drops you into a shell.

Then start Claude Code:

```bash
claude
```

Or use `yolo` to skip all permission prompts entirely:

```bash
yolo
```

This runs `claude --dangerously-skip-permissions`, which lets Claude execute any action without confirmation. Only use this in disposable environments.

If this is your first time, log in with `claude login` (Claude subscription) or set `ANTHROPIC_API_KEY` in your environment.

## Using Claude Code

Claude has full permissions to run commands, edit files, and use all Aztec MCP tools without asking for approval.

### Useful Slash Commands

| Command | Description |
|---------|-------------|
| `/aztec:new-contract <name>` | Create a new Aztec contract |
| `/aztec:review-contract <path>` | Review a contract for best practices |
| `/aztec:add-function <desc>` | Add a function to an existing contract |
| `/aztec:add-test <desc>` | Add a test for a contract function |
| `/aztec:explain <concept>` | Explain an Aztec concept |
| `/aztec:deploy <contract>` | Generate a deployment script |
| `/aztec-version` | Check or switch Aztec version |

### Example Workflow

```
> claude

You: Create a private token contract with mint and transfer functions

Claude: [uses MCP server to check current Aztec patterns, creates contract, compiles it]

You: Add TXE tests for the transfer function

Claude: [generates tests, runs them with `aztec test`]

You: Deploy it to testnet

Claude: [generates deployment script, deploys]
```

## Aztec Version

This environment is pinned to **Aztec v4.1.0** (testnet). To update:

1. Change the version in `.devcontainer/setup.sh`
2. Update the `tag` in any `Nargo.toml` files
3. Update `@aztec/*` package versions in `package.json`
4. Rebuild the container

## Permissions

The `.claude/settings.local.json` grants Claude full permissions (`Bash(*)`, `Edit(*)`, `Write(*)`). This is intentional for a disposable development container. If you want tighter controls, edit that file to scope permissions down.

## Resources

- [Aztec Documentation](https://docs.aztec.network)
- [Aztec AI Tooling Guide](https://docs.aztec.network/developers/ai_tooling)
- [Noir Language](https://noir-lang.org)
- [Claude Code](https://claude.ai/code)
