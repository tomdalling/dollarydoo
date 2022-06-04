class DD::Events::GameStarted
  value_semantics do
    players ArrayOf(DD::Player)
    small_blind DD::Types::Credits
    big_blind DD::Types::Credits
    deck ArrayOf(DD::Card)
  end
end
