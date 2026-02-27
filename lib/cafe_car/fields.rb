module CafeCar
  class Fields < Array
    include Caching

    derive :editable,    -> { Fields.new reject(&:constant?) }
    derive :listable,    -> { Fields.new editable.reject(&:digest?) }
    derive :attachments, -> { Fields.new select(&:attachment?) }
    derive :timestamps,  -> { Fields.new select(&:timestamp?) }

    derive :by_name,     -> { index_by(&:name).with_indifferent_access }
    derive :names,       -> { map(&:name) }

    def reverse = Fields.new(super)

    def sort_with(obj)
      Fields.new(sort_by { obj.try(_1.name) })
    end

    def has?(name) = by_name.key?(name)
  end
end
