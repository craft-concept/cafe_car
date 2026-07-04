module CafeCar
  # Aggregates an index collection into time buckets for the index "chart" view.
  # Given a datetime/date column (the x-axis) and a granularity it GROUP BYs a
  # DB-portable truncation of that column and COUNTs each bucket, then renders an
  # inline SVG bar chart. The collection passed in is already policy-scoped and
  # filtered (it is the same relation the table view renders), so the chart never
  # counts rows the user can't see and always honors the active filters.
  class ChartBuilder
    # strftime patterns, shared by SQLite's `strftime` and Ruby's `Time#strftime`
    # so a bucket label is identical whichever adapter produced the key.
    FORMATS        = { day: "%Y-%m-%d", week: "%Y-%W", month: "%Y-%m" }.freeze
    DEFAULT_BUCKET = :month

    # SVG geometry (user units; the viewBox scales it to fit its container). WIDTH
    # and HEIGHT are FIXED so the chart keeps one landscape shape at ANY bucket
    # count. The CSS gives `.Chart` a full-width block with `height: auto`, so the
    # rendered height follows the viewBox aspect ratio — a column-per-bucket layout
    # made that viewBox near-square for a few buckets (rendered tall and narrow) and
    # very wide for many (rendered flat and short). Distributing the bars across a
    # fixed WIDTH instead holds a steady ~3.5:1 landscape that always fills the column.
    WIDTH      = 1000
    HEIGHT     = 280
    PAD_TOP    = 14  # room for the value label above the tallest bar
    PAD_BOTTOM = 22  # room for the x-axis (bucket) labels
    MAX_BAR    = 72  # cap bar width so a handful of buckets don't balloon
    BAR_RATIO  = 0.6 # bar width as a fraction of its slot

    delegate :tag, :safe_join, to: :@template

    def initialize(template, objects:, column: nil, bucket: nil)
      @template = template
      @objects  = objects
      @column   = pick_column(column)
      @bucket   = FORMATS.key?(bucket.to_s.to_sym) ? bucket.to_s.to_sym : DEFAULT_BUCKET
    end

    attr_reader :column, :bucket

    # The date/datetime columns offered as x-axis choices: the model's displayable
    # attributes (policy-respecting) whose type is a date. Column NAMES only reach
    # the query through this allowlist — a `?chart_x=` param outside it is dropped
    # by #pick_column, so a raw param can never be interpolated as a column name.
    def columns
      @columns ||= policy.displayable_attributes
                         .map    { info(_1) }
                         .select { _1.type.in?(%i[date datetime]) }
                         .map    { _1.method.to_s }
    end

    def column_options = columns.map { [ info(_1).label, _1 ] }
    def bucket_options = FORMATS.keys.map { [ _1.to_s.capitalize, _1.to_s ] }

    # Ordered `{ "2026-01" => count }` over the policy-scoped, filtered collection.
    def data = @data ||= aggregate

    def html_safe? = true
    def to_s       = svg.to_s
    def ~@         = @template.concat(to_s)

    private

    def aggregate
      return {} unless @column
      base.group(bucket_node).count
          .reject  { |bucket, _| bucket.nil? } # rows with a NULL x-axis value
          .transform_keys { label_for _1 }
          .sort.to_h
    end

    # The collection stripped of clauses that would corrupt a GROUP BY aggregate:
    # pagination (else only the current page counts), ordering (a non-grouped ORDER
    # BY column is invalid under GROUP BY on Postgres), and eager loading (its LEFT
    # JOINs could multiply counts). The WHERE — filters + policy scope — is kept.
    def base
      @objects.except(:limit, :offset, :includes, :eager_load, :preload).reorder(nil)
    end

    # DB-portable date truncation as an Arel function (no raw SQL string, so no
    # injection surface and Brakeman-clean). The granularity is a fixed keyword and
    # the column is allowlisted, so neither is attacker-controlled.
    def bucket_node
      col = @objects.arel_table[@column]
      if postgres?
        Arel::Nodes::NamedFunction.new("date_trunc", [ Arel::Nodes.build_quoted(@bucket.to_s), col ])
      else
        Arel::Nodes::NamedFunction.new("strftime", [ Arel::Nodes.build_quoted(FORMATS[@bucket]), col ])
      end
    end

    # SQLite's strftime already returns the formatted String; Postgres' date_trunc
    # returns a Time we format the same way, so both adapters key by the same label.
    def label_for(key) = key.is_a?(String) ? key : key.to_time.strftime(FORMATS[@bucket])

    def postgres? = @objects.klass.connection_db_config.adapter.match?(/postg/i)

    def pick_column(param)
      param = param.to_s
      return param if columns.include?(param)
      columns.include?("created_at") ? "created_at" : columns.first
    end

    def policy     = @template.policy(@objects)
    def info(name) = @objects.info.field(name)

    # --- SVG rendering ------------------------------------------------------

    def svg
      points = data
      max    = points.values.max || 0
      plot   = HEIGHT - PAD_TOP - PAD_BOTTOM
      slot   = points.empty? ? WIDTH : WIDTH.to_f / points.size
      bar_w  = [ slot * BAR_RATIO, MAX_BAR ].min

      tag.svg(class: "Chart", role: "img", "aria-label": aria_label,
              "viewBox": "0 0 #{WIDTH} #{HEIGHT}", preserveAspectRatio: "xMidYMid meet") do
        safe_join [ baseline, *bars(points, max, plot, slot, bar_w) ]
      end
    end

    def baseline
      y = HEIGHT - PAD_BOTTOM
      tag.line(class: "Chart-axis", x1: 0, y1: y, x2: WIDTH, y2: y,
               stroke: "currentColor", "stroke-opacity": "0.25")
    end

    def bars(points, max, plot, slot, bar_w)
      points.each_with_index.map do |(label, count), i|
        cx = slot * (i + 0.5)
        x  = cx - bar_w / 2
        h  = max.zero? ? 0 : (count.to_f / max * plot).round
        y  = HEIGHT - PAD_BOTTOM - h

        tag.g(class: "Chart-bar", "data-bucket": label, "data-count": count) do
          safe_join [
            tag.title("#{label}: #{count}"),
            tag.rect(x:, y:, width: bar_w, height: h, rx: 2, fill: "currentColor"),
            tag.text(count, x: cx, y: y - 4, class: "Chart-value", "text-anchor": "middle"),
            tag.text(label, x: cx, y: HEIGHT - PAD_BOTTOM + 15, class: "Chart-label", "text-anchor": "middle")
          ]
        end
      end
    end

    def aria_label
      "#{@objects.model_name.human(count: :all)} by #{info(@column).label}" if @column
    end
  end
end
