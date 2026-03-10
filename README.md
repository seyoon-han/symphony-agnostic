# symphony-agnostic

> Fork of [openai/symphony](https://github.com/openai/symphony) with support for **Codex, Claude Code, and Gemini** — plus label-based agent routing so each Linear issue is automatically dispatched to the right agent.

## What's different from the original

| Feature | openai/symphony | symphony-agnostic |
|---|---|---|
| Supported agents | Codex only | Codex, Claude Code, Gemini |
| Agent selection | hardcoded | Linear label (`codex` / `claude` / `gemini`) |
| Launcher | manual binary invocation | `symphony [agent] [slug]` from anywhere |
| Project slug | baked into workflow file | read from project's `.env.local` |
| Model override | Codex flag only | `--model <name>` on all wrappers |

## How it works

Run one `symphony` process per agent. Each process polls Linear and only picks up issues labeled for its agent.

```
Linear issue (label: codex)   →  symphony codex  →  Codex app-server
Linear issue (label: claude)  →  symphony claude →  claude-app-server → Claude Code CLI
Linear issue (label: gemini)  →  symphony gemini →  gemini-app-server → Gemini ACP
```

## Setup

### 1. Prerequisites

```bash
# Codex v0.112+ (not the Homebrew version)
gh release download rust-v0.112.0 -R openai/codex --pattern 'codex-*-aarch64-apple-darwin.tar.gz' -D /tmp
tar -xzf /tmp/codex-*.tar.gz -C ~/.local/bin

# Claude Code
npm install -g @anthropic-ai/claude-code

# Gemini CLI
npm install -g @google/gemini-cli
```

### 2. Clone and configure

```bash
git clone https://github.com/seyoon-han/symphony-agnostic ~/symphony
cd ~/symphony

cp .env.example .env
# Fill in LINEAR_API_KEY and GIT_REPO_URL in .env
```

### 3. Install global launcher

```bash
ln -s ~/symphony/symphony.sh ~/.local/bin/symphony
chmod +x ~/.local/bin/symphony
```

### 4. Set up Linear labels

Create three labels in your Linear workspace: **`codex`**, **`claude`**, **`gemini`**.
Tag each issue with the agent you want to handle it.

### 5. Run

```bash
# In your project directory (saves slug to .env.local automatically on first run)
symphony codex my-project-abc123
symphony claude my-project-abc123
symphony gemini my-project-abc123

# Next time, slug is read from .env.local
symphony codex
symphony claude
symphony gemini
```

### Model override (optional)

```yaml
# In workflows/WORKFLOW-claude.md
codex:
  command: /Users/yourname/symphony/agents/claude-app-server --model claude-opus-4-6

# In workflows/WORKFLOW-gemini.md
codex:
  command: node /Users/yourname/symphony/agents/gemini-app-server --model gemini-2.5-pro

# In workflows/WORKFLOW-codex.md
codex:
  command: ~/.local/bin/codex --config model=o3 app-server
```

Omit `--model` to use each agent's default.

## Architecture

```
symphony.sh                   # launcher — loads env, patches slug, calls binary
├── workflows/
│   ├── WORKFLOW-codex.md     # label_names: [codex]
│   ├── WORKFLOW-claude.md    # label_names: [claude]
│   └── WORKFLOW-gemini.md    # label_names: [gemini]
├── agents/
│   ├── claude-app-server     # Codex JSON-RPC → Claude Code CLI
│   └── gemini-app-server     # Codex JSON-RPC → Gemini ACP
└── elixir/                   # Symphony Elixir orchestrator (modified)
    └── lib/symphony_elixir/
        ├── config.ex          # + label_names tracker option
        └── linear/client.ex   # + label-based issue filtering
```

## Credits

Built on [openai/symphony](https://github.com/openai/symphony). Agent wrappers and routing additions by [@seyoon-han](https://github.com/seyoon-han).
