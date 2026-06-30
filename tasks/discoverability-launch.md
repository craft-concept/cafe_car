---
id: discoverability-launch
title: Discoverability — Awesome Rails, RubyFlow, launch post
priority: P2
status: open
blocked_on: user
domain: Marketing
created: 2026-06-26
---

## Passive levers DONE (2026-06-30, pass 41)

The discoverability work that needs **no owner accounts** is now shipped: the GitHub repo had zero
topics and an empty website. Set via `gh repo edit` — website → docs homepage
`https://craft-concept.github.io/cafe_car`, plus 12 topics (`rails ruby ruby-on-rails rails-engine
rails-gem admin admin-dashboard admin-panel backoffice crud scaffolding hotwire`). The repo now
surfaces on GitHub topic pages + search without any owner action. Only the **publish** step below
remains owner-gated.

## Prepared (2026-06-26)

All launch assets are drafted, committed, and ready under `marketing/` — nothing
has been published. Awaiting owner go-ahead (the publish step is owner-only;
every venue needs the owner's accounts/credentials and their name on the post).

Ready to fire:
- `marketing/launch-post.md` — ~850-word launch blog post. Angle: "Rails should
  render something by default." Killer `cafe_car` + `rails g cafe_car:resource`
  snippets, demo/repo/RubyGems links. Needs a host URL (owner decision).
- `marketing/awesome-list-entries.md` — paste-ready lines for **Awesome Ruby**
  (Admin Interface section) and **Awesome Rails** (Gems section), matched to each
  list's format. Flags Awesome Ruby's ~30k-download bar (gate that PR on downloads).
- `marketing/rubyflow-and-toolbox.md` — RubyFlow post (title+body) and Ruby
  Toolbox listing (auto-indexed; category PR to `rubytoolbox/catalog` →
  `rails_admin_interfaces.yml`).
- `marketing/SUBMISSION-CHECKLIST.md` — ordered owner action list (Ruby Toolbox,
  Awesome Rails/Ruby PRs, RubyFlow, Show HN, r/rails + r/ruby, Discord/Slack,
  X/Mastodon), each with URL, paste text, and which account it needs.

Owner decisions tracked in this task + surfaced by email (go-ahead, blog host, channels,
demo-spike OK). Status stays `open`, blocked on user for the publish step.

Roadmap item #6. Visibility is the other half of the mission. Sequence this AFTER ship +
trust (green CI, hygiene docs, working v1, live demo) so first impressions land well.

- Submit to the Awesome Ruby / Awesome Rails lists.
- List on Ruby Toolbox; post on RubyFlow.
- Write a launch blog post (the "Rails should render something by default" thesis is a
  strong hook) and share where Rails devs gather.
- Depends on [[docs-site-live-demo]] for the demo link to point at.
