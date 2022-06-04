# Mutable wrapper for an immutable projection
class DD::Entity
  attr_reader :projection

  def initialize(projection_class)
    @projection = projection_class.new
  end

  def run_command!(command_name, **command_params)
    command = DD::Commands.lookup(command_name)
    result = command.call(**command_params)
    unless result.ok?
      # TODO: work out what failures look like
      raise "Command failed: #{result.inspect}"
    end

    result.events.each do |event|
      @projection = @projection.apply(event)
    end

    nil
  end
end
