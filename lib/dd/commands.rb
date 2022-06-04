module DD::Commands
  extend self

  def lookup(name)
    const_get(DD::Inflector.camelize(name))
  end
end
