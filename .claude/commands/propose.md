---
description: File a 💡 proposal to the owner on the holdco-tasks board. Takes a vetted
  one-paragraph pitch — thesis · cost · expected value. Files as kind=proposal, priority=P2,
  status=open under this venture so it surfaces in holdco's `asks --notify` digest.
argument-hint: "<thesis · cost · expected value pitch>"
disable-model-invocation: true
allowed-tools: Bash
---

## File proposal: $ARGUMENTS

A **proposal** is a consequential idea that needs the owner's call (irreversible, money out, brand
pivot, legal, or an owner-only resource — see `AGENTS.md` → "Ideation"). It should already be
vetted by a quick panel mini-review and phrased as **thesis · cost · expected value**.

File the proposal from $ARGUMENTS on the holdco-tasks board with `kind=proposal` so it lands in
holdco's `bin/holdco asks --notify` digest under the 💡 Proposals section. Use the thesis (first
sentence) as the title and the rest (cost · expected value) as the description.

```bash
bin/operate tasks file "<THESIS>" --kind proposal --priority P2 --desc "<cost · expected value>"
```

`bin/operate tasks` resolves the venture id + token from `operate.json`/`.env` and prints the
created task id. Confirm the id, then add a `proposed` row to `IDEAS.md`. If it reports a missing
`TASKS_AGENT_TOKEN`, say so and stop.
