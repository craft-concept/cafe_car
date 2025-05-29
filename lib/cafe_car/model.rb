module CafeCar::Model
  extend ActiveSupport::Concern

  include CafeCar::Queryable
  include CafeCar::Informable

  class_methods do
    def sorted(*args)
      return all if args.compact_blank!.empty?
      args = args.flat_map { normalize_sort_key(_1) }
      reorder(*args)
    end

    def normalize_sort_key(key)
      case key
      when /,/
        key.split(',').map { normalize_sort_key _1 }
      when /^-(.+)$/ then {$1 => :desc}
      else key
      end
    end
  end
end
