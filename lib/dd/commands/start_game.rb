module DD::Commands::StartGame
  extend self

  def call
    DD::CommandResult.success([
      DD::Events::GameStarted.new(
        players: [
          DD::Player.new(username: "tom"),
          DD::Player.new(username: "mot"),
        ]
      )
    ])
  end
end
