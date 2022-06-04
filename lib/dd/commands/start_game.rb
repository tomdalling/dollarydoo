module DD::Commands::StartGame
  extend self

  def call(_, players:, small_blind:, big_blind:, deck: DD::Card.all.shuffle)
    fail if deck.uniq.size != deck.size

    # TODO: validations
    DD::CommandResult.success([
      DD::Events::GameStarted.new(
        small_blind: small_blind,
        big_blind: big_blind,
        players: players,
        deck: deck,
      )
    ])
  end
end
