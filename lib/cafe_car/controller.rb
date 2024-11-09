module CafeCar
  module Controller
    extend ActiveSupport::Concern
    include Pundit::Authorization

    class_methods do
      def model(model)
        define_method(:model) { @model ||= model }
      end
    end

    included do
      default_form_builder FormBuilder
      rescue_from ::ActiveRecord::RecordInvalid, with: :render_invalid_record
      define_callbacks :render, :update, :create, :destroy
      helper_method :model, :model_name, :object, :objects, :record, :records, :plural?, :singular?
      helper_method :partial?

      helper Helpers

      # prepend_view_path CafeCar::Engine.root.join('app/views/cafe_car')
      # prepend_view_path 'app/views/cafe_car'

      after_action :verify_authorized

      before_action :set_current_attributes
      before_action(only: %i[show edit update destroy]) { self.record = record! }
      before_action(only: %i[new create])               { self.record = model.new }
      before_action(if: :singular?) { authorize object }
      before_action :assign_attributes, only: %i[create update]
    end

    def index
      self.records = records.page(params[:page]).per(params[:per]) if records.respond_to?(:page)
      self.records = filter(records) if respond_to?(:filter, true)
      self.records = sorted(records)
      self.records = records.includes(*includes) if respond_to?(:includes, true)

      authorize records
    end

    def show; end
    def new; end
    def edit; end

    def create
      run_callbacks(:create) { record.save! }

      respond_to do |f|
        f.html { created_redirect }
        f.json { }
      end
    end

    def update
      run_callbacks(:update) { record.save! }

      respond_to do |f|
        f.html { updated_redirect }
        f.json { }
      end
    end

    def destroy
      run_callbacks(:destroy) { record.destroy }

      respond_to do |f|
        f.html { destroyed_redirect }
        f.json { }
      end
    end

    private

    def current_user = CafeCar[:Current].user

    def sorted(scope)
      if scope.respond_to?(:sorted)
        scope.sorted(*params[:sort].presence)
      else scope
      end
    end

    def assign_attributes = record.assign_attributes(permitted_attributes(record))

    def plural?   = action_name == "index"
    def singular? = !plural?

    def scope    = model
    def record!  = scope.find(params[:id])
    def records! = policy_scope(scope.all)

    def objects = records
    def records = instance_variable_get("@#{model_name.plural}") || (self.records = records!)
    def records=(value)
      instance_variable_set("@#{model_name.plural}", value)
    end

    def object = record
    def record = instance_variable_get("@#{model_name.singular}")
    def record=(value)
      instance_variable_set("@#{model_name.singular}", value)
    end

    def model_name = model.model_name

    def model
      @model ||= self.class.name.gsub(/.*::|Controller$/, '').singularize.constantize
    end


    def created_redirect   = redirect_back fallback_location: [model_name.plural.to_sym]
    def destroyed_redirect = redirect_to [model_name.plural.to_sym]

    def updated_redirect
      return destroyed_redirect if record.destroyed?
      redirect_to record
    end

    def render_invalid_record = render(record.persisted? ? 'edit' : 'new')

    # def default_render(...) = run_callbacks(:render) { super }

    def default_url_options
      {} # { locale: I18n.locale }
    end

    def partial?(path)
      prefixes = path.include?(?/) ? [] : lookup_context.prefixes
      lookup_context.any?(path, prefixes, true)
    end

    def set_current_attributes
      CafeCar[:Current].request_id = request.uuid
      CafeCar[:Current].user_agent = request.user_agent
      CafeCar[:Current].ip_address = request.ip
    end
  end
end
