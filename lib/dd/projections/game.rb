class DD::Projections::Game
  FLOP_CARDS = 3
  TURN_AND_RIVER_CARDS = 1
  HOLE_CARDS = 2

  value_semantics do
    players ArrayOf(DD::Player)
    current_player_idx DD::Types::Index
    pooled_pot DD::Types::Credits
    community_cards ArrayOf(DD::Card)
    deck ArrayOf(DD::Card)
  end

  def current_player = player_at_position(current_player_idx)
  def player(username)
    players.find { _1.username == username } or
      fail "player not found: #{username.inspect}"
  end

  def self.apply(event)
    raise ArgumentError unless event.is_a?(DD::Events::GameStarted)

    remaining_deck = event.deck.dup
    dealt_players = event.players.map do |p|
      p.with(hole_cards: remaining_deck.shift(HOLE_CARDS))
    end

    self
      .new(
        current_player_idx: 0,
        players: dealt_players,
        deck: remaining_deck,
        pooled_pot: 0,
        community_cards: [],
      )
      # TODO: This is not correct when players.size == 2. Need to implement
      # "heads up" rule for blinds.
      .send(:apply_bet, 0, acted: false)
      .send(:apply_bet, event.small_blind, acted: false)
      .send(:apply_bet, event.big_blind, acted: false)
  end

  def apply(event)
    case event
    when DD::Events::BetPlaced then apply_bet(event.credits, acted: true)
    else fail "unhandled event type #{event.class}"
    end
  end

  private
    def pre_flop? = community_cards.empty?

    def apply_bet(credits, acted:)
      self
        .with(
          current_player_idx: (current_player_idx + 1) % players.size,
          players: players_updating(current_player_idx) do
            _1.apply_bet(credits, acted: acted)
          end
        )
        .send(:apply_start_of_next_stage_if_necessary)
    end

    def apply_start_of_next_stage_if_necessary
      if stage_finished?
        apply_start_of_next_stage
      else
        self
      end
    end

    def stage_finished?
      players.all?(&:acted_this_stage?) &&
        players.map(&:current_bet).uniq.size == 1 # all the same bet
    end

    def player_at_position(idx)
      players.fetch(idx % players.size)
    end

    def players_updating(idx)
      players.dup.tap { _1[idx] = yield _1[idx] }
    end

    def apply_start_of_next_stage
      deal_count = pre_flop? ? FLOP_CARDS : TURN_AND_RIVER_CARDS
      with(
        current_player_idx: 1, # player after dealer
        pooled_pot: players.sum(&:current_bet),
        players: players.map(&:apply_reset_for_next_stage),
        community_cards: community_cards + deck.first(deal_count),
        deck: deck.drop(deal_count),
      )
    end
end
