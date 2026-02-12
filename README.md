# CafeCar

CafeCar is a Rails engine that extends the MVC "view" layer to provide automatic CRUD UI generation with sensible defaults. Its philosophy is rooted in the idea that Rails should render _something_ that represents the CRUD operations of your models by default. These defaults can then be expanded or overridden on either an application-wide or model-specific basis.

**Perfect for**: Admin panels, internal tools, and rapid prototyping.

## Features

- 🚀 **Auto-generated CRUD interfaces** - One line of code generates complete index, show, new, edit views
- 🎨 **Component-based UI system** - Flexible, composable components for building interfaces
- 🔐 **Built-in authorization** - Pundit integration for attribute-level permissions
- 📊 **Smart presenters** - Automatic type-aware display of your data
- 🔍 **Advanced filtering** - Range queries, comparison operators, and association filters
- 📄 **Pagination & sorting** - Kaminari integration with sortable columns
- ⚡ **Hotwire ready** - Turbo Streams support out of the box
- 📝 **Intelligent forms** - Auto-generated forms with smart field detection

## Prerequisites

- Rails 7.0+
- Ruby 3.0+

## Installation

Add this line to your application's Gemfile:

```ruby
gem "cafe_car"
```

And then execute:

```bash
$ bundle install
```

Run the installer to set up CafeCar in your application:

```bash
$ rails generate cafe_car:install
```

This will:
- Add required dependencies (bcrypt, paper_trail, factory_bot_rails, faker, rouge)
- Mount the CafeCar engine at `/` under the `:admin` namespace
- Create `app/policies/application_policy.rb`
- Add `CafeCar::Controller` to your `ApplicationController`
- Set up JavaScript imports for Trix and ActionText

## Getting Started

### Quick Start: Generate a Complete Resource

The fastest way to get started is to generate a complete resource (model + controller + policy):

```bash
$ rails generate cafe_car:resource Product name:string price:decimal description:text
```

This creates:
- Migration and model (`app/models/product.rb`)
- Controller with CRUD actions (`app/controllers/products_controller.rb`)
- Policy with permission methods (`app/policies/product_policy.rb`)

Run migrations and start your server:

```bash
$ rails db:migrate
$ rails server
```

Navigate to `/products` and you'll see a fully functional CRUD interface!

### Manual Setup

You can also add CafeCar to existing resources:

#### 1. Add to Controller

```ruby
class ProductsController < ApplicationController
  recline_in_the_cafe_car
end
```

That single line provides:
- All 7 RESTful actions (index, show, new, create, edit, update, destroy)
- Automatic authorization via Pundit
- Filtering and sorting
- JSON/HTML/Turbo Stream responses
- Smart parameter handling

#### 2. Create a Policy

```ruby
# app/policies/product_policy.rb
class ProductPolicy < ApplicationPolicy
  def index?   = user.present?
  def show?    = user.present?
  def create?  = user.admin?
  def update?  = user.admin?
  def destroy? = user.admin?

  def permitted_attributes
    [:name, :price, :description, :category_id]
  end
end
```

The policy controls both authorization and which attributes can be edited.

## Core Components

### Controllers

The `CafeCar::Controller` module provides automatic CRUD functionality with the `recline_in_the_cafe_car` class method.

```ruby
class Admin::ClientsController < ApplicationController
  recline_in_the_cafe_car
end
```

**What you get:**

- **RESTful actions**: `index`, `show`, `new`, `edit`, `create`, `update`, `destroy`
- **Authorization**: Automatic `authorize!` before each action
- **Smart defaults**: Model detection from controller name
- **Callbacks**: Lifecycle hooks for `render`, `update`, `create`, `destroy`
- **Responders**: JSON, HTML, and Turbo Stream responses

**Limiting actions:**

```ruby
recline_in_the_cafe_car only: [:index, :show]
# or
recline_in_the_cafe_car except: [:destroy]
```

**Custom model:**

```ruby
class Admin::ClientsController < ApplicationController
  model Company  # Use Company model instead of Client
  recline_in_the_cafe_car
end
```

**Callbacks:**

```ruby
class ProductsController < ApplicationController
  recline_in_the_cafe_car
  
  set_callback :create, :after do |controller|
    NotificationMailer.product_created(controller.object).deliver_later
  end
end
```

### Policies

