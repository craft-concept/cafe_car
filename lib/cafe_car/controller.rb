module CafeCar
  module Controller
    extend ActiveSupport::Concern
    include CafeCar::UI::Controller

    class_methods do
      def model(model)
        define_method(:model) { @model ||= model }
      end
    end

    included do
      default_form_builder CafeCar::FormBuilder
      rescue_from ActiveRecord::RecordInvalid, with: :render_invalid_record
      define_callbacks :render, :update, :create, :destroy
      helper_method :model, :model_name, :record, :records, :plural?, :singular?

      # prepend_view_path CafeCar::Engine.root.join('app/views/cafe_car')
      # prepend_view_path 'app/views/cafe_car'
      before_action(only: %i[show edit update destroy]) { self.record = record! }
      before_action(only: %i[new create])               { self.record = model.new }
      before_action(if: :singular?) { authorize record }
      before_action :assign_attributes, only: %i[create update]
    end

    def index
      self.records = records.page(params[:page]).per(params[:per] || 100) if records.respond_to?(:page)
      self.records = filtered(records) if respond_to?(:filtered, true)
      self.records = paginated(records) if respond_to?(:paginated, true)
      self.records = sorted(records) if respond_to?(:sorted, true)
      self.records = records.includes(*includes) if respond_to?(:includes, true)

      authorize records
    end

    def show; end
    def new; end
    def edit; end

    def create
      run_callbacks(:create) { record.save! }

      respond_to do |f|
        f.js { created_js }
        f.html { created_redirect }
        f.json { }
      end
    end

    def update
      run_callbacks(:update) { record.save! }

      respond_to do |f|
        f.js { updated_js }
        f.html { updated_redirect }
        f.json { }
      end
    end

    def destroy
      run_callbacks(:destroy) { record.destroy }

      respond_to do |f|
        f.js { destroyed_js }
        f.html { destroyed_redirect }
        f.json { }
      end
    end

    private

    def assign_attributes = record.assign_attributes(permitted_attributes(record))

    def plural?   = action_name == "index"
    def singular? = not plural?

    def scope    = model
    def record!  = scope.find(params[:id])
    def records! = policy_scope(scope.all)

    def records
      instance_variable_get("@#{model_name.plural}") || (self.records = records!)
    end

    def records=(value)
      instance_variable_set("@#{model_name.plural}", value)
    end

    def record
      instance_variable_get("@#{model_name.singular}")
    end

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

    def created_js
      render 'create'
    rescue ActionView::MissingTemplate
      created_redirect
    end

    def updated_js
      render 'update'
    rescue ActionView::MissingTemplate
      updated_redirect
    end

    def destroyed_js
      render 'destroy'
    rescue ActionView::MissingTemplate
      destroyed_redirect
    end
  end

  def render_invalid_record = render record.persisted? ? 'edit' : 'new'

  def default_render(*args, **opts, &block)
    run_callbacks(:render) { super(*args, **opts, &block) }
  end
end
