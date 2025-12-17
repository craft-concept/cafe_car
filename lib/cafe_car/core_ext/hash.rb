# frozen_string_literal: true

class Hash
  def extract_if!
    each_with_object(self.class.new) do |(key, value), result|
      result[key] = delete(key) if yield(key, value)
    end
  end
end
