module CafeCar
  # A host-declared dashboard: an ordered list of widgets composed in an
  # initializer via `CafeCar.dashboard { ... }`. The block is evaluated against a
  # Dashboard instance, so `#metric` and `#chart` read as a declarative DSL and
  # each appends a widget. Nothing is declared by default — an empty dashboard
  # mounts no route (opt-in, off by default).
  #
  #   CafeCar.dashboard do
  #     metric "Users",         -> { User.count }
  #     metric "Signups today", -> { User.where(created_at: Date.current.all_day).count }
  #     chart  "New users", model: User, x: :created_at, by: :month
  #   end
  class Dashboard
    # A metric tile: a label over a number produced by a host-supplied callable.
    # The callable is trusted config (the host wrote it), evaluated at render time.
    Metric = Struct.new(:label, :value, keyword_init: true) do
      def type = :metric
      def call = value.call
    end

    # A chart widget: a title over an inline SVG bar chart of record counts bucketed
    # by a date column. It reuses ChartBuilder, so `x` is validated against the
    # model's date-column allowlist and truncated via portable Arel — a bad column
    # name can never reach SQL. `by` is the granularity (:day/:week/:month).
    Chart = Struct.new(:title, :model, :x, :by, keyword_init: true) do
      def type = :chart
      # The unpaginated relation ChartBuilder aggregates (it strips ordering/limits).
      def objects = model.all
    end

    attr_reader :widgets

    def initialize
      @widgets = []
    end

    def metric(label, value)
      @widgets << Metric.new(label:, value:)
    end

    def chart(title, model:, x:, by: nil)
      @widgets << Chart.new(title:, model:, x:, by:)
    end

    def any? = @widgets.any?
  end
end
