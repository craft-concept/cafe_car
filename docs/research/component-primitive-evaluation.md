# Component primitive evaluation — should CafeCar re-back its handrolled components on ViewComponent, Phlex, or something else?

*Decision-support report for the owner. Research only — no code changed. Authored 2026-07-09.*
*Directive: DECISIONS.md 2026-07-07 (owner, `auth=VERIFIED(yak.sh)`).*

---

## TL;DR / recommendation

**Keep the Component API. Keep partials as the override seam. Do not adopt ViewComponent or Phlex as a wholesale replacement.** Optionally re-back the *default emit path* (the `content_tag`/`render_partial` branch inside `Component#to_html`) on Phlex later, behind the unchanged API, if a measured benchmark shows the render cost actually matters. It almost certainly doesn't yet.

Three findings drive this:

1. **The owner is right on direction, wrong on magnitude.** Our primitive *is* heavier than plain partials, ViewComponent, and Phlex — measurably so per node. But CafeCar renders tens-to-hundreds of components per admin page, not thousands, and the published benchmark spread is ~1.4–1.9×, i.e. sub-millisecond differences dwarfed by DB and partial I/O. "Slower" is true and not the bottleneck.
2. **The owner is right that our Component is "a level above."** It is a convention layer (flags→CSS classes, href/current/ancestor, blank-collapse, child naming, policy/locale wiring) whose actual HTML emit is a swappable backend. It could sit *on top of* Phlex or VC. That's an architecture fact, confirmed by reading the code.
3. **The override story is the deal-breaker, and it points *away* from VC/Phlex.** CafeCar's whole value prop — build with components, let the host drop a file to override markup/classes without forking — rests on Rails' ordered view-path lookup (partials). **ViewComponent cannot do path-based template override** (its templates bind to the class's source file, not the view path — a long-standing, closed-as-wontfix limitation). **Phlex has no templates at all** — override means Ruby subclassing. Both force the *gem* to hand-engineer an override seam that partials give us for free. So the mechanism the owner finds a "headache" (partials) is also the one thing that makes the override story work.

**Cheapest next experiment to de-risk:** a one-component spike (do `Button`, it's `content_tag`-only) re-backed on Phlex behind the existing API, plus running the existing dummy app through a `benchmark-ips` render loop to get *our* real numbers. A day's work; tells us both whether the API survives a Phlex backend and whether the perf gain is worth any dependency at all. Details in [Paths forward](#5-paths-forward).

---

## 1. What the primitive is today, and is it slower?

### The mechanism (from the code)

Every capitalized call in a CafeCar view — `Page`, `Card`, `Button` — is a component, not a template:

- The view calls a capitalized name → `Helpers#method_missing` (`lib/cafe_car/helpers.rb:294-297`) routes it to `ui.send(name)` → `Context#method_missing` (`lib/cafe_car/context.rb`) resolves `CafeCar::UI::<Name>` if declared, else falls back to the base class, and does `Component.new(template, [name], …)`.
- Components are declared in `app/ui/cafe_car/ui/*.rb` with a tiny macro DSL — `component :Card do flag :slim; option :title; component :Head, :Body, … end` (`app/ui/cafe_car/ui/card.rb`). Only **six** classes are declared (Card, Page, Field, Grid, Button, Layout); everything else — and all undeclared children like `card.Section` — falls back to the bare `CafeCar::Component`.
- HAML's `=` emits the component by calling `to_s` → `to_html` (`lib/cafe_car/component.rb:135-140`): `return "" if blank?; wrapper { body }`.
  - `wrapper` = `@template.content_tag(tag, **attributes, &)` (`component.rb:126`).
  - `body` = `context { partial? ? render_partial : content }` (`component.rb:114`).
  - `partial?` (`component.rb:84`) asks Rails' `lookup_context.any?("ui/card", …)` (`helpers.rb:270`); `render_partial` (`component.rb:87-89`) is a full Rails `render`.
- **Only four components are partial-backed** — `app/views/ui/_card.html.haml`, `_field`, `_page`, `_modal_close`. The rest emit pure `content_tag`.

So a CafeCar component is a plain-Ruby object that maps a terse call to CSS classes + attributes and then emits either a `content_tag` or (for four of them) a Rails partial render.

### Per-render cost surface

Every single component render allocates a Ruby object and runs a non-trivial amount of ActiveSupport machinery (`lib/cafe_car/component.rb`):

- `options.extract!(…).with_defaults!` (`:10`), `[*name].map(&:underscore)` (`:60`), `args.extract! { is_a? Symbol }` (`:61`), `attributes.with_defaults!` (`:63`), `attributes.extract_if! { _1 =~ /^[A-Z]/ }` (`:64`) — a regex per attribute key.
- Class computation: `class_names` camelizes (`:93`), then `ui_class` string-joins and camelizes again (`helpers.rb:19-32`).
- `href_for` allocates a `HrefBuilder` when a link is present (`helpers.rb:77`); `current_href?`/`ancestor_href?` parse URIs / call `current_page?`.
- `blank?` (`:110`) runs **two regexes** (`match?` + `gsub`) over the captured content string on every render to decide whether to collapse an empty wrapper.
- `content`/`context`/`capture` do multiple `capture` buffer swaps (`helpers.rb:62-66` overrides `capture`); partial-backed components add a **full Rails partial lookup + render** on top of all the above.
- Capitalized child calls (`card.Section`) go through `method_missing` → `child` (`:142-153`) — and Ruby `method_missing` dispatch is itself slow.

### Perf verdict — the owner's suspicion is correct in direction, nuanced in magnitude

Reasoned from the mechanism (no CafeCar-specific benchmark run — see the spike in §5), and calibrated against the published cross-library numbers below:

- **vs plain partials:** a partial-backed CafeCar component does *strictly more* than the raw partial — object allocation, `method_missing`, two blank-detection regexes, class computation, capture swaps — and *then* renders the partial. It is unavoidably slower than the hand-written partial it wraps. The `content_tag`-only components are lighter but still heavier than an inline tag.
- **vs Phlex:** Phlex is pure Ruby method calls appending to one string buffer — no template compile, no partial lookup, no capture buffer swaps, minimal allocation. Our primitive is much heavier per node. Phlex wins decisively on raw node throughput.
- **vs ViewComponent:** VC compiles each template to a Ruby method once and allocates one object per render. We allocate + `method_missing` + maybe render a partial → heavier than VC too.

**The magnitude caveat is the important part.** The canonical cross-library benchmark (KonnorRogers/view-layer-benchmarks, Ruby 3.4.1 / Rails 8.0 / YJIT, accessed 2026-07-10) puts the fastest-to-slowest *mainstream* spread at under 2×: Phlex 20,551 i/s → ViewComponent 18,445 → Rails Partials 14,946. That's Phlex ~11% faster than VC and ~37% faster than partials — on a synthetic nested-render test whose own author says "benchmarks aren't representative of real life." CafeCar sits below partials (it wraps them), but the whole band is sub-millisecond per node. An admin index renders on the order of 10²  components; DB queries and partial I/O dominate the request. **So: yes, handrolled is the slowest of the bunch — but it is very unlikely to be a user-visible bottleneck for CafeCar's CRUD/admin use-case.** Optimize only if a real measurement says so.

## 2. Is our Component "a level above" these libraries? Yes.

The Component is not competing at the "unit of reuse" layer that VC and Phlex occupy. It's a **convention layer** that maps a terse view call to a bundle of behaviors:

- CSS modifier classes from bare-symbol flags (`Button :danger` → `.Button-danger`) via `ui_class`;
- automatic `current` / `ancestor` link classes and href resolution (`component.rb:77-99`);
- blank-content collapse — no empty wrappers (`component.rb:109-110`);
- nested child naming (`card.Section` → `.Card_Section`) with no declaration needed;
- an optional **partial override seam** (`partial? ? render_partial : content`);
- policy- and locale-driven behavior wired through the same objects (`bulk_action` buttons, etc., `helpers.rb:163-206`).

Crucially, the *actual HTML emit* — `wrapper` (content_tag) and `render_partial` — is a thin, isolated backend. The flag/option/child/href/blank machinery is orthogonal to how the final bytes get produced. **The owner's hypothesis holds: the Component API could sit on top of a Phlex or VC emit backend**; only `wrapper`, `content`, and `render_partial` touch the rendering primitive. That's what makes a "re-back, don't replace" path even possible (§5, Option B).

## 3. The override story — the make-or-break constraint

CafeCar's override ergonomic rests **entirely** on Rails' ordered view-path lookup:

- The engine appends its view paths and the host's (`lib/cafe_car/controller.rb:53-56`, `append_view_path`).
- **CRUD view override:** a host `app/views/products/index.html.haml` shadows the gem's `app/views/cafe_car/application/index.html.haml` via the controller prefix + `application` fallback (README "Customizing Views").
- **Component markup override:** the partial `ui/card` — a host drops `app/views/ui/_card.html.haml` and replaces Card's markup app-wide while keeping the Ruby API (`skills/cafe_car/references/components.md:44-46`).
- **CSS class / label override:** per-component stylesheets + locale strings; no global CSS.

This is **zero-config, no-subclass, file-drop shadowing** — a native Rails partial/template feature. And here is the tension the owner already senses: *the render cost we dislike (partial lookup/render) and the override ergonomic we love (file-drop shadow) are the same Rails mechanism.* You cannot drop partials for pure Ruby without losing the free override — unless you keep the partial as the override *branch* and only replace the default emit.

**Can VC or Phlex give the same host-override ergonomic? No — not for free.** (Research accessed 2026-07-10; sources below.)

| Mechanism | Rails Partials (today) | ViewComponent | Phlex |
|---|---|---|---|
| Host overrides markup by **dropping a file** (view-path shadow) | ✅ zero-config | ❌ **not supported** — template binds to the component's source file, not the view path | ❌ n/a — no templates exist |
| Override requires Ruby **subclassing** | no | **yes** | **yes** |
| Override CSS classes via a **gem-provided config** surface | n/a (locale) | only if the gem builds one | common pattern (initializer `configure` block) |
| **"Eject"/generate** source into the app to own it | n/a | possible via generators | common (e.g. RubyUI) |

- **ViewComponent:** a component's sidecar template is resolved relative to the *class's source file* and compiled onto the class — it is **not** resolved through Rails' view-path chain, so a host file at the same relative path does **not** shadow the gem's. This is exactly [ViewComponent issue #411 "Overriding inherited partials"](https://github.com/ViewComponent/view_component/issues/411) (closed; documented answer: subclass the component and supply your own sidecar template). Slots / `render_in` / `with_collection` are composition APIs, not a host override seam.
- **Phlex:** components are plain Ruby classes; there is no template and no view lookup to hook. Override = subclass and override `view_template` (or specific methods), or the gem exposes a config/registry/eject seam. Phlex-based gems in the wild do exactly this: config initializers that override base/variant class strings (`shadcn_phlexcomponents`), or generators that eject editable source into the app (`RubyUI`). Sources: [phlex.fun](https://www.phlex.fun/), [Fly.io Ruby Dispatch: Phlex](https://fly.io/ruby-dispatch/component-driven-development-on-rails-with-phlex/), [shadcn_phlexcomponents](https://github.com/sean-yeoh/shadcn_phlexcomponents).

**Verdict:** Partials uniquely preserve the file-drop, no-subclass, no-fork override that is CafeCar's selling point. Moving the whole primitive to VC or Phlex would *degrade* the exact feature the owner most wants to keep — unless we keep partials as the override branch and use the library only for the default render (§5, Option B/D).

## 4. Adoption & trajectory (2026)

All figures accessed 2026-07-10; point-in-time unless a source carries its own date.

**ViewComponent** — the larger, more mature ecosystem.
- ~3.6k GitHub stars; **59.8M** cumulative RubyGems downloads; latest **4.12.0** released **2026-06-04**; 204 releases, near-empty issue tracker → actively maintained. Sources: [github.com/ViewComponent/view_component](https://github.com/ViewComponent/view_component), [rubygems.org/gems/view_component](https://rubygems.org/gems/view_component).
- Origin: extracted from **GitHub's** monolith. **GitLab** documents production use (its Pajamas design system ships VC, and it actively migrates Haml → VC with Lookbook previews): [GitLab ViewComponent docs](https://docs.gitlab.com/development/fe_guide/view_component/). Now on the **4.x** line (breaking config changes vs 3.x, e.g. `config.generate.path`).
- Strengths beyond rendering: previews (Lookbook), first-class unit-testing of components, conventions. Weakness for us: **no path-based override** (§3).

**Phlex** — smaller, faster, pure-Ruby, real momentum.
- ~1.5k stars; **4.9M** cumulative downloads; latest **2.4.1** released **2026-02-06**; repo now under the `yippee-fun` org; uses BreakVer. Sources: [github.com/phlex-ruby/phlex](https://github.com/phlex-ruby/phlex), [rubygems.org/gems/phlex](https://rubygems.org/gems/phlex).
- **Phlex 2.x** is the supported line: `template` → `view_template`, Kits promoted, new attribute cache, generators put views under `app/views` namespaced under `Views`. Upgrade guide: [phlex.fun/miscellaneous/v2-upgrade](https://www.phlex.fun/miscellaneous/v2-upgrade). Ecosystem gems: RubyUI, shadcn_phlexcomponents, Literal stacks.
- Relative scale: VC leads Phlex ~2.4× on stars and ~12× on cumulative downloads, but latest-version velocity is closer (VC 351k vs Phlex 213k), consistent with Phlex being younger with momentum on a smaller base.

**Rails-core signals — neither is being blessed.** The dominant 2025–2026 Rails-core view-layer energy is **Herb / ReActionView** (Marco Roth): an HTML-aware ERB toolchain (C parser, linter, formatter, language server) plus `Herb::Engine`, an Erubi-compatible HTML-aware ERB engine, and `ReActionView`, an ActionView-compatible ERB engine aiming at a drop-in `.html.erb` replacement with validation and an opt-in path toward reactivity. Presented across RubyKaigi 2025, RailsConf 2025, Rails World 2025, SF Ruby 2025. Sources: [Introducing Herb](https://marcoroth.dev/posts/introducing-herb), [herb-tools.dev](https://herb-tools.dev/overview). **Strategic read: Rails core is investing in making *ERB* better-tooled, not in adopting a component library.** DHH/37signals are reported to favor native partials + helpers and to be cool on baking VC into Rails (community lore, not a dated primary quote — treat as opinion).

**Other primitives worth a mention:** **Nice Partials** (lightweight partial-locals helper — same view-lookup ergonomics as partials, so it *preserves* the override story; a plausible incremental aid rather than a replacement); **Papercraft** and **ruby2html** (pure-Ruby templating; top the benchmark but niche, unresearched adoption); **Herb/ReActionView** (watch this — if it lands in Rails, "better ERB with validation" could be the primitive that matters, and it keeps view-path lookup).

**Performance, measured (same benchmark as §1):** Phlex 20,551 i/s > ViewComponent 18,445 > Rails Partials 14,946 > (CafeCar sits below partials, wrapping them). Source: [KonnorRogers/view-layer-benchmarks](https://github.com/KonnorRogers/view-layer-benchmarks). Every secondary source stresses DB/business logic is the real bottleneck; e.g. [ttb.software 2026-06-21](https://ttb.software/2026/06/21/rails-phlex-ruby-view-components-erb-viewcomponent/), [ivanturkovic.com 2025-11-26](https://www.ivanturkovic.com/2025/11/26/rails-templating-showdown-slim-vs-erb-vs-haml-vs-phlex-which-one-should-you-use/).

**Recency / uncertainty flags:** benchmark run date not stamped (numbers current-at-access); VC 4.0.0 and Phlex 2.0.0 exact release dates not pinned; adopters beyond GitHub/GitLab (Shopify/Gusto/Cookpad/Basecamp) unconfirmed; no download *trend* series available; DHH stance is opinion not a dated quote.

## 5. Paths forward

Five options, each scored on perf, override story, migration cost/risk, dependency/adoption risk, and fit with CafeCar's "convention layer above the primitive" positioning.

### Option A — Keep handrolled as-is
- **Perf:** slowest of the field, but immaterial at admin scale (§1).
- **Override:** ✅ best possible — file-drop partial shadow, zero config.
- **Migration:** none.
- **Dependency risk:** none — one fewer thing to track against Rails releases.
- **Positioning fit:** perfect — we *are* the convention layer; no config DSL, view/partial-configured.
- **Verdict:** the honest default. The suspicion that motivated this research (perf) doesn't survive the magnitude check. The real pain ("partials are a headache") is ergonomic/maintenance, not speed — and it's the same feature that powers overrides.

### Option B — Keep the Component API, re-back the *default emit* on Phlex
Replace `wrapper`/`content_tag` in `Component#to_html` with a Phlex-emitted default, **keeping `partial? ? render_partial : phlex_emit`** so the file-drop override branch is untouched.
- **Perf:** the `content_tag`-only components (the majority) get Phlex's faster buffer emit; partial-backed ones are unchanged.
- **Override:** ✅ preserved — partials remain the override seam; only the default render changes.
- **Migration:** moderate — rewrite the emit path in Phlex idiom, re-verify HTML/escaping parity against the whole test suite; risk of subtle attribute/escaping diffs.
- **Dependency risk:** adds Phlex (pure-Ruby, healthy, but a new runtime dep to track through Rails upgrades).
- **Positioning fit:** good — Phlex becomes the substrate *under* our layer, exactly the owner's "level above" thesis.
- **Verdict:** the interesting one, but only worth it if a benchmark on *our* workload shows the emit path matters. Speculative until measured.

### Option C — Re-back on ViewComponent
- **Perf:** modest gain over partials, slower than Phlex.
- **Override:** ❌ **degrades the core value prop** — VC can't do path-based template override; hosts would have to subclass. This fights CafeCar's whole "drop a file" story.
- **Migration:** high — VC's class+sidecar model is a poor fit for our dynamic child/flag machinery.
- **Verdict:** **rejected.** Loses the override ergonomic for a smaller perf win than Phlex.

### Option D — Hybrid: partials stay the override seam, Nice Partials + selective Phlex
Adopt **Nice Partials** to take the ergonomic sting out of partial locals (the actual "headache"), keep partials as the override mechanism, and optionally do Option B's Phlex emit for the hot `content_tag`-only components.
- **Perf:** same as B where applied.
- **Override:** ✅ preserved (Nice Partials uses the same view lookup).
- **Migration:** low-moderate, incremental.
- **Verdict:** the pragmatic middle if the owner's pain is *partial ergonomics* rather than raw speed. Cheapest way to address "partials are a headache" without touching the override story.

### Option E — Watch Herb/ReActionView, do nothing structural yet
Rails-core's own trajectory is better-tooled ERB with validation, keeping view-path lookup. If it lands, it could relieve the partial "headache" *and* preserve overrides natively.
- **Verdict:** not an action, a posture — bank Option A now, re-evaluate when Herb stabilizes.

### Recommendation

**Adopt Option A as the standing answer (keep handrolled + partials), and run the Option B spike to falsify the perf premise before committing to anything.** The override story — CafeCar's actual moat — is *best served by the partials we already use*, and every library move risks it. The perf concern, measured honestly, is real in direction but almost certainly immaterial at admin scale.

**Cheapest next experiment (de-risks B, ~1 day):**
1. Add `benchmark-ips` to the dev group and render a representative dummy-app admin index (`test/dummy` exists) N times; capture ms/request and object allocations. This gives us *our* numbers instead of a synthetic library benchmark — the missing measured fact.
2. Re-implement **one** component — `Button` (it's `content_tag`-only, no partial) — with a Phlex emit backend behind the unchanged `ui.Button` / `Button :danger` API, on a throwaway branch. Confirm: (a) the API survives, (b) HTML/escaping is byte-identical, (c) the render is measurably faster.
3. Decide from data: if the spike shows a real, meaningful win *and* clean API parity, expand to the other `content_tag`-only components (Option B). If it shows a sub-millisecond delta (likely), close it — Option A stands, and we've answered the owner's question with evidence instead of a hunch.

If the true pain is partial *ergonomics* (locals, indirection) rather than speed, do the Option D Nice Partials experiment instead — it targets the headache directly and keeps the override story intact.

---

## Sources

CafeCar code (this repo, read 2026-07-09):
- `lib/cafe_car/component.rb` — the primitive (`:10, :60-64, :77-99, :109-114, :126, :135-153`).
- `lib/cafe_car/context.rb`, `lib/cafe_car/helpers.rb` (`:4-17, :19-32, :270, :294-297`), `lib/cafe_car/resolver.rb` — dispatch & class resolution.
- `lib/cafe_car/controller.rb:53-56` — `append_view_path` (override seam).
- `app/ui/cafe_car/ui/*.rb` — component declarations; `app/views/ui/_*.html.haml` — the 4 partial-backed components.
- `skills/cafe_car/references/components.md`, `README.md`, `DECISIONS.md:149-176`.

External (all accessed 2026-07-10):
- ViewComponent: [github.com/ViewComponent/view_component](https://github.com/ViewComponent/view_component), [rubygems.org/gems/view_component](https://rubygems.org/gems/view_component), [CHANGELOG](https://viewcomponent.org/CHANGELOG.html), [issue #411 (override limitation)](https://github.com/ViewComponent/view_component/issues/411), [GitLab VC docs](https://docs.gitlab.com/development/fe_guide/view_component/).
- Phlex: [github.com/phlex-ruby/phlex](https://github.com/phlex-ruby/phlex), [rubygems.org/gems/phlex](https://rubygems.org/gems/phlex), [phlex.fun](https://www.phlex.fun/), [v2 upgrade](https://www.phlex.fun/miscellaneous/v2-upgrade), [Fly.io Ruby Dispatch: Phlex](https://fly.io/ruby-dispatch/component-driven-development-on-rails-with-phlex/), [shadcn_phlexcomponents](https://github.com/sean-yeoh/shadcn_phlexcomponents).
- Herb / ReActionView: [Introducing Herb](https://marcoroth.dev/posts/introducing-herb), [Rails World 2025 recap](https://marcoroth.dev/posts/rails-world-2025-recap), [herb-tools.dev](https://herb-tools.dev/overview).
- Benchmarks: [KonnorRogers/view-layer-benchmarks](https://github.com/KonnorRogers/view-layer-benchmarks), [ttb.software 2026-06-21](https://ttb.software/2026/06/21/rails-phlex-ruby-view-components-erb-viewcomponent/), [ivanturkovic.com 2025-11-26](https://www.ivanturkovic.com/2025/11/26/rails-templating-showdown-slim-vs-erb-vs-haml-vs-phlex-which-one-should-you-use/).
