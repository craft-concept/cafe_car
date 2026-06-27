# Awesome-list entries (ready to paste)

Two lists, two formats. Each entry is matched to the target list's exact
convention (verified against the live READMEs/CONTRIBUTING). Open **one PR per
list**, add **one link per PR**, and insert the line in the correct section in
**alphabetical order**.

---

## 1. Awesome Ruby

- **Repo to PR:** https://github.com/markets/awesome-ruby (edit `README.md`, branch `master`)
- **Section:** **Admin Interface** (where ActiveAdmin, Administrate, RailsAdmin live)
- **Format rule (from their CONTRIBUTING):** `[Library](url) - Description.`
  rendered as a `*` list item, ` - ` separator, description ends with a period.
  No badges, no star counts. Entries sorted alphabetically within the section.
- **Alphabetical placement:** after `Administrate`, before `RailsAdmin`.

**Paste this line:**

```
* [CafeCar](https://github.com/craft-concept/cafe_car) - Auto-generate CRUD admin UI for your Rails models, with sensible overridable defaults.
```

> ⚠️ **Gating risk — 30k download minimum.** Awesome Ruby's CONTRIBUTING enforces
> a quality bar: ~30k+ RubyGems downloads, actively maintained, documented, tested.
> CafeCar is a young gem and is very likely **below** that threshold today, so this
> PR may be deferred/rejected on the download count alone. **Recommendation:** hold
> the Awesome Ruby PR until downloads clear ~30k (the launch itself should help get
> there); submit the other three venues now. Check the current count on
> https://rubygems.org/gems/cafe_car before opening this PR.

---

## 2. Awesome Rails

- **Repo to PR:** https://github.com/gramantin/awesome-rails (edit `README.md`, branch `master`)
  — the most-starred, de-facto canonical "awesome-rails" list (no official Rails-team list exists).
- **Section:** **Gems** (where activeadmin, rails_admin, avo are listed; there is no dedicated Admin section).
- **Format:** `- [name](github_url) - Description. [:red_circle:](rubygems_url)`
  The trailing `:red_circle:` links to the RubyGems page (dominant convention; a
  few newer entries use literal `[rubygems](url)` instead).
- **No stated alphabetical/quality rules** — match the existing style by example.

**Paste this line:**

```
- [cafe_car](https://github.com/craft-concept/cafe_car) - A gem to auto-generate CRUD admin UI for your Rails models. [:red_circle:](https://rubygems.org/gems/cafe_car)
```

---

## Notes

- Both submissions are GitHub PRs and require the owner's GitHub account.
- Keep the descriptions verbatim with the gemspec summary so the messaging is
  consistent across every venue.
- Awesome Rails has the lower barrier — do it first. Awesome Ruby is the
  higher-value, higher-bar target; gate it on downloads (see warning above).
