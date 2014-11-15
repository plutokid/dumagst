require 'matrix'

#patch the Vector class

class Vector
  def each_index(&block)
    range = (0..size-1)
    block_given? ? range.each(&block) : range.to_enum
  end
end