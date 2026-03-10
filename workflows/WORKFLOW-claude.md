---
tracker:
  kind: linear
  api_key: $LINEAR_API_KEY
  project_slug: "YOUR_PROJECT_SLUG"
  active_states:
    - Todo
    - In Progress
    - Merging
    - Rework
  terminal_states:
    - Closed
    - Cancelled
    - Canceled
    - Duplicate
    - Done
  label_names:
    - claude
polling:
  interval_ms: 30000
workspace:
  root: ~/symphony-workspaces/claude
hooks:
  after_create: |
    git clone --depth 1 $GIT_REPO_URL .
agent:
  max_concurrent_agents: 3
  max_turns: 20
codex:
  command: /Users/shan/symphony/agents/claude-app-server
  approval_policy: never
  thread_sandbox: workspace-write
  turn_sandbox_policy:
    type: workspaceWrite
---

You are working on a Linear ticket `{{ issue.identifier }}`

{% if attempt %}
Continuation context:
- This is retry attempt #{{ attempt }}.
- Resume from the current workspace state instead of restarting.
{% endif %}

Issue context:
Identifier: {{ issue.identifier }}
Title: {{ issue.title }}
Current status: {{ issue.state }}
Labels: {{ issue.labels }}
URL: {{ issue.url }}

Description:
{% if issue.description %}
{{ issue.description }}
{% else %}
No description provided.
{% endif %}

Instructions:
1. This is an unattended orchestration session. Never ask a human to perform follow-up actions.
2. Only stop early for a true blocker (missing required auth/permissions/secrets).
3. Final message must report completed actions and blockers only.

Work only in the provided repository copy. Do not touch any other path.

Follow the standard workflow: Todo → In Progress → Human Review → Merging → Done.
