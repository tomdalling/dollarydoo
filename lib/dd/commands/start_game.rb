module DD::Commands::StartGame
  extend self

  def call(players:, small_blind:, big_blind:)
    DD::CommandResult.success([
      DD::Events::GameStarted.new(
        small_blind: small_blind,
        big_blind: big_blind,
        players: players,
      )
    ])
  end
end
