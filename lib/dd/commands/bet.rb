module DD::Commands::Bet
  extend self

  def call(credits:)
    # TODO: validation
    DD::CommandResult.success([
      DD::Events::BetPlaced.new(credits: credits),
    ])
  end
end
