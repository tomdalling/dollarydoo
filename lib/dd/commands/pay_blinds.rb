module DD::Commands::PayBlinds
  extend self

  def call
    # TODO: validations
    DD::CommandResult.success([
      DD::Events::BlindsPaid.new
    ])
  end
end
