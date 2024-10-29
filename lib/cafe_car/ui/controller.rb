module CafeCar
  module UI
    module Controller
      extend ActiveSupport::Concern

      included do
        helper_method :ui, :title, :ui_class, :partial?
      end

      private

      def partial?(name) = lookup_context.template_exists?(name, [], true)

      def ui_class(name, *args, **opts)
        name = [*name].map(&:to_s).map(&:camelize).join("_")
        args.flatten!
        args.compact_blank!
        opts.compact_blank!

        flags = args.extract! { _1.is_a? Symbol } | opts.extract! { _1.is_a? Symbol }.keys
        flags.map! { [*name, _1].join("-") }

        [*name, *flags, *args, *opts.keys].join(" ")
      end

      def ui
        @ui ||= UI::Context.new(helpers)
      end

      def title(title)
        @title = title
      end
    end
  end
end
