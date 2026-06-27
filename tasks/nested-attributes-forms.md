---
id: nested-attributes-forms
title: Nested-attributes form rendering for has_many
priority: P2
status: wip
domain: Eng
created: '2026-06-26'
updated: '2026-06-26'
---

Implement first-class form rendering for `has_many` + `accepts_nested_attributes_for`
(repeatable nested fields with add/remove). Strengthens the "smart forms" value prop.

- **Reference:** the closed draft PR #11 (`copilot/fix-nested-fields-for-has-many`) had a
  reasonable approach — a `_nested_field.html.haml` partial using `fields_for` with a
  `<template>` for new records, vanilla-JS add/remove in `app/javascript/cafe_car.js`
  (handling `_destroy`), and reordering `FieldInfo#type` to try `nested_attributes_type`
  first. Closed because it was a stale, untested draft against a since-diverged main.
- Reimplement on current main **with tests** and a CHANGELOG entry.
- **Regression risk:** moving `nested_attributes_type` to the front of the `type`
  resolution chain changes detection priority for has_many — prove existing association
  rendering (e.g. belongs_to selects, plain has_many) is unaffected. `nested_attributes_type`
  must return nil unless `accepts_nested_attributes_for` is actually configured.
- Likely owner-visible product addition — fine to ship once tested, but flag in WORKLOG.
