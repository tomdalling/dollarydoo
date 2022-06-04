module DD::Commands::Bet
  extend self

  def call(game, credits:)
    # TODO: validation
    DD::CommandResult.success([
      DD::Events::BetPlaced.new(credits: credits),
    ])
  end
end
