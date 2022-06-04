class DD::Projections::Game
  value_semantics do
    players ArrayOf(DD::Player), default: []
    current_player_idx DD::Types::Index, default: 0
    pooled_pot DD::Types::Credits, default: 0

    small_blind DD::Types::Credits, default: 0
    big_blind DD::Types::Credits, default: 0
  end

  def dealer = player_at_position(0)
  def small_blind_payer = player_at_position(1)
  def big_blind_payer = player_at_position(2)
  def current_player = player_at_position(current_player_idx)
  def player(username)
    players.find { _1.username == username } or
      fail "player not found: #{username.inspect}"
  end

  def after_bet(credits)
    with(
      current_player_idx: (current_player_idx + 1) % players.size,
      players: players_updating(current_player_idx) { _1.after_betting(credits) }
    )
  end

  def apply(event)
    case event
    when DD::Events::GameStarted then apply_game_started(event)
    when DD::Events::BlindsPaid then apply_blinds_paid
    else fail "unhandled event type #{event.class}"
    end
  end

  private

    def player_at_position(idx)
      players.fetch(idx % players.size)
    end

    def players_updating(idx)
      players.dup.tap { _1[idx] = yield _1[idx] }
    end

    def apply_game_started(event)
      with(
        players: event.players,
        small_blind: event.small_blind,
        big_blind: event.big_blind,
      )
    end

    def apply_blinds_paid
      fail if current_player != dealer

      after_bet(0).after_bet(small_blind).after_bet(big_blind)
    end
end
