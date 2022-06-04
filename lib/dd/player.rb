class DD::Player
  value_semantics do
    username String
    credits DD::Types::Credits
    current_bet DD::Types::Credits, default: 0
  end

  def after_betting(bet)
    with(
      current_bet: current_bet + bet,
      credits: credits - bet,
    )
  end
end
