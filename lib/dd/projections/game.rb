class DD::Projections::Game
  FLOP_CARDS = 3
  TURN_AND_RIVER_CARDS = 1

  value_semantics do
    players ArrayOf(DD::Player), default: []
    current_player_idx DD::Types::Index, default: 0
    pooled_pot DD::Types::Credits, default: 0
    community_cards ArrayOf(DD::Card), default: []
    deck ArrayOf(DD::Card), default: []

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

  def after_bet(credits, acted:)
    with(
      current_player_idx: (current_player_idx + 1) % players.size,
      players: players_updating(current_player_idx) do
        _1.after_betting(credits, acted: acted)
      end
    ).ending_stage_if_necessary
  end

  def ending_stage_if_necessary
    if stage_finished?
      after_ending_stage
    else
      self
    end
  end

  def apply(event)
    case event
    when DD::Events::GameStarted then apply_game_started(event)
    when DD::Events::BlindsPaid then apply_blinds_paid
    when DD::Events::BetPlaced then after_bet(event.credits, acted: true)
    else fail "unhandled event type #{event.class}"
    end
  end

  private

    def player_at_position(idx)
      players.fetch(idx % players.size)
    end

    def stage_finished?
      players.all?(&:acted_this_stage?) &&
        players.map(&:current_bet).uniq.size == 1 # all the same bet
    end

    def players_updating(idx)
      players.dup.tap { _1[idx] = yield _1[idx] }
    end

    def after_ending_stage
      deal_count = pre_flop? ? FLOP_CARDS : TURN_AND_RIVER_CARDS
      with(
        current_player_idx: 1, # player after dealer
        pooled_pot: players.sum(&:current_bet),
        players: players.map(&:reset_for_next_stage),
        community_cards: community_cards + deck.first(deal_count),
        deck: deck.drop(deal_count),
      )
    end

    def pre_flop?
      community_cards.empty?
    end

    def apply_game_started(event)
      with(
        players: event.players,
        small_blind: event.small_blind,
        big_blind: event.big_blind,
        deck: event.deck,
      )
    end

    def apply_blinds_paid
      fail if current_player != dealer

      # TODO: This is not correct when players.size == 2. Need to implement
      # "heads up" rule.
      after_bet(0, acted: false)
        .after_bet(small_blind, acted: false)
        .after_bet(big_blind, acted: false)
    end
end
