class DD::Player
  value_semantics do
    username String
    credits DD::Types::Credits
    current_bet DD::Types::Credits, default: 0
    acted_this_stage? Bool(), default: false
    hole_cards ArrayOf(DD::Card), default: []
    state Either(:active, :folded), default: :active
  end

  def active? = state == :active
  def folded? = state == :folded

  def apply_bet(bet, acted:)
    with(
      current_bet: current_bet + bet,
      credits: credits - bet,
      acted_this_stage?: acted ? true : acted_this_stage?,
    )
  end

  def apply_reset_for_next_stage
    with(
      current_bet: 0,
      acted_this_stage?: false,
      state: :active,
    )
  end

  def apply_fold
    with(state: :folded)
  end
end
