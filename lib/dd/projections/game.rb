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

  def pre_flop? = stage == :pre_flop
  def flop? = stage == :flop
  def turn? = stage == :turn
  def river? = stage == :river
  def finished? = showdown? || remaining_players.count == 1
  def showdown? = river? && stage_finished?
  def current_player = player_at_position(current_player_idx)
  def remaining_players = players.select(&:active?)
  def dealer = players.last
  def largest_current_bet = players.map(&:current_bet).max
  def total_pot = pooled_pot + players.sum(&:current_bet)
  def winners = wins.map(&:player)
  def player(username)
    players.find { _1.username == username } or
      fail "player not found: #{username.inspect}"
  end

  def stage
    case community_cards.size
    when 0 then :pre_flop
    when FLOP_CARDS then :flop
    when FLOP_CARDS + TURN_AND_RIVER_CARDS then :turn
    when FLOP_CARDS + 2*TURN_AND_RIVER_CARDS then :river
    else fail "wtf #{community_cards.size}"
    end
  end

  def wins
    return [] unless finished?

    if remaining_players.count == 1
      [
        DD::Win.new(
          player: remaining_players.first,
          hand: nil,
          share_of_pot: total_pot,
        )
      ]
    else
      showdown_wins
    end
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
      .send(:apply_bet, event.small_blind, acted: false)
      .send(:apply_bet, event.big_blind, acted: false)
  end

  def apply(event)
    case event
    when DD::Events::BetPlaced then apply_bet(event.credits, acted: true)
    when DD::Events::Folded then apply_fold
    else fail "unhandled event type #{event.class}"
    end
  end

  private

    def apply_bet(credits, acted:)
      apply_move do |current_player|
        current_player.apply_bet(credits, acted: acted)
      end
    end

    def apply_start_of_next_stage_if_necessary
      if stage_finished? && !river?
        apply_start_of_next_stage
      else
        self
      end
    end

    def apply_fold
      apply_move do |current_player|
        current_player.apply_fold
      end
    end

    def apply_move(&update_current_player)
      self
        .with(
          players: players_updating(current_player_idx, &update_current_player),
          current_player_idx: (current_player_idx + 1) % players.size,
        )
        .send(:apply_start_of_next_stage_if_necessary)
    end

    def stage_finished?
      remaining_players.all?(&:acted_this_stage?) &&
        remaining_players.map(&:current_bet).uniq.size == 1 # all the same bet
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
        current_player_idx: players.index(remaining_players.first),
        pooled_pot: pooled_pot + players.sum(&:current_bet),
        players: players.map(&:apply_reset_for_next_stage),
        community_cards: community_cards + deck.first(deal_count),
        deck: deck.drop(deal_count),
      )
    end

    def showdown_wins
      ordered_potentials =
        remaining_players
          .map { potential_win_for(_1) }
          .sort_by(&:hand)
          .reverse # best hands first

      # can be multiple winners with equal hands
      ordered_potentials
        .take_while { _1.hand >= ordered_potentials.first.hand }
        .then { distribute_pot_over(_1) }
    end

    def potential_win_for(player)
      DD::Win.new(
        player: player,
        share_of_pot: 0,
        hand:
          if showdown?
            DD::Hand.best_from(player.hole_cards + community_cards)
          else
            nil
          end
      )
    end

    def distribute_pot_over(wins)
      division = total_pot / wins.count
      remainder = total_pot % division
      ordered_wins = wins.sort_by { players.index(_1.player) }

      ordered_wins.each_with_index.map do |w, idx|
        extra = idx < remainder ? 1 : 0
        w.with(share_of_pot: division + extra)
      end
    end
end
