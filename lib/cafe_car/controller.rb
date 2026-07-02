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

      def default_view(v = @default_view || "table")
        @default_view = v.to_s
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

        before_action :find_object,       only: _only.(%i[show edit update destroy])
        before_action :build_object,      only: _only.(%i[new create])
        before_action :find_objects,      only: _only.(%i[index])
        before_action :assign_attributes, only: _only.(%i[create update])
        before_action :authorize!

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

    def sorted(scope)
      scope.sorted(*params[:sort].presence)
    end

    def paginated(scope, page: params[:page], per: params[:per])
      return scope if request.format.csv? # CSV exports the full filtered+sorted set
      scope.page(page).per(per)
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

    def scope   = model.all.then { policy_scope _1 }
                           .then { sorted _1 }
                           .then { filtered _1 }
                           .then { eager_loaded _1 }
                           .then { paginated _1 }

    # Preload the associations an index will render so a multi-row table costs a
    # bounded number of queries instead of one-per-row-per-association (N+1).
    def eager_loaded(scope) = scope.includes(*eager_loaded_associations)

    # The displayed belongs_to / has_many associations, each nested with the
    # attachment its preview renders (so the association's own avatar isn't a
    # second-order N+1). Intersecting with `displayable_associations` drops
    # polymorphic ones — which can't be naively `.includes`d — since it already
    # excludes them.
    def eager_loaded_associations
      policy = policy(model.new)
      (policy.displayable_attributes & policy.displayable_associations).map { with_preview(_1) }
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
      # permitted_attributes is record-oriented, so ask a record for the column
      # list even when serializing a collection.
      record = obj.is_a?(CafeCar::Model) ? obj : obj.klass.new
      options[:only] ||= [ :id ] | policy(record).displayable_attributes

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
