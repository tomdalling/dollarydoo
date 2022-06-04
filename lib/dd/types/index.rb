module DD::Types::Index
  extend self

  def ===(value)
    value.is_a?(Integer) && value >= 0
  end
end
