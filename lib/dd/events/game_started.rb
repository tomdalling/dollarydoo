class DD::Events::GameStarted
  value_semantics do
    players ArrayOf(DD::Player)
  end
end
