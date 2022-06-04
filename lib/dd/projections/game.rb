class DD::Projections::Game
  value_semantics do
    players ArrayOf(DD::Player), default: []
  end

  def apply(event)
    case event
    when DD::Events::GameStarted then apply_game_started(event)
    else fail "unhandled event type #{event.class}"
    end
  end

  private

    def apply_game_started(event)
      with(players: event.players)
    end
end
