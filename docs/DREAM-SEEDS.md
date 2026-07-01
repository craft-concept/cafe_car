# Dream seeds — the divergent leg's entropy source

The divergent leg (`.claude/agents/dream.md` step 5) is **input-starved, not idea-starved**: run on
nothing but the day's own consolidated state, it correctly abstains when there's nothing new — but
that means most passes produce nothing even though the business has plenty to think about. A
**dream seed** is one concrete provocation/lens/constraint the leg pulls to force a genuinely
different angle each time, on top of (never instead of) this pass's own maintenance delta (see
dream.md step 5 — maintenance comes first).

This is a **growing, git-tracked, curated list — anyone (any dream pass, the operator, the owner)
can append a seed.** Killed/stale seeds get struck through, not deleted, so the pool's history stays
legible. Delete the placeholder rows below once you've replaced them with venture-specific ones.

## Selection — deterministic, replay-safe, varies daily

**Never `Date.now()`/random in a way that breaks a resumed run.** Use the day-of-year, which is
deterministic for a given date (re-running the same day's dream — e.g. a resumed or forced second
pass — deterministically re-pulls the *same* seed, which is correct: it's not new entropy, so
picking a fresh one would be manufacturing variety that isn't there):

```bash
n=$(grep -c '^- \*\*\[' docs/DREAM-SEEDS.md)
i=$(( $(date -u +%-j) % n ))                                  # 0-indexed
sed -n "$(( i + 1 ))p" <(grep '^- \*\*\[' docs/DREAM-SEEDS.md)  # the pulled seed
```
Run this in step 5, after the maintenance delta is already in hand. As the list grows, the mapping
from day-of-year → seed shifts — that's fine, there's no requirement that a given day always pull
the same seed across the list's lifetime, only that *today's* pull is deterministic if repeated.

## Categories

### Lens rotation
- **[Lens: cost]** Lead with COST this pass: what's the single biggest recurring expense (token
  spend, a paid tool, COGS) — what's one change that could halve it?
- **[Lens: growth]** Lead with GROWTH this pass: where's the most latent demand not yet captured
  (waitlist, traffic, repeat visitors) — what's the cheapest test to convert more of it?
- **[Lens: adjacency]** Lead with ADJACENCY this pass: what's the business's strongest existing
  asset (a tool, an audience, a piece of IP) — what adjacent thing could it sell that it doesn't yet?
- **[Lens: moat]** Lead with MOAT this pass: what do we know or have built that would be genuinely
  hard for a fast-follower to copy in a week — are we actually leaning on it anywhere?
- **[Lens: product]** Lead with PRODUCT this pass: what's the single most annoying step in the core
  customer loop, today?

### Constraint provocations (Oblique-Strategies-style)
- **[Constraint]** What if this venture had to 10x its margin — not its revenue — this month? What
  would you cut, automate, or reprice?
- **[Constraint]** What would a well-funded competitor ship against you THIS WEEK? Would it hurt?
  Should you ship it first?
- **[Constraint]** If you could only keep using ONE tool/service — imagine losing everything else —
  what breaks first, and is that a single point of failure worth de-risking now?
- **[Constraint]** What's the dumbest, cheapest version of the next idea that could ship this week
  instead of the "proper" version — and would it actually teach you less?

### Cross-domain pollination
- **[Cross-domain]** Pull the most recent durable lesson from one part of the business (product,
  ops, marketing) — what does it imply for a DIFFERENT part that hasn't hit that problem yet?
- **[Cross-domain]** If your operator repo lives alongside sibling ventures in holdco's fleet, check
  `../*/WORKLOG.md` for a recent cross-cutting lesson (deploy safety, a pipeline, a review flow) —
  does it apply here too?

### External signal (true outside-the-loop happenstance)
- **[External]** Fetch the latest Claude Code / Claude API changelog or release notes — given what's
  new, what should this business try?
- **[External]** Fetch one recent item relevant to this venture's market (a competitor move, a
  platform change, an industry trend) — what does it suggest?

### Resurface a shelved idea / past decision
- **[Resurface]** Pull one `killed` row from `IDEAS.md` — has anything changed (a new tool, a new
  decision in `docs/DECISIONS.md`, a new capability) that would flip the verdict?
- **[Resurface]** Pull one entry from `docs/DECISIONS.md` — now that time has passed, is the
  decision still right, or has the situation it was made under changed?
- **[Resurface]** Pull one `proposed` row from `IDEAS.md` that's been sitting unrun for a while —
  why hasn't it moved? Is it actually cheap, or was it misrouted?
