module DD::Commands::Check
  extend self

  def call
    # TODO: validation
    DD::CommandResult.success([
      DD::Events::BetPlaced.new(credits: 0),
    ])
  end
end
