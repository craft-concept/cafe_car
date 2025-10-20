module CafeCar
  class Fields < Array
    include Caching

    derive :editable,    -> { Fields.new reject(&:constant?) }
    derive :listable,    -> { Fields.new editable.reject(&:digest?) }
    derive :attachments, -> { Fields.new select(&:attachment?) }

    derive :by_name,     -> { index_by(&:name).with_indifferent_access }
    derive :names,       -> { map(&:name) }

    def has?(name) = by_name.key?(name)
  end
end
