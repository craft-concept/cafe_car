---
description: File a 💡 proposal to the owner on the Task Graph. Takes a vetted
  one-paragraph pitch — thesis · cost · expected value. Files as a P2 task under this
  venture's project so it reaches the owner.
argument-hint: "<thesis · cost · expected value pitch>"
disable-model-invocation: true
allowed-tools: Bash
---

## File proposal: $ARGUMENTS

A **proposal** is a consequential idea that needs the owner's call (irreversible, money out, brand
pivot, legal, or an owner-only resource — see `AGENTS.md` → "Ideation"). It should already be
vetted by a quick panel mini-review and phrased as **thesis · cost · expected value**.

File the proposal from $ARGUMENTS on the Task Graph. Use the thesis (first sentence) as the title
and the rest (cost · expected value) as the body. v2 has no `kind=proposal` — a P2 task under this
venture's project is the proposal.

```bash
task new P2 .project=cafe_car .title="<THESIS>" .body="<cost · expected value>"
```

Confirm the id it prints, then add a `proposed` row to `IDEAS.md`.
