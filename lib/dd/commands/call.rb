module DD::Commands::Call
  extend self

  def call(game)
    DD::Commands::Bet.call(game,
      credits: game.largest_current_bet - game.current_player.current_bet,
    )
  end
end
