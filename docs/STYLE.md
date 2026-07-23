# CafeCar Code Style

Normative for all Ruby in this repo. If you're contributing, this is the style
section of [CONTRIBUTING.md](../CONTRIBUTING.md) — read it before writing code,
and expect review to hold you to it.

Token-level style (double quotes, 2-space indent, guard clauses, hash-value
shorthand) is arbitrated by **rubocop-rails-omakase** — `bundle exec rubocop`
settles those arguments, not this file. This file is about *shape*: how features
are declared, where logic lives, and what idiom the codebase speaks.

Every example below is quoted from the codebase, with its file cited. When in
doubt, find the nearest neighbor and match it.

## 1. Roll everything into a class macro

A feature is *declared*, not written. A UI component is a handful of macro
calls with zero method bodies:

```ruby
# app/ui/cafe_car/ui/page.rb
component :Page do
  flag :slim
  option :title
  option :actions
  option :tabs

  component :Head, :Aside, :Body, :Foot
  component :Title, tag: :h2
  component :Actions
end
```

The machinery behind `flag` and `option` is written **once**, in the base class
(`lib/cafe_car/component.rb`). Note the `include Module.new` trick: generated
methods land in an included module, not the class itself, so a subclass can
override them and still call `super`:

```ruby
# lib/cafe_car/component.rb
def flag(flag)
  include Module.new do
    define_method(flag) { |v| @options[flag] = v.nil? ? true : v }
  end
end
```

Host-app boilerplate folds the same way — one macro wires rescue handlers,
responders, callbacks, and authorization for a whole controller
(`cafe_car(only:, model:)` in `lib/cafe_car/controller.rb`).

The rule of thumb: **the same wiring pattern written twice is the macro telling
you it wants to exist.**

## 2. Metaprogramming is a named vocabulary, then composed

Metaprogramming is welcome, but as small *named* primitives composed into
macros — never one clever `method_missing` that does everything. The
vocabulary in this repo:

- `define_class` — `const_set` + `Class.new` shorthand for macros
  (`lib/cafe_car/core_ext/module.rb`); it's how `component` mints each
  subclass (`lib/cafe_car/ui.rb`).
- `Resolver` — a concern that walks `const_scopes` so host-app constants
  shadow engine ones; `CafeCar[:Component]` is its lookup
  (`lib/cafe_car/resolver.rb`).
- Ancestry dispatch — a presenter is found by walking the object's class
  ancestry, so `AdminPresenter < Presenter` resolution falls out of Ruby's own
  ancestor chain:

```ruby
# app/presenters/cafe_car/presenter.rb
def self.find(klass)
  candidates(klass).filter_map { CafeCar[_1] }.first or raise "Could not find presenter"
end

def self.names(klass)
  return [ klass.to_s.classify ] if klass.is_a?(Symbol)
  klass.ancestors.lazy.map(&:name).compact
end
```

Each primitive is understandable alone; the magic is in the composition.

## 3. Endless methods, `.then` pipelines, Ruby 3 throughout

One expression gets an endless method — aligned into columns when neighbors
read as a table:

```ruby
# lib/cafe_car/component.rb
def name     = @names.last
def tag      = href? ? :a : super
def href?    = super && !context?(:a) && !current_href?
```

A pipeline is a `.then` chain (the Ruby `pipe`):

```ruby
# lib/cafe_car/controller.rb
def scope = filtered_scope.then { sorted _1 }
                          .then { eager_loaded _1 }
                          .then { paginated _1 }
```

Use the rest of Ruby 3 freely: pattern matching for dispatch
(`case [ r.macro, r.name ] in [ :belongs_to, * ] then r.foreign_key …`,
`lib/cafe_car/field_info.rb`), `Data.define` for value objects
(`SortKey = Data.define(:order, :join)`, `lib/cafe_car/model.rb`), anonymous
forwarding `(...)`, numbered params (`_1`), and guard clauses with `and`/`or`.

Bang methods mutate; the non-bang twin is pure or works on a clone. Aim for a
file under ~200 lines, one class per file, directories as namespaces.

## 4. Concerns, presenters, builders — not fat models or service objects

Logic lives in `ActiveSupport::Concern` modules, builder POROs
(`QueryBuilder`, `FormBuilder`, `ChartBuilder`, `Table::LabelBuilder`), and a
presenter hierarchy resolved by ancestry (rule 2). There are no service
objects, no interactors, no fat models.

Controllers stay thin enough to be endless:

```ruby
# lib/cafe_car/controller.rb
def index = respond_with objects
def show  = respond_with object
```

Haml views are pure component composition — markup calls components; it never
holds logic or styling of its own.

## 5. Examples over prose

Show, don't describe. A helper's doc comment is a runnable example with `#=>`
results:

```ruby
# lib/cafe_car/core_ext/hash.rb
# Removes and returns a hash containing the key/value pairs for which the
# block returns a true value given the key.
#
#   hash = {:a => 1, "b" => 2, :c => 3}
#   hash.extract_if! { _1.is_a? Symbol } #=> {a: 1, c: 3}
#   hash                                 #=> {"b" => 2 }
```

Comments stay short — a few lines of *rationale* (why, not what). If a method
needs a paragraph to explain what it does, reshape the method.

Be ActiveSupport-maximalist: reach for `extract!`, `compact_blank`,
`index_by`, `.then` before writing a loop. The standard library probably
already has the verb you need.

## 6. Gems earn their place

Adopt gems freely — but each one must **delete a subsystem**, not add a
convenience. The current roster (`cafe_car.gemspec`): Pundit (authorization),
Kaminari (pagination), Responders (respond_with), Turbo, Haml, Propshaft +
importmap-rails (no bundler, no Node build).

Small gaps in Ruby or Rails get a focused monkeypatch in
`lib/cafe_car/core_ext/` (`array.rb`, `hash.rb`, `module.rb`) — never a
grab-bag utility gem.

JavaScript stays unsettled on purpose: Turbo, delegated listeners, progressive
enhancement. No framework layer until one earns its place.

## 7. Testing: Minitest, never RSpec

Declarative `test "sentence" do` blocks, FactoryBot factories
(`test/dummy/factories.rb`), and assertions against the generated SQL rather
than round-tripping the database:

```ruby
# test/cafe_car/sorted_test.rb
test "belongs_to key orders by the associated table's column, with the join" do
  sorted = Invoice.sorted("client.name")
  assert_includes sorted.to_sql, %(LEFT OUTER JOIN "clients")
  assert_includes sorted.to_sql, %(ORDER BY "clients"."name" ASC)
end
```

Security behavior gets explicit *negative* assertions — prove the leak
doesn't happen, don't just prove the feature works:

```ruby
# test/controllers/searchable_association_options_test.rb
assert_not_includes values, hidden.id, "policy_scope must hide a row the user can't see"
```

Keep tests succinct: shared helpers over repeated setup, table-driven cases
where it saves lines. The suite should stay fast.

Before every push, run the full check suite — it's the rake default:

```bash
bundle exec rake   # rubocop + test + brakeman, all three must be green
```

"Green on my files" is not green — a single repo-wide RuboCop offense reds the
push.
