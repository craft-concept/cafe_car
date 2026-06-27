---
layout: default
---

# CafeCar

[![CI](https://img.shields.io/github/actions/workflow/status/craft-concept/cafe_car/ci.yml?branch=main&label=CI)](https://github.com/craft-concept/cafe_car/actions/workflows/ci.yml)
[![Gem Version](https://img.shields.io/gem/v/cafe_car)](https://rubygems.org/gems/cafe_car)
[![License: MIT](https://img.shields.io/badge/license-MIT-green)](https://opensource.org/licenses/MIT)

> 🚀 **[Live demo →](https://cafe-car-demo-production.up.railway.app)** — click straight
> into a real auto-generated admin (clients, invoices, articles, users, notes). No signup;
> the data resets periodically.

**CafeCar is a Rails engine that auto-generates CRUD admin UI from your models** —
complete index, show, new, and edit interfaces with no boilerplate. Sensible defaults
cover authorization, presenters, filtering, sorting, pagination, and Hotwire-ready forms,
and every default can be overridden application-wide or per model.

**Perfect for** admin panels, internal tools, and rapid prototyping.

## Install

```ruby
# Gemfile
gem "cafe_car"
```

```bash
$ bundle install
$ rails generate cafe_car:install
```

## One line to a full CRUD interface

```ruby
class ProductsController < ApplicationController
  cafe_car
end
```

That single line gives you all seven RESTful actions, Pundit authorization, filtering,
sorting, pagination, and JSON / HTML / Turbo Stream responses. Or scaffold a complete
resource at once:

```bash
$ rails generate cafe_car:resource Product name:string price:decimal description:text
```

## Learn more

- **[README & full usage guide](https://github.com/craft-concept/cafe_car#readme)** — controllers, policies, presenters, components, forms, filtering.
- **[Changelog](https://github.com/craft-concept/cafe_car/blob/main/CHANGELOG.md)**
- **[Contributing](https://github.com/craft-concept/cafe_car/blob/main/CONTRIBUTING.md)** · **[Security policy](https://github.com/craft-concept/cafe_car/blob/main/SECURITY.md)**
- **[Source on GitHub](https://github.com/craft-concept/cafe_car)**

---

<small>Released under the [MIT License](https://opensource.org/licenses/MIT).</small>
