# frozen_string_literal: true

class Array
  def overlap(other)
    0.upto(size) do |i|
      if other.start_with? drop(i)
        return slice(0, i) + other
      end
    end
  end

  def extract!(pattern = nil, &block)
    block = -> { pattern === _1 } if pattern
    return to_enum(:extract!) { size } unless block

    extracted_elements = []

    reject! do |element|
      extracted_elements << element if block.(element)
    end

    extracted_elements
  end
end
