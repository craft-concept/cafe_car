module CafeCar
  class LinkBuilder
    attr_reader :object

    delegate :link_to, :link_to_unless, :current_page?, :href_for, to: :@template

    def initialize(template, object)
      @template = template
      @object   = object
    end

    def model      = @object.is_a?(Class) ? @object : @object.class
    def model_name = model.model_name
    def policy     = @template.policy(@object)
    def var(names) = names.merge! *names.map { {_1.to_s.downcase.intern => _2.downcase} }

    def i18n(action, scope: nil, default: :default, **opt)
      @template.t action, scope: [:controls, *scope], default:,
                  **var(
                    Action: @template.t(action, default: action.to_s.humanize),
                    Model:  model_name.human,
                    Models: model_name.human(count: 2),
                  ),
                  **opt
    end

    def confirm(key)             = i18n(key, scope: :confirm)
    def disabled(action, reason) = i18n(action, scope: [:disabled, reason])

    def turbo(opts)
      {data: opts.delete(:data) { {} }.with_defaults(
        turbo_stream: true,
        turbo_method: opts.delete(:method),
        turbo_confirm: opts.delete(:confirm),
      )}
    end

    def link(action, target, label = i18n(action), disabled: false, hide: false, **opts)
      href       = href_for(*target, action:)
      disabled ||= !policy.public_send("#{action}?") && disabled(action, :policy)
      return "" if disabled and hide
      disabled ||= current_page?(href) && ""
      link_to_unless(disabled, label, href, **turbo(opts), **opts) do
        @template.tag.span(label, class: "disabled", disabled: true, title: disabled)
      end
    end

    def show(...)      = link(:show, @object, ...)
    def edit(...)      = link(:edit, @object, ...)
    def destroy(*, **) = link(:destroy, @object, *, method: :delete, confirm: confirm(:destroy), **)
    def index(*, **)   = link(:index, model, *, hide: true, **)
    def new(*, **)     = link(:new, model, *, hide: true, **)
  end
end
