# frozen_string_literal: true

class Hash
  def extract_if!
    each_with_object(self.class.new) do |(key, value), result|
      result[key] = delete(key) if yield(key, value)
    end
  end

  def transform!(*keys)
    keys.each do |k|
      self[k] = yield self[k] if key?(k)
    end
  end

  def transform(...) = dup.transform!(...)
end
