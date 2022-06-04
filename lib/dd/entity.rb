# Mutable wrapper for an immutable projection
class DD::Entity < SimpleDelegator
  def initialize(projection_class)
    super(projection_class.new)
  end

  def run_command!(command_name, **command_params)
    command = DD::Commands.lookup(command_name)
    result = command.call(**command_params)
    unless result.ok?
      # TODO: work out what failures look like
      raise "Command failed: #{result.inspect}"
    end

    result.events.each do |event|
      __setobj__(__getobj__.apply(event))
    end

    nil
  end
end
