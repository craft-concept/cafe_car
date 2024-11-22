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

        prepend_cafe_car_views

        before_action :set_current_attributes

        before_action :find_object,       only: _only.(%i[show edit update destroy])
        before_action :build_object,      only: _only.(%i[new create])
        before_action :find_objects,      only: _only.(%i[index])
        before_action :assign_attributes, only: _only.(%i[create update])
        before_action :authorize!
      end

      def prepend_cafe_car_views
        prepend_view_path CafeCar::Engine.root.join('app/views/cafe_car')
        prepend_view_path 'app/views/cafe_car'
      end
    end

    included do
      default_form_builder CafeCar[:FormBuilder]

      define_callbacks :render, :update, :create, :destroy

      helper_method :model, :model_name, :object, :objects
      helper_method :action, :scope

      helper Helpers

      after_action :verify_authorized, :verify_policy_scoped
    end

    def index = nil
    def show  = nil
    def new   = nil
    def edit  = nil

    def create
      run_callbacks(:create) { object.save! }

      respond_to do |f|
        f.html { created_redirect }
        f.json { }
      end
    end

    def update
      run_callbacks(:update) { object.save! }
    end

    def destroy
      run_callbacks(:destroy) { object.destroy }

      respond_to do |f|
        f.html { destroyed_redirect }
        f.json { }
      end
    end

    private

    def authorize!
      return authorize object if object
      return authorize objects if objects
      raise "nothing to authorize! Define self.object or self.objects"
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
      self.object = scope.except(:limit, :offset).find(params[:id])
    end

    def find_objects
      self.objects = scope
    end

    def assign_attributes
      object.assign_attributes(permitted_attributes(object))
    end

    def scope   = policy_scope(model.all).then { sorted _1 }
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
      @model ||= self.class.name.gsub(/.*::|Controller$/, '').singularize.constantize
    end


    def created_redirect   = redirect_back fallback_location: [model_name.plural.to_sym]
    def destroyed_redirect = redirect_to [model_name.plural.to_sym]

    def updated_redirect
      return destroyed_redirect if object.destroyed?
      redirect_to object
    end

    def render_invalid_record = render(object.persisted? ? 'edit' : 'new')

    # def default_render(...) = run_callbacks(:render) { super }

    def default_url_options
      {} # { locale: I18n.locale }
    end

    def action
      @action ||= ActiveSupport::StringInquirer.new(action_name)
    end

    def set_current_attributes
      CafeCar[:Current].request_id = request.uuid
      CafeCar[:Current].user_agent = request.user_agent
      CafeCar[:Current].ip_address = request.ip
    end
  end
end
