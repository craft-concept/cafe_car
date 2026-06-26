# frozen_string_literal: true

class Hash
  # Removes and returns a hash containing the key/value pairs for which the
  # block returns a true value given the key.
  #
  #   hash = {:a => 1, "b" => 2, :c => 3}
  #   hash.extract_if! { _1.is_a? Symbol } #=> {a: 1, c: 3}
  #   hash                                 #=> {"b" => 2 }
  def extract_if!
    each_with_object(self.class.new) do |(key, value), result|
      result[key] = delete(key) if yield(key, value)
    end
  end
end
