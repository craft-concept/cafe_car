require "responders"

module CafeCar
  module Controller
    extend ActiveSupport::Concern

    include Pundit::Authorization
    include Filtering, Authentication

    class_methods do
      def model(model)
        define_method(:model) { @model ||= model }
      end

      # The index view (`table`/`grid`/`chart`) shown when no `?view=` is given.
      # `default_view :grid` sets it; a bare call reads the current value. Backed
      # by an inheritable class_attribute (`_default_view`) so a subclass keeps
      # its parent's setting — a bare class ivar would not carry across
      # subclassing.
      def default_view(view = nil)
        self._default_view = view.to_s if view
        _default_view
      end

      def cafe_car(only: nil, except: nil, model: nil)
        _only = ->(actions) do
          actions -= except if except
          actions &= only if only
          actions
        end

        self.model model if model

        rescue_from ::ActiveRecord::RecordInvalid,
                    ::ActiveModel::ValidationError, with: :render_invalid_object

        rescue_from ::Pundit::NotAuthorizedError, with: :render_unauthorized

        append_cafe_car_views

        respond_to :json, :html, :turbo_stream, :csv

        before_action :set_current_attributes

        before_action :find_object,       only: _only.(%i[show edit update destroy member_action])
        before_action :build_object,      only: _only.(%i[new create])
        before_action :find_objects,      only: _only.(%i[index])
        before_action :assign_attributes, only: _only.(%i[create update])
        # `batch`, `options` and the custom-action endpoints are excluded: each
        # authorizes on its own — `batch` per selected record (see #batch),
        # `options` via `index?` plus the policy scope on the typeahead feed
        # (see #options), `member_action`/`collection_action` via the named
        # action's own policy predicate.
        before_action :authorize!, except: %i[batch options member_action collection_action]

        after_action :verify_authorized, :verify_policy_scoped
      end

      def append_cafe_car_views
        append_view_path CafeCar::Engine.root.join("app/views/cafe_car")
        append_view_path "app/views/cafe_car"
      end

      def define_callbacks_with_helpers(*names, **)
        define_callbacks(*names, **)

        names.each do |name|
          %i[before around after].each do |kind|
            define_singleton_method "#{kind}_#{name}" do |*args, **opts|
              set_callback(name, kind, *args, prepend: true, **opts)
            end

            define_singleton_method "skip_#{kind}_#{name}" do |*args|
              skip_callback(name, kind, *args)
            end
          end
        end
      end
    end

    included do
      self.responder = CafeCar[:ApplicationResponder]
      default_form_builder CafeCar[:FormBuilder]

      # Inheritable backing for `default_view` (see the class method) — a
      # class_attribute carries the setting to subclasses; a bare class ivar
      # would not.
      class_attribute :_default_view, default: "table", instance_accessor: false

      define_callbacks_with_helpers :render, :update, :create, :destroy
      add_flash_types :success, :warning, :error

      helper_method :model, :model_name, :object, :objects
      helper_method :action, :scope, :view, :default_view

      helper Helpers
      delegate :present, :href_for, :namespace, to: :helpers
    end

    def index = respond_with objects
    def show  = respond_with object
    def new   = respond_with object
    def edit  = respond_with object

    def create
      run_callbacks(:create) { object.save! }
      respond_with object
    end

    def update
      run_callbacks(:update) { object.save! }
      respond_with object
    end

    def destroy
      run_callbacks(:destroy) { object.destroy! }
      respond_with object
    end

    # Apply a bulk action, named by `params[:bulk_action]`, to the selected records.
    # The action name is derived, not registered: the model policy's
    # `permitted_bulk_actions` is the whitelist (a name outside it is a bad request),
    # `name?` is the per-record authorization predicate, and `name!` the model bang
    # method applied. Every record is authorized ON ITS OWN — the candidate set is
    # first narrowed to the policy scope (rows the user may see), then each is checked
    # against `name?`; unauthorized rows are skipped, never bulk-bypassed. That
    # per-record check is the security boundary, so Pundit's blanket
    # `verify_authorized` is satisfied by `skip_authorization` after the fact.
    def batch
      skip_authorization # authorization is per-record below, not one blanket check
      action = permitted_bulk_action(params[:bulk_action])
      unless action
        skip_policy_scope # no candidate query on the reject path
        return head(:bad_request)
      end

      records = policy_scope(model).where(id: Array(params[:ids]))
      batched = records.select { |record| action_allowed?(record, action) }
      batched.each { |record| record.public_send("#{action}!") }

      redirect_to url_for(action: :index), success: batch_notice(action, batched.size)
    end

    # Run a policy-declared custom action on one record:
    # POST /<resources>/:id/actions/:member_action. The name resolves through the
    # model policy's `permitted_member_actions` whitelist (anything else is a
    # 404), its `name?` predicate authorizes, then — by convention — the record's
    # `name!` bang method runs. A host overrides the behavior by defining a
    # public controller method of the action's name; it takes over after
    # authorization and owns the response.
    def member_action
      skip_authorization # authorized via the action's own predicate below
      name = permitted_custom_action(params[:member_action], policy(object).attributes.actions.member)
      return head(:not_found) unless name

      authorize_action! object, name
      return public_send(name) if respond_to?(name)

      object.public_send("#{name}!")
      redirect_back_or_to href_for(object), success: action_notice(:member_action, name)
    end

    # Run a policy-declared custom action over the collection:
    # POST /<resources>/actions/:collection_action. Same derivation as
    # #member_action — `permitted_collection_actions` whitelists, `name?` (asked
    # of the model class) authorizes — then `name!` runs on the #filtered_scope,
    # which ActiveRecord delegates to a class method within that scoping. It runs
    # over the currently-viewed, filtered set (the button carries the active
    # filters, its label shows the count) — "Publish all" acts on exactly the
    # records the user is looking at. A host override (a public controller method
    # of the action's name) scopes its own query.
    def collection_action
      skip_authorization # authorized via the action's own predicate below
      name = permitted_custom_action(params[:collection_action], policy(model.new).attributes.actions.collection)
      unless name
        skip_policy_scope # no query on the reject path
        return head(:not_found)
      end

      authorize_action! model, name
      return public_send(name) if respond_to?(name)

      filtered_scope.public_send("#{name}!")
      redirect_to url_for(action: :index), success: action_notice(:collection_action, name)
    end

    # JSON typeahead feed for a searchable association select (Tom Select). Returns
    # `[{value, text}]` for the model, filtered by the `?q=` keyword search and
    # capped at `max_collection_options` — so an association field can reach records
    # PAST the render cap. Authorized twice: `index?` gates list access at all, and
    # `policy_scope` narrows rows to those the user may see (never leaking hidden ones).
    def options
      authorize model, :index?
      scope = policy_scope(model)
      scope = scope.query([ search_term ]) if search_term
      records = scope.limit(CafeCar.max_collection_options)
      render json: records.map { |record| { value: record.id, text: option_label(record) } }
    end

    def respond_with(*resources, **options, &block)
      super(*namespace, *resources, **options, &block)
    end

    private

    def authorize!
      return authorize object if object
      return authorize objects if objects
      raise "nothing to authorize! Define self.object or self.objects"
    end

    def flash!
      flash[:success] = present(object).i18n("#{action_name}_html", scope: :flashes)
    end

    def permitted_bulk_action(param)
      permitted_custom_action(param, policy(model.new).attributes.actions.bulk)
    end

    # The whitelisted action name matching `param` — a symbol drawn from the
    # given policy-declared list, or nil for a name outside it. #batch,
    # #member_action and #collection_action send `<name>!`/`<name>?`, so
    # resolving through the whitelist here means the derived method is always a
    # policy-declared name, never the raw request value (a bare param would be
    # a dynamic-send footgun).
    def permitted_custom_action(param, permitted)
      permitted.find { |a| a.to_s == param.to_s }
    end

    # Whether `subject` (a record, or the model class for collection actions)
    # grants `action` — its `action?` policy predicate. Guarded by `respond_to?`
    # so a permitted action without a predicate simply denies rather than erroring.
    def action_allowed?(subject, action)
      policy    = policy(subject)
      predicate = "#{action}?"
      policy.respond_to?(predicate) && policy.public_send(predicate)
    end

    # #action_allowed?, but raising: one denied custom action is a refusal
    # (rendered by render_unauthorized), not a skippable row like in #batch.
    def authorize_action!(subject, action)
      return if action_allowed?(subject, action)
      raise Pundit::NotAuthorizedError.new(query: "#{action}?", record: subject, policy: policy(subject))
    end

    # Success flash for a custom action, from the locale —
    # `flashes.member_action` / `flashes.collection_action`, interpolating the
    # action's label (`en.<name>`, humanized fallback) and the model name.
    def action_notice(kind, name)
      label = I18n.t(name, default: name.to_s.humanize)
      I18n.t(kind, scope: :flashes, action: label,
             model: model_name.human.downcase, models: model_name.human(count: 2).downcase)
    end

    def batch_notice(action, count)
      label = I18n.t(action, default: action.to_s.humanize)
      "#{label} #{count} #{model_name.human(count:).downcase}"
    end

    # Plain-text label for a typeahead option — the record's policy title attribute
    # (e.g. a user's name), falling back to its id. Kept scalar so the JSON feed
    # never serializes the HTML the presenter's #title emits.
    def option_label(record)
      attribute = policy(record).title_attribute
      record.public_send(attribute).to_s.presence || record.to_s
    end

    def sorted(scope)
      scope.sorted(*permitted_sort)
    end

    def paginated(scope, page: params[:page], per: params[:per])
      return scope if request.format.csv? # CSV exports the full filtered+sorted set
      scope.page(page).per(capped_per(per))
    end

    # Clamp `?per=` to `CafeCar.max_per_page` so an oversized request can't load an
    # unbounded table into memory. A blank `per` falls through to Kaminari's default.
    def capped_per(per)
      return per if per.blank?
      [ per.to_i, CafeCar.max_per_page ].min
    end

    def build_object
      self.object = scope.new
    end

    def find_object
      delimiter = model.param_delimiter
      id = unwrap params.extract_value(:id, delimiter:)
      self.object = scope.except(:limit, :offset).find(id)
    end

    def unwrap(arr) = arr.size == 1 ? arr.first : arr

    def find_objects
      self.objects = scope
    end

    def assign_attributes
      object.assign_attributes(permitted_attributes(object))
    end

    # Pundit permits attachment names as scalars, but a `has_many_attached`
    # field posts an array of uploads that a scalar permit silently drops — so
    # only one file (or none) would persist. Expand those keys to `{ name => [] }`
    # so every uploaded file survives strong-params.
    def permitted_attributes(record, action = action_name)
      policy = policy(record)
      method = "permitted_attributes_for_#{action}"
      method = "permitted_attributes" unless policy.respond_to?(method)
      multi  = multiple_attachments(record)
      keys   = policy.public_send(method).map { |k| multi.include?(k) ? { k => [] } : k }
      pundit_params_for(record).permit(*keys)
    end

    # Names of the record's `has_many_attached` attachments — the fields whose
    # form submits an array of files.
    def multiple_attachments(record)
      klass = record.is_a?(Class) ? record : record.class
      klass.try(:reflect_on_all_attachments)
           &.select { _1.macro == :has_many_attached }
           &.map    { _1.name.to_sym } || []
    end

    def scope   = filtered_scope.then { sorted _1 }
                                .then { eager_loaded _1 }
                                .then { paginated _1 }

    # Preload the associations an index will render so a multi-row table costs a
    # bounded number of queries instead of one-per-row-per-association (N+1).
    # With nothing to preload, `.includes` would raise on empty args — skip it.
    def eager_loaded(scope)
      eager_loaded_associations.then { _1.any? ? scope.includes(*_1) : scope }
    end

    # The displayed belongs_to / has_many associations, each nested with the
    # attachment its preview renders (so the association's own avatar isn't a
    # second-order N+1). Intersecting with `displayable_associations` drops
    # polymorphic ones — which can't be naively `.includes`d — since it already
    # excludes them.
    def eager_loaded_associations
      policy = policy(model.new)
      (policy.attributes.displayable & policy.displayable_associations).map { with_preview(_1) }
    end

    # `name`, or `{ name => { logo_attachment: :blob } }` when the associated
    # record's preview shows a logo attachment.
    def with_preview(name)
      klass      = model.reflect_on_association(name).klass
      logo       = policy(klass.new).logo_attribute
      attachment = logo && klass.reflect_on_attachment(logo)
      return name unless attachment

      plural = attachment.macro == :has_many_attached
      { name => { "#{logo}_attachment#{'s' if plural}": :blob } }
    end
    def objects = instance_variable_get("@#{model_name.plural}")
    def objects=(value)
      instance_variable_set("@#{model_name.plural}", value)
    end

    def object = instance_variable_get("@#{model_name.singular}")
    def object=(value)
      instance_variable_set("@#{model_name.singular}", value)
    end

    def model_name = model.model_name

    def model
      @model ||= self.class.name.gsub(/.*::|Controller$/, "")
                                .classify
                                .then { self.class.module_parent.const_get _1 }
    end

    def render_invalid_object
      render(object.persisted? ? "edit" : "new", status: :unprocessable_content)
    end

    def render_unauthorized
      if !sessions_available?
        head :forbidden
      elsif authenticated?
        redirect_back_or_to root_path
      else
        request_authentication
      end
    end

    # def default_render(...) = run_callbacks(:render) { super }

    def default_url_options
      {} # { locale: I18n.locale }
    end

    def action
      @action ||= ActiveSupport::StringInquirer.new(action_name)
    end

    def default_view = self.class.default_view
    def view
      params.fetch(:view) { default_view }
    end

    def _render_with_renderer_json(obj, options)
      # Plain payloads (e.g. the #options typeahead feed's [{value, text}] array)
      # aren't records — serialize them verbatim rather than deriving model columns.
      return super unless obj.is_a?(CafeCar::Model) || obj.respond_to?(:klass)

      # permitted_attributes is record-oriented, so ask a record for the column
      # list even when serializing a collection.
      record = obj.is_a?(CafeCar::Model) ? obj : obj.klass.new
      options[:only] ||= [ :id ] | policy(record).attributes.displayable

      if obj.is_a?(CafeCar::Model)
        options[:include] ||= policy(obj).displayable_associations
      end

      super obj, **options
    end

    def set_current_attributes
      CafeCar[:Current].request_id = request.uuid
      CafeCar[:Current].user_agent = request.user_agent
      CafeCar[:Current].ip_address = request.ip
    end
  end
end
