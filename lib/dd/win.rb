class DD::Win
  value_semantics do
    player DD::Player
    hand Either(DD::Hand, nil)
    share_of_pot DD::Types::Credits
  end
end
