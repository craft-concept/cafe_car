module CafeCar
  class LinkBuilder
    attr_reader :object

    delegate :link_to, :link_to_unless, :current_page?, to: :@template

    def initialize(template, object)
      @template = template
      @object   = object
    end

    def model      = @object.is_a?(Class) ? @object : @object.class
    def model_name = model.model_name
    def policy     = @template.policy(@object)

    def i18n(key, scope: nil, **opt)
      @template.t(key, scope: [:controls, *scope],
                  Model:  model_name.human,
                  Models: model_name.human(count: 2),
                  model:  model_name.human.downcase,
                  models: model_name.human(count: 2).downcase, **opt)
    end

    def confirm(key) = i18n(key, scope: :confirm)

    def disable(label, **opts)
      @template.tag.span(label, class: "disabled", disabled: true, **opts)
    end

    def index(text = i18n(:index), **opts)
      return "" unless policy.index?
      link_to(text, [model], **opts)
    end

    def new(text = i18n(:new), **opts)
      return "" unless policy.index?
      link_to(text, [model, action: :new], **opts)
    end

    def show(disabled: false, **opts)
      disabled ||= !policy.show? || current_page?([@object])
      link_to_unless(disabled, i18n(:show), [@object], **opts) { disable _1 }
    end

    def edit(disabled: false, **opts)
      disabled ||= !policy.edit? || current_page?([@object, action: :edit])
      link_to_unless(disabled, i18n(:edit), [@object, action: :edit], **opts) { disable _1 }
    end

    def destroy(disabled: false, **opts)
      disabled ||= !policy.destroy?
      link_to_unless(disabled, i18n(:destroy), [@object],
                     data: {turbo_method: :delete, turbo_confirm: confirm(:destroy)}, **opts) { disable _1 }
    end
  end
end
