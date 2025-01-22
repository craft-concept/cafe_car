module CafeCar
  class LinkBuilder
    attr_reader :object

    delegate :link_to, :link_to_unless, :current_page?, :href_for, to: :@template

    def initialize(template, object, namespace: template.namespace)
      @template  = template
      @object    = object
      @namespace = namespace
    end

    def model         = @object.is_a?(Class) ? @object : @object.class
    def model_name    = model.model_name
    def policy        = @template.policy(@object)
    def var(names)    = names.merge! *names.map { {_1.to_s.downcase.intern => _2.downcase} }
    def can?(action)  = policy.public_send("#{action}?")
    def cant?(action) = !can?(action) && disabled(action, :policy)

    def i18n(action, scope: nil, default: :default, **)
      vars = var Action: @template.t(action, default: action.to_s.humanize),
                 Model:  model_name.human,
                 Models: model_name.human(count: 2)
      @template.t(action, scope: [:controls, *scope], default:, **vars, **)
    end

    def confirm(key)             = i18n(key, scope: :confirm)
    def disabled(action, reason) = i18n(action, scope: [:disabled, reason])

    def turbo!(opts)
      opts.replace({
        data: {turbo_stream:  true,
               turbo_method:  opts.delete(:method),
               turbo_confirm: opts.delete(:confirm)
        }
      }.deep_merge(opts))
    end

    def link(action, target, label = i18n(action), disabled: false, hide: false, **opts)
      disabled ||= cant?(action)
      return "" if disabled and hide

      href    = href_for(*target, action:, namespace: @namespace)
      current = current_page?(href)

      link_to_unless(disabled || current, label, href, **turbo!(opts)) do
        @template.tag.span(label, class: "disabled", disabled: true, title: disabled)
      end
    end

    def show(...)      = link(:show, @object, ...)
    def edit(*, **)    = link(:edit, @object, *, **)
    def destroy(*, **) = link(:destroy, @object, *, method: :delete, confirm: confirm(:destroy), **)
    def index(*, **)   = link(:index, model, *, hide: true, **)
    def new(*, **)     = link(:new, model, *, hide: true, **)

    def code(path = nil)
      return unless Rails.env.development?
      return unless @template.request.local?
      path ||= caller_locations(1, 1).first.path

      link_to "✎", "rubymine://open?file=#{path}" # &line=%{line}
    end
  end
end
