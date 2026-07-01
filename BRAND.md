# CafeCar — Brand Voice Guide

CafeCar's specific voice. The universal AI-slop ban list (banned lexicon, antithesis tic,
rule-of-three, em-dash overuse, detail-free upbeat tone) lives in the `designer` persona and is
inherited — this file captures only what's specific to CafeCar.

## Our purpose and our standard

Everything we build is for the glory of God. This is the first filter on all our work — above
profit and above growth.

- **Nothing wrong in God's eyes.** We do not create, sell, promote, or support anything vulgar,
  disturbing, harmful, or evil. If a product, feature, customer request, campaign, or growth
  tactic would produce something wrong in God's sight, we decline it — no matter the revenue.
- **Never offensive to Christ or to Christians.** Nothing we produce should dishonor Christ or
  offend Christians. The one exception: neutrally and respectfully serving a request that
  specifically concerns another religion (e.g. a book about Holi) is honest work for a customer,
  not an endorsement. Mocking, demeaning, or dishonoring Christ is never allowed.
- **Love your neighbor as yourself.** We treat every customer, user, and neighbor the way we would
  want to be treated: honestly, generously, and for their good. We do what is right and loving
  **even when it costs us money.** When doing right and making a profit conflict, right wins.

When in doubt, don't. Decline the work, note why, and move on.

## Who we're talking to

Rails developers who need an admin panel, internal tool, or back-office and don't want to
hand-roll CRUD views or adopt a heavyweight admin framework. They're fluent in Rails, read code
faster than prose, trust convention over configuration, and are skeptical of magic and marketing.
They already talk in `model`/`controller`/`Turbo`/`Pundit` — meet them there.

## Voice adjectives (each defined behaviorally)

- **Rails-native** = speak in Rails idioms and assume Rails fluency. Name real concepts
  (controllers, Pundit policies, Turbo Streams, Kaminari) directly; never dumb them down or
  explain Rails basics. It should read like it was written by someone who ships Rails apps.
- **Show, don't claim** = prove every capability with a code snippet or the live demo, not an
  adjective. Replace "powerful filtering" with the actual query: `?total=>100`.
- **Opinionated** = state the thesis and the default plainly ("Rails should render something by
  default"). Recommend the one right way instead of enumerating options. Take a position.
- **Terse** = lead with the payoff, cut throat-clearing. One line of controller code, one
  sentence of why. The reader is busy.
- **Unhyped** = describe what it does at face value. Confidence comes from precision, not volume —
  no intensifiers, no exclamation-driven enthusiasm.

## Behavioral do / don't

- **Do:** open with the one line of code or the concrete result ("One line generates index, show,
  new, and edit").
- **Do:** name the real mechanism — Pundit, Kaminari, Turbo Streams, Rouge — credibility comes
  from specificity.
- **Do:** write code identifiers exactly (`cafe_car`, `rails g cafe_car:resource`); prefer a
  runnable snippet over a description of one.
- **Do:** use sentence case and plain periods; keep paragraphs to one or two sentences.
- **Don't:** use marketing intensifiers — effortless, seamless, blazing-fast, magical, powerful,
  revolutionary, game-changer, supercharge.
- **Don't:** manufacture excitement with exclamation points. (The README's emoji feature-bullets
  are the ceiling, not the floor; prose stays calm.)
- **Don't:** hedge ("might," "could possibly help") or hand-wave with "simply" / "just."

## Lexicon

| Always use | Sometimes use | Never use |
|---|---|---|
| Rails engine; auto-generated; one line; override; sensible defaults; the `cafe_car` macro; back-office / admin / internal tools; convention | turnkey (as in the keyword-search bullet); zero-config (only when literally true); emoji (feature-bullet lists only) | effortless(ly); seamless(ly); blazing-fast; magical / magic; revolutionary; game-changer; supercharge; "powerful" as a standalone claim; leverage (as a verb) |

## On-voice / off-voice examples

- **Off:** "Supercharge your Rails admin with effortless CRUD generation!"
  **On:** "A complete Rails admin from one line of controller code."
- **Off:** "CafeCar is a powerful, flexible solution that revolutionizes how you build admin panels."
  **On:** "Rails should render something for your models by default. CafeCar does — then gets out of the way when you override it."
- **Off:** "Enjoy blazing-fast, magical filtering capabilities."
  **On:** "Filter any index by range, comparison, or association count: `?created_at=>2024-01-01`."
- **Off:** "Get started today and transform your workflow!"
  **On:** "Add `gem \"cafe_car\"`, run the installer, point it at a model."
- **Off (error):** "Oops! Something went wrong. Please try again later."
  **On (error):** "Couldn't save: title can't be blank. Fix that field and resubmit."
- **Off (empty state):** "No data yet — start your journey!"
  **On (empty state):** "No invoices yet. \"New invoice\" fills this table."
- **Off (transactional email):** "We're thrilled to let you know your export is ready!"
  **On (transactional email):** "Your CSV export is ready: 1,240 rows. Link below, expires in 24h."
- **Off (social):** "🚀🚀 Game-changing Rails gem that will revolutionize your admin panels!! 🚀🚀"
  **On (social):** "Hand-rolled one more admin CRUD view? Try `cafe_car`: one line gives you index/show/new/edit. Demo (no signup) in the README."

## Per-channel notes

- **Landing headline:** one sentence; lead with the outcome (a full admin) and the cost (one
  line). No exclamation.
- **Product UI / microcopy (buttons, empty states, tooltips):** imperative and short ("New
  invoice," "Download CSV," "Edit"); match Rails scaffold conventions; sentence case.
- **Error messages:** plain and specific; name the field and the next step; blame the system or
  state, not the user; never "Oops."
- **Transactional email:** lead with the fact (what's ready or done), include the concrete number
  and the link; no enthusiasm padding.
- **Marketing email / social:** developer-to-developer. A real snippet or the demo link does the
  selling; at most one emoji; no hype stacking.
