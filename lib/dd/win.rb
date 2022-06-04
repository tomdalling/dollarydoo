class DD::Win
  value_semantics do
    player DD::Player
    hand Either(DD::Hand, nil)
  end
end
