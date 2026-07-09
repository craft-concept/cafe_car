# Locales — all UI copy lives here

Source: `config/locales/en.yml` in the gem. Owner rule: **no hardcoded UI strings
in templates.** Every label, flash, confirm, hint, and button style resolves
through I18n; the gem ships defaults and a host overrides by defining the same key
in its own `config/locales/*.yml`.

When adding UI (a bulk action, a button in an overridden partial, a nav icon), add
its copy to the locale — don't inline the string.

## The key map

```yaml
en:
  # Action labels (bulk-action buttons, controls): en.<action>
  publish: Publish
  destroy: Delete

  # Bulk-action button styles — a Button flag per action name
  bulk_actions:
    styles:
      destroy: danger        # shipped default; add your own actions here

  # Sidebar icons (Iconoir names), per controller
  navigation:
    icon:
      products: box-iso

  # Control links (show/edit/delete clusters): labels, confirms, disabled tooltips
  controls:
    confirm:
      destroy: This %{Model} will be PERMANENTLY deleted. Are you sure?
    disabled:
      policy:
        default: You don't have permission to %{action} this %{model}.

  # Flash messages after CRUD actions
  flashes:
    create_html: "%{Model} created."
    update_html: "%{Model} updated."
    destroy_html: "%{Model} deleted."

  # Dashboard metric tile labels (non-:all metrics)
  metrics:
    published: Published

  # Per-field form copy: helpers.<kind>.<model>.<attribute>
  helpers:
    label:       { article: { title: Headline } }
    hint:        { article: { summary: Shown on the index card. } }
    placeholder: { article: { title: e.g. “Q3 results” } }
    prompt:      { invoice: { client_id: Pick a client… } }

  # Model & attribute names — standard Rails
  activerecord:
    models:
      article: Post
    attributes:
      article:
        title: Headline
```

Interpolations like `%{Model}`/`%{Models}`/`%{Action}` are provided (capitalized
and lowercase variants).

## Where they're read

- Bulk-action bar: label `en.<name>`, style `bulk_actions.styles.<name>`, confirm
  `helpers.bulk_confirm`.
- Form fields: `helpers.label/hint/placeholder/autocomplete/prompt.<model>.<attr>`
  (FieldInfo), falling back to `human_attribute_name`.
- Attribute/column headers everywhere: `activerecord.attributes`.
- Flashes: `flashes.<action>_html` via the presenter's `i18n`.
- Chart/dashboard strings: `chart.*`, `dashboard.*`.
