# RubyFlow post + Ruby Toolbox listing

Two more discoverability venues. Neither is a code change; both put CafeCar in
front of Ruby devs who browse for gems.

---

## RubyFlow (community link blog)

- **Where:** https://rubyflow.com/ — use the **"Submit a post"** link on the
  homepage (in-page form, anchor `#submitform`; there is no separate `/submit` path).
- **Account:** **Yes — GitHub OAuth.** You'll be sent through GitHub to sign in /
  sign up. No GitHub account, no post.
- **Format:** a title plus one body field (Markdown or basic HTML, with live
  preview). **Only the first paragraph shows on the front page**, so lead with the
  hook and put the link inline. Posts may be lightly edited to fit the site.

**Title:**

```
CafeCar — auto-generate a CRUD admin UI for your Rails models
```

**Body (paste as-is):**

```
CafeCar is a Rails engine that auto-generates a CRUD admin UI straight from your
models — one line in a controller gives you index/show/new/edit with Pundit
authorization, filtering, sorting, and pagination, all overridable. The thesis:
Rails should render *something* from your models by default. Try the live demo
(no signup): https://cafe-car-demo-production.up.railway.app — source at
https://github.com/craft-concept/cafe_car
```

Keep it to that one paragraph; RubyFlow truncates the rest on the front page.

---

## Ruby Toolbox (gem catalog / comparison site)

- **The gem auto-appears.** Ruby Toolbox indexes every gem published on
  RubyGems.org, so `cafe_car` is (or will be) indexed automatically at
  https://www.ruby-toolbox.com/ — **no submission needed for the listing itself.**
- **But it won't have a category** until someone adds it. Categorization is manual,
  via a GitHub PR to the catalog repo.

**To put CafeCar in the right category:**

- **Repo to PR:** https://github.com/rubytoolbox/catalog
- **File:** `catalog/Rails_Plugins/rails_admin_interfaces.yml`
- **Category:** **Rails Admin Interfaces**
  (https://www.ruby-toolbox.com/categories/rails_admin_interfaces — alongside
  activeadmin, rails_admin, administrate, avo, trestle).
- **How:** add `cafe_car` to the `projects:` array, **alphabetically** (the list
  is sorted; `cafe_car` goes among the `c` entries). The file is validated against
  a JSON schema at build time, so match the existing indentation exactly.

**The line to add** (under `projects:`, alphabetically placed):

```yaml
  - cafe_car
```

For context, the file looks like:

```yaml
name: "Rails Admin Interfaces"
projects:
  - ab_admin
  - active_scaffold
  - activeadmin
  # ...
  - cafe_car        # <- add here, in alphabetical position
  # ...
```

- **Account:** GitHub (it's a PR).
- **Catalog rules:** categories need ≥2 entries (already satisfied); for a single
  add like this, a small PR is fine — no discussion issue needed.

---

## Summary

| Venue | Action | Account | Effort |
|---|---|---|---|
| RubyFlow | Submit post via homepage form | GitHub OAuth | 2 min, paste title+body above |
| Ruby Toolbox (listing) | Nothing — auto-indexed from RubyGems | none | automatic |
| Ruby Toolbox (category) | PR adding `cafe_car` to `rails_admin_interfaces.yml` | GitHub | 5 min |
