module CafeCar::Visitors
  module SQLite
    def function(name, args, collector)
      collector << "#{name}("
      inject_join(args, collector, ", ") << ")"
    end

    def bool(value)
      value ? Arel::Nodes::True.new : Arel::Nodes::False.new
    end

    def visit_Arel_Nodes_Regexp(o, collector)
      function("regexp", [o.right, o.left, bool(o.case_sensitive)], collector)
    end

    def visit_Arel_Nodes_NotRegexp(o, collector)
      collector << "NOT "
      function("regexp", [o.right, o.left, bool(o.case_sensitive)], collector)
    end
  end
end
