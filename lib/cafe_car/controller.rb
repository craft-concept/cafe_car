module CafeCar
  module Controller
    extend ActiveSupport::Concern

    class_methods do
      def model(model)
        define_method(:record_model) { @record_model ||= model }
      end
    end

    included do
      helper_method :record_model, :record_name, :records_name, :record, :records
      rescue_from ActiveRecord::RecordInvalid, with: :render_invalid_record
      prepend_view_path CafeCar::Engine.root.join('app/views/cafe_car')
      prepend_view_path 'app/views/cafe_car'
    end

    def index
      self.records = records.page(params[:page]).per(params[:per] || 100) if records.respond_to?(:page)
      self.records = filtered(records) if respond_to?(:filtered, true)
      self.records = paginated(records) if respond_to?(:paginated, true)
      self.records = sorted(records) if respond_to?(:sorted, true)
      self.records = records.includes(*includes) if respond_to?(:includes, true)

      authorize records
    end

    def show
      self.record = record!
      authorize record
    end

    def new
      self.record = new_record
      authorize record
    end

    def edit
      self.record = record!
      authorize record
    end

    def create
      self.record = new_record
      authorize record
      record.assign_attributes(permitted_attributes(record))

      record.save!
      created

      respond_to do |f|
        f.js { created_js }
        f.html { created_redirect }
        f.json { }
      end
    end

    def update
      self.record = record!
      authorize record

      record.update!(permitted_attributes(record))
      updated
      respond_to do |f|
        f.js { updated_js }
        f.html { updated_redirect }
        f.json { }
      end
    end

    def destroy
      self.record = record!
      authorize record

      destroy_record

      destroyed
      respond_to do |f|
        f.js { destroyed_js }
        f.html { destroyed_redirect }
        f.json { }
      end
    end

    def alter_tags
      self.record = record!
      authorize record
      # tag_list compares tags case-insensitively when adding, but not when removing
      remove      = [*params[:remove]].map {|t| record.tag_list.find {|t2| t.casecmp(t2).zero? } }
      tags        = record.tag_list.remove(*remove).add(*params[:add])
      if record.save
        render json: {tags:}
      else
        render json: {errors: record.errors.full_messages}, status: :bad_request
      end
    end

    private

    def new_record
      record_scope.new
    end

    def record!
      if record_model.respond_to?(:[])
        record_scope[params[:id]]
      else
        record_scope.find(params[:id])
      end
    end

    def record_scope
      record_model.all
    end

    def destroy_record
      record.destroy
    end

    def records!
      policy_scope(record_scope.all)
    end

    def records
      instance_variable_get("@#{records_name}") || (self.records = records!)
    end

    def records=(value)
      instance_variable_set("@#{records_name}", value)
    end

    def record
      instance_variable_get("@#{record_name}") || (self.record = record!)
    end

    def record=(value)
      instance_variable_set("@#{record_name}", value)
    end

    def record_model
      @record_model ||= self.class.name.gsub(/.*::|Controller$/, '').singularize.constantize
    end

    def record_name           = record_model.model_name.singular
    def records_name          = record_model.model_name.plural
    def render_invalid_record = render record.persisted? ? 'edit' : 'new'

    def created_redirect   = redirect_back fallback_location: [records_name.to_sym]
    def destroyed_redirect = redirect_to [records_name.to_sym]

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

    def created   = nil
    def updated   = nil
    def destroyed = nil
  end
end
