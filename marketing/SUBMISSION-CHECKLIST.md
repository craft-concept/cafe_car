# Launch submission checklist — owner actions

Everything here is an **external action only the owner can take** (your accounts,
your name on the post). All content is drafted in this `marketing/` directory —
this list is the order to fire it in, with the exact URL and what to paste.

**Nothing below has been done.** Drafting and format research are complete; no PRs
were opened, no posts submitted, no accounts created.

---

## Step 0 — Prerequisites (do these first)

- [ ] **Decide go/no-go** and answer the four questions in `QUESTIONS.md`
      (go-ahead, blog host, channels, demo-spike OK). The whole launch is blocked on (a).
- [ ] **Host the blog post.** `marketing/launch-post.md` needs a canonical URL before
      anything can link to it. Publish it on your blog / Medium / dev.to. **Account: your
      blog platform.** → This URL is referenced as `BLOG_URL` everywhere below.
- [ ] **Sanity-check the live demo** can take a traffic spike:
      https://cafe-car-demo-production.up.railway.app (and that the periodic data reset is
      fine for public eyes).
- [ ] **Confirm RubyGems page** looks right (description, links, latest version):
      https://rubygems.org/gems/cafe_car

---

## Step 1 — Ruby Toolbox category PR (no traffic, do anytime)

- [ ] Open a PR adding `cafe_car` to the `projects:` list, alphabetically.
      - **Repo:** https://github.com/rubytoolbox/catalog
      - **File:** `catalog/Rails_Plugins/rails_admin_interfaces.yml`
      - **Paste:** `  - cafe_car` (match indentation; see `rubyflow-and-toolbox.md`)
      - **Account:** GitHub.
- [ ] (The gem itself auto-indexes from RubyGems — nothing to submit for the listing.)

## Step 2 — Awesome Rails PR

- [ ] Open a PR adding CafeCar to the **Gems** section.
      - **Repo:** https://github.com/gramantin/awesome-rails (`README.md`)
      - **Paste:** `- [cafe_car](https://github.com/craft-concept/cafe_car) - A gem to auto-generate CRUD admin UI for your Rails models. [:red_circle:](https://rubygems.org/gems/cafe_car)`
      - **Account:** GitHub. One link per PR.

## Step 3 — Awesome Ruby PR (GATED — check downloads first)

- [ ] **Check RubyGems download count** at https://rubygems.org/gems/cafe_car.
      Awesome Ruby enforces a **~30k-download minimum**. If CafeCar is below it,
      **skip this step for now** and revisit after the launch lifts downloads.
- [ ] If eligible: open a PR adding CafeCar to the **Admin Interface** section,
      alphabetically (after `Administrate`, before `RailsAdmin`).
      - **Repo:** https://github.com/markets/awesome-ruby (`README.md`)
      - **Paste:** `* [CafeCar](https://github.com/craft-concept/cafe_car) - Auto-generate CRUD admin UI for your Rails models, with sensible overridable defaults.`
      - **Account:** GitHub. One link per PR; follow their CONTRIBUTING.

## Step 4 — RubyFlow post

- [ ] Submit via the **"Submit a post"** form on https://rubyflow.com/ (homepage, `#submitform`).
      - **Account:** GitHub OAuth (you'll sign in/up through GitHub).
      - **Title + body:** see `marketing/rubyflow-and-toolbox.md` (lead paragraph + inline demo/repo links).

## Step 5 — Hacker News "Show HN"

- [ ] Submit at https://news.ycombinator.com/submit
      - **Account:** Hacker News (yours).
      - **Title:** `Show HN: CafeCar – Rails should render a CRUD admin from your models by default`
      - **URL field:** `BLOG_URL` (the launch post) — or the GitHub repo if you'd rather.
      - **First comment (post immediately after):** a short, honest note — what it is,
        the one-line `cafe_car` snippet, the live demo link, that it's pre-1.0, and that
        you're the author and happy to answer questions. (Adapt the intro of `launch-post.md`.)
      - Tip: post in the morning ET on a weekday; don't ask for upvotes.

## Step 6 — Reddit

- [ ] **r/rails** — https://www.reddit.com/r/rails/submit
      - Title: `CafeCar: auto-generate a CRUD admin UI from your Rails models (one line, fully overridable)`
      - Body: 2-3 sentences from the launch post + **demo link** + repo link + `BLOG_URL`.
      - **Account:** Reddit (yours). Check subreddit self-promo rules / flair.
- [ ] **r/ruby** — https://www.reddit.com/r/ruby/submit (same content; r/ruby is stricter on
      self-promo, so lead with the technical thesis, not the pitch).

## Step 7 — Chat communities

- [ ] **Ruby Discord** — share in the relevant show-and-tell / gems channel.
      https://discord.gg/ruby (**account: Discord**). Read channel rules first.
- [ ] **Ruby/Rails Slack** (if you're a member of one, e.g. a regional or rubyonrails Slack) —
      post in a #gems / #showcase channel. **Account: that Slack.**
- [ ] Short message for both: one line + demo link + repo link.

## Step 8 — Social

- [ ] **X/Twitter** and/or **Mastodon (ruby.social)** — short thread:
      hook ("Rails should render something by default"), the `cafe_car` one-liner,
      the demo GIF/link, repo + `BLOG_URL`. **Accounts: yours.** Tag #RubyOnRails #Ruby.

---

## Accounts you'll need (all owner-held)

| Action | Account |
|---|---|
| Blog post host | your blog / Medium / dev.to |
| Awesome Ruby / Awesome Rails / Ruby Toolbox PRs | GitHub |
| RubyFlow | GitHub (OAuth) |
| Hacker News | Hacker News |
| Reddit (r/rails, r/ruby) | Reddit |
| Ruby Discord / Slack | Discord / Slack |
| X / Mastodon | X / Mastodon |

## Suggested order & timing

Land the low-traffic, evergreen listings first (Ruby Toolbox, Awesome Rails), then
do the timed burst (Show HN in the morning, then Reddit, RubyFlow, chat, social on
the same day) so the demo and repo see attention while they're fresh. Awesome Ruby
is gated on downloads — circle back to it after the launch.
