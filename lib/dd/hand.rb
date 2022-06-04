class DD::Hand
  include Comparable

  SIZE = 5
  TYPES = %i[
    high_card
    pair
    two_pairs
    three_of_a_kind
    straight
    flush
    full_house
    four_of_a_kind
    straight_flush
  ].freeze

  value_semantics do
    cards ArrayOf(DD::Card)
  end

  def self.best_from(cards)
    cards.combination(SIZE)
      .map { new(cards: _1) }
      .sort
      .last
  end

  def self.[](serialised_cards)
    new(cards: serialised_cards.split.map { DD::Card.parse(_1) })
  end

  def type
    if straight? && flush?
      :straight_flush
    elsif quadruplet?
      :four_of_a_kind
    elsif triplet? && pairs.count == 1
      :full_house
    elsif flush?
      :flush
    elsif straight?
      :straight
    elsif triplet?
      :three_of_a_kind
    else
      case pairs.count
      when 2 then :two_pairs
      when 1 then :pair
      when 0 then :high_card
      else fail
      end
    end
  end

  def <=>(other)
    if type == other.type
      ordered_kicker_values <=> other.send(:ordered_kicker_values)
    else
      type_value <=> other.send(:type_value)
    end
  end

  private

    def straight?
      ordered_values = cards.map(&:rank_value).sort

      ordered_values[0..-2].zip(ordered_values[1..-1]).all? do |(this_rank, next_rank)|
        next_rank == this_rank + 1
      end
    end

    def type_value = TYPES.index(type)
    def ordered_kicker_values
      # 1. first order by group size (singles < pairs < triplets < quads)
      # 2. then by rank of the group (2x2s < 2x3s < ... < 2xAs)
      # 3. reverse, so it's highest to lowest
      # 4. use the rank value (A => 12, K => 11, ..., 3 => 1, 2 => 0)
      #
      # NOTE: suit doesn't matter
      rank_groups
        .sort_by { [_1.size, _1.first.rank_value] }
        .reverse
        .map { _1.first.rank_value }
    end

    def flush? = cards.map(&:suit).uniq.size == 1
    def pairs = rank_groups.select { _1.size == 2 }
    def triplet? = rank_groups.any? { _1.size == 3 }
    def quadruplet? = rank_groups.any? { _1.size == 4 }
    def rank_groups
      @rank_groups ||= cards.group_by(&:rank).values
    end
end
