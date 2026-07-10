---
layout: default
title: Guide
permalink: /guide/
---

# CafeCar guide

The reference for working with CafeCar, page by page. Each page covers one layer —
the `cafe_car` macro, the override system, the policy, and the pieces around them —
with the code you'd actually write.

<!-- These pages are rendered from the single source at skills/cafe_car/references/
     by docs/bin/build-guide (a pages.yml build step). Don't edit them here — edit
     the source. See docs/bin/build-guide for the mechanism. -->

{% assign pages = site.pages | where_exp: "p", "p.guide_order" | sort: "guide_order" %}
<ul>
{% for p in pages %}
  <li><a href="{{ p.url | relative_url }}">{{ p.title }}</a></li>
{% endfor %}
</ul>

Reading the source directly? It lives at
[`skills/cafe_car/references/`](https://github.com/craft-concept/cafe_car/tree/main/skills/cafe_car/references) —
the same files an agent skill and GitMCP read. There is one copy.
