module DD::Commands::Check
  extend self

  def call(game)
    DD::Commands::Bet.call(game, credits: 0)
  end
end