CafeCar extends Pundit with attribute-level permissions and auto-detection of displayable fields.

```ruby
class ClientPolicy < ApplicationPolicy
  def index?   = admin?
  def show?    = admin?
  def create?  = admin?
  def update?  = admin?
  def destroy? = update?

  def permitted_attributes
    [:name, :owner_id, :email, :phone]
  end

  class Scope < Scope
    def resolve
      admin? ? scope.all : scope.where(owner: user)
    end
  end
end
```

**Key methods:**

- `permitted_attributes` - Attributes that can be edited via forms
- `displayable_attributes` - Attributes shown in views (auto-detected from columns + associations)
- `displayable_associations` - Associations that can be displayed
- `filtered_attribute?(attr)` - Check if attribute should be hidden (uses Rails parameter filters)

**Scope pattern:**

The `Scope` class filters collections based on user permissions:

```ruby
class Scope < Scope
  def resolve
    admin? ? scope.all : scope.where(owner: user)
  end
end
```

### Presenters

Presenters convert model objects into view-ready representations with automatic type detection.

**Automatic usage** (in views):

```erb
<%= present(@product) %>
```

This automatically:
1. Finds the appropriate presenter for the object type
2. Checks policy permissions
3. Renders displayable attributes
4. Uses type-specific formatting

**Custom presenters:**

```ruby
# app/presenters/product_presenter.rb
class ProductPresenter < CafeCar::Presenter
  show :name
  show :price
  show :description
  show :category
  show :created_at
  
  # Custom display method
  def preview
    "#{name} - #{format_currency(price)}"
  end
  
  private
  
  def format_currency(amount)
    "$#{amount}"
  end
end
```

**Built-in presenters:**

- `RecordPresenter` - ActiveRecord models
- `DatePresenter`, `DateTimePresenter` - Dates and times
- `CurrencyPresenter` - Money values
- `RangePresenter` - Range objects
- `ActiveStorage::AttachmentPresenter` - File attachments
- `ActionText::RichTextPresenter` - Rich text content
- `EnumerablePresenter`, `HashPresenter` - Collections
- `NilClassPresenter` - Handles nil values gracefully

**Presenter methods:**

```ruby
presenter = present(@product)
presenter.show(:name)              # Display single attribute
presenter.attributes               # All displayable attributes
presenter.associations             # All displayable associations
presenter.to_html                  # Render to HTML
```

### UI Components

CafeCar provides a flexible component system for building interfaces.

**Basic usage:**

```ruby
# In views or helpers
ui.Card do
  ui.Field label: "Name" do
    @product.name
  end
end
```

**Available components:**

- `Page` - Page container with title and actions
- `Grid`, `Row` - Layout containers
- `Card` - Content cards
- `Table` - Data tables
- `Field` - Form fields with labels
- `Button` - Action buttons
- `Modal` - Modal dialogs
- `Alert` - Flash messages
- `Menu`, `Navigation` - Navigation elements

**Component options:**

```ruby
ui.Button "Save", class: "primary", type: "submit"
ui.Field label: "Email", required: true, hint: "We'll never share this"
ui.Card title: "Details", collapsed: false
```

**Custom components:**

Create partials in `app/views/cafe_car/ui/`:

```haml
-# app/views/cafe_car/ui/_badge.html.haml
%span.badge{ class: ui.classname }
  = yield
```

Use it:

```ruby
ui.Badge class: "success" do
  "Active"
end
```

### Forms

CafeCar provides an enhanced form builder with smart field detection.

**Basic forms:**

```erb
<%= form_with model: @product do |f| %>
  <%= f.input :name %>
  <%= f.input :price %>
  <%= f.input :description, as: :text %>
  <%= f.association :category %>
  <%= f.submit %>
<% end %>
```

**Smart field types:**

The form builder automatically detects field types:

- Password fields (columns named `password`, `password_confirmation`)
- File attachments (ActiveStorage `has_one_attached`, `has_many_attached`)
- Rich text (ActionText `has_rich_text`)
- Associations (belongs_to, has_many)
- Polymorphic associations
- Dates, datetimes, booleans, etc.

**Custom field rendering:**

```erb
<%= form_with model: @product do |f| %>
  <%= f.field(:price).label %>
  <%= f.field(:price).input class: "currency" %>
  <%= f.field(:price).hint "In USD" %>
  <%= f.field(:price).errors %>
<% end %>
```

