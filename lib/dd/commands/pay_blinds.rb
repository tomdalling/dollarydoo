module DD::Commands::PayBlinds
  extend self

  def call
    DD::CommandResult.success([
      DD::Events::BlindsPaid.new
    ])
  end
end
