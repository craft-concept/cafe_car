# Rails should render something by default

Here is a thing Rails makes you do that it shouldn't.

You write a model. It has columns, validations, a couple of associations — a
complete description of a resource. Then, to *see* that resource in a browser,
you generate a controller and seven actions and a folder of view templates, most
of which are the same `<table>` and the same `<form>` you wrote on the last
project and will write again on the next one. The model already knows its
columns. The database already knows the types. Pundit already knows who's
allowed to do what. And yet the view layer sits there with its hands in its
pockets, rendering nothing, until you spell out every field by hand.

That's the gap [CafeCar](https://github.com/craft-concept/cafe_car) closes. It's
a composable view extension for Rails — an engine that extends the view and
controller layer so your models render *something* useful by default, and lets
you override any part of it when the default isn't what you want. Point it at your
models and you get a usable admin UI (and dashboards) without writing the views.

**Try it before you read another word:**
**[the live demo](https://cafe-car-demo.up.railway.app)** drops you
straight into a working admin for clients, invoices, articles, and users.
No signup. Click around, sort a column, filter a range, edit a record. Every
screen you see was rendered straight from ordinary models — nobody wrote those
views.

## One line, not one folder

Here's the whole integration for a resource:

```ruby
class Admin::ClientsController < ApplicationController
  cafe_car
end
```

That `cafe_car` macro gives you all seven RESTful actions, Pundit authorization
on every one of them, URL-based filtering and sorting, pagination, and
HTML/JSON/Turbo Stream responses. The model is inferred from the controller name;
override it with `model Company` if you need to. Want a read-only view? `cafe_car
only: [:index, :show]`.

Starting from scratch instead of bolting onto an existing model? The generator
scaffolds the whole resource:

```bash
$ rails generate cafe_car:resource Product name:string price:decimal description:text
```

That's a migration, a model, a controller with the macro, and a Pundit policy.
Run `rails db:migrate`, visit `/products`, and you have a working admin for
Products. The policy is where you say who can do what and which attributes are
editable — authorization and the form fields come from the same source of truth:

```ruby
class ProductPolicy < ApplicationPolicy
  def index?  = user.present?
  def update? = user.admin?

  def permitted_attributes = [:name, :price, :description, :category_id]
end
```

## Why not scaffolding, why not the heavyweight admins

Two tools already live in this space, and CafeCar exists because of what's
between them.

**Scaffolding** generates code you own — which sounds great until you realize
that's the problem. Scaffold output is throwaway by design: a pile of templates
you immediately start editing, duplicated per resource, drifting from each other
the moment you touch one. It doesn't *understand* your model; it stamps out a
snapshot and walks away. Change the model and the views don't follow.

**The heavyweight admin gems** go the other way. They're powerful, but they're a
second framework: a DSL to learn, a configuration layer that wants to own the
whole `/admin` namespace, and a fairly firm opinion about how your admin should
look and behave. Great when you live inside them; heavy when you just wanted your
models on a screen.

CafeCar sits in the middle, and the design rule is *sensible defaults, fully
overridable*. The defaults render from your models, so they track the model
instead of drifting from it. And when a default is wrong, you override exactly
that one piece — drop an `app/views/products/index.html.haml` to replace one
view, write a `ProductPresenter` to control how a record displays, define a
custom policy `Scope` to filter what each user sees. No DSL to adopt wholesale;
it's the Rails layers you already know, with the boilerplate removed.

## Pick your view primitive — CafeCar sits above it

Rails discourse this year keeps circling the same argument: ViewComponent, Phlex,
or plain partials, and whether partials are the wrong answer for 2026. CafeCar is
orthogonal to that fight. It's the convention layer *above* whichever primitive
you pick, and it composes with all three.

ViewComponent and Phlex answer "what's the unit of reuse for the UI I write?"
CafeCar answers a different question: "why hand-write the index, show, and form
views at all?" Different layers. CafeCar renders the boilerplate screens straight
from the model; you keep your ViewComponent or Phlex components for the screens
worth building by hand and drop them into a CafeCar view or presenter like any
other partial. Whatever you settled on for your view primitive, CafeCar deletes
the boilerplate views on top of it — you write only the ones that earn their keep.

## What it actually is

Being honest about the shape of it: the core — the controller macro that renders
CRUD straight from the model, the Pundit-backed authorization with attribute-level
permissions, the filtering and sorting DSL, the generators, and view overriding —
is the solid, well-exercised center of the gem. There's a type-aware presenter
system, a composable UI component layer, smart form building, and opt-in
email/password sessions layered on top. It targets Ruby 3.3+ and Rails 8. It's MIT
licensed and still pre-1.0, so expect some sharp edges and tell me about the ones
you hit.

The pitch isn't "replace your admin framework." It's smaller and more
opinionated than that: your models already contain enough information to render a
usable interface, so Rails should render one — and you should be able to change
your mind about any of it afterward.

- **Live demo:** https://cafe-car-demo.up.railway.app
- **Source:** https://github.com/craft-concept/cafe_car
- **Gem:** https://rubygems.org/gems/cafe_car

```ruby
gem "cafe_car"
```

Install it, point a controller at a model, and see what shows up.