**Association select:**

```erb
<%= f.association :category %>
```

Automatically creates a select dropdown with all categories.

### Filtering & Sorting

CafeCar provides advanced filtering with minimal configuration.

**URL-based filtering:**

```
/products?name=Widget&price.min=10&price.max=50&created_at=2024-01-01..2024-12-31
```

**Filter operators:**

- **Range queries**: `created_at=2024..2025-01-01`
- **Comparisons**: `price.min=10`, `price.max=50`
- **Greater than**: `price.gt=10` or `price=>10`
- **Less than**: `price.lt=50` or `price=<50`
- **Equals**: `status=active` or `status.eq=active`
- **Arrays**: `tags=red,blue,green`

**Sorting:**

```
/products?sort=name              # Ascending
/products?sort=-price            # Descending (note the minus)
/products?sort=category,-price   # Multiple columns
```

**In models:**

```ruby
class Product < ApplicationRecord
  include CafeCar::Model  # Auto-included via engine
end
```

The model gets:
- `sorted(*keys)` - Parse and apply sort parameters
- `normalized_sort_key()` - Convert sort keys to Arel format

**Custom filters in controllers:**

```ruby
class ProductsController < ApplicationController
  recline_in_the_cafe_car
  
  private
  
  def find_objects
    @objects = model.where(active: true)
                    .query(filter_params)
                    .sorted(sort_params)
                    .page(page_params)
  end
end
```

## Advanced Usage

### Customizing Views

Override default views by creating templates in your application:

```
app/views/
  products/
    index.html.haml    # Override index view
    show.html.haml     # Override show view
    _form.html.haml    # Override form partial
```

CafeCar's default views are in `app/views/cafe_car/application/` and serve as templates.

### Custom Responders

```ruby
class ProductsController < ApplicationController
  recline_in_the_cafe_car
  
  private
  
  def create
    super
    respond_with object, location: custom_path
  end
end
```

### Authorization Helpers

In controllers:

```ruby
authorize!                    # Authorize current action
policy(object).update?        # Check specific permission
policy(object).permitted_attributes  # Get editable attributes
```

In views:

```erb
<% if policy(@product).update? %>
  <%= link_to "Edit", edit_product_path(@product) %>
<% end %>
```

### Current Context

Access current request context anywhere:

```ruby
CafeCar::Current.user           # Current user
CafeCar::Current.request_id     # Request ID
CafeCar::Current.user_agent     # User agent string
CafeCar::Current.ip_address     # IP address
```

Set in controllers via `set_current_attributes` (automatically called by `recline_in_the_cafe_car`).

## Generators

### Resource Generator

Generate a complete resource (model + controller + policy):

```bash
$ rails generate cafe_car:resource Product name:string price:decimal
```

### Controller Generator

Generate just a controller:

```bash
$ rails generate cafe_car:controller Products
```

### Policy Generator

Generate just a policy:

```bash
$ rails generate cafe_car:policy Product
```

### Notes Generator

Add polymorphic audit trail notes to your app:

```bash
$ rails generate cafe_car:notes
```

Creates:
- Migration for notes table
- `Note` model
- `Notable` concern for trackable models

## Configuration

### Custom Form Builder

```ruby
# config/initializers/cafe_car.rb
module CafeCar
  class FormBuilder < ActionView::Helpers::FormBuilder
    # Your customizations
  end
end
```

### Custom Presenter

```ruby
# app/presenters/application_presenter.rb
class ApplicationPresenter < CafeCar::Presenter
  # Application-wide presenter customizations
end

# app/presenters/product_presenter.rb  
class ProductPresenter < ApplicationPresenter
  show :name
  show :price
end
```

### Custom Policy

```ruby
# app/policies/application_policy.rb
class ApplicationPolicy < CafeCar::ApplicationPolicy
  def admin?
    user&.admin?
  end
end
```

## Testing

CafeCar integrates with standard Rails testing tools:

```ruby
# test/controllers/products_controller_test.rb
class ProductsControllerTest < ActionDispatch::IntegrationTest
  test "index displays products" do
    get products_url
    assert_response :success
  end
  
  test "create with valid attributes" do
    assert_difference "Product.count", 1 do
      post products_url, params: { product: { name: "Widget" } }
    end
    assert_redirected_to product_path(Product.last)
  end
end
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
