require "responders"

module CafeCar
  module Controller
    extend ActiveSupport::Concern

    include Pundit::Authorization
    include Filtering

    class_methods do
      def model(model)
        define_method(:model) { @model ||= model }
      end

      def recline_in_the_cafe_car(only: nil, except: nil)
        _only = ->(actions) do
          actions -= except if except
          actions &= only if only
          actions
        end

        rescue_from ::ActiveRecord::RecordInvalid, with: :render_invalid_record

        append_cafe_car_views

        respond_to :json, :html, :turbo_stream

        before_action :set_current_attributes

        before_action :find_object,       only: _only.(%i[show edit update destroy])
        before_action :build_object,      only: _only.(%i[new create])
        before_action :find_objects,      only: _only.(%i[index])
        before_action :assign_attributes, only: _only.(%i[create update])
        before_action :authorize!
      end

      def append_cafe_car_views
        append_view_path CafeCar::Engine.root.join('app/views/cafe_car')
        append_view_path 'app/views/cafe_car'
      end
    end

    included do
      self.responder = CafeCar[:ApplicationResponder]
      default_form_builder CafeCar[:FormBuilder]

      define_callbacks :render, :update, :create, :destroy
      add_flash_types :success, :warning, :error

      helper_method :model, :model_name, :object, :objects
      helper_method :action, :scope

      helper Helpers
      delegate :present, :href_for, to: :helpers

      after_action :verify_authorized, :verify_policy_scoped
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

    private

    def authorize!
      return authorize object if object
      return authorize objects if objects
      raise "nothing to authorize! Define self.object or self.objects"
    end

    def flash!
      flash[:success] = present(object).i18n("#{action_name}_html", scope: :flashes)
    end

    def current_user = CafeCar[:Current].user

    def sorted(scope)
      scope.sorted(*params[:sort].presence)
    end

    def paginated(scope, page: params[:page], per: params[:per])
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
                           .then { paginated _1 }
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
      @model ||= self.class.name.gsub(/.*::|Controller$/, '')
                                .classify
                                .then { self.class.module_parent.const_get _1 }
    end

    def render_invalid_record = render(object.persisted? ? 'edit' : 'new', status: :unprocessable_content)

    # def default_render(...) = run_callbacks(:render) { super }

    def default_url_options
      {} # { locale: I18n.locale }
    end

    def action
      @action ||= ActiveSupport::StringInquirer.new(action_name)
    end

    def _render_with_renderer_json(obj, options)
      options[:only] ||= [:id] | policy(obj).displayable_attributes

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
