---
description: File a 💡 proposal to the owner on the holdco-tasks board. Takes a vetted
  one-paragraph pitch — thesis · cost · expected value. Files as kind=proposal, priority=P2,
  status=open under this venture so it surfaces in holdco's `asks --notify` digest.
argument-hint: "<thesis · cost · expected value pitch>"
disable-model-invocation: true
allowed-tools: Bash
---

## File proposal: $ARGUMENTS

### Current API state

!`source .env 2>/dev/null; echo "VENTURE_ID=${TASKS_VENTURE_ID:-cafe_car}" && echo "TASKS_WORKER_URL=${TASKS_WORKER_URL:-https://holdco-tasks.yaks.workers.dev}" && echo "TOKEN_SET=$([ -n "$TASKS_AGENT_TOKEN" ] && echo yes || echo MISSING)"`

### Instructions

A **proposal** is a consequential idea that needs the owner's call (irreversible, money out, brand
pivot, legal, or an owner-only resource — see `AGENTS.md` → "Ideation"). It should already be
vetted by a quick panel mini-review and phrased as **thesis · cost · expected value**.

File the proposal from $ARGUMENTS as a new task on the holdco-tasks board with `kind=proposal` so
it lands in holdco's `bin/holdco asks --notify` digest under the 💡 Proposals section.

- `venture_id`: read from `TASKS_VENTURE_ID` in `.env` (shown above); fall back to `cafe_car`
- `kind`: `proposal`
- `priority`: `P2`
- `status`: `open`

Use the first sentence of $ARGUMENTS as the `title` (the thesis). Use the rest as `description`.

```bash
source .env
curl -sf -X POST "${TASKS_WORKER_URL:-https://holdco-tasks.yaks.workers.dev}/api/v1/tasks" \
  -H "Authorization: Bearer ${TASKS_AGENT_TOKEN}" \
  -H "Content-Type: application/json" \
  -d '{"venture_id":"<VENTURE_ID>","kind":"proposal","priority":"P2","status":"open","title":"<THESIS>","description":"<cost · expected value>"}'
```

Confirm the created task ID, then add a `proposed` row to `IDEAS.md`. If TASKS_AGENT_TOKEN is
missing from `.env`, say so and stop.
