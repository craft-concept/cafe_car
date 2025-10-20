# frozen_string_literal: true

class Array
  def overlap(other)
    0.upto(size) do |i|
      if other.start_with? drop(i)
        return slice(0, i) + other
      end
    end
  end
end
