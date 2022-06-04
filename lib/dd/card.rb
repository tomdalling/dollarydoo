class DD::Card
  RANK_PREFIXES = {
    two: "2",
    three: "3",
    four: "4",
    five: "5",
    six: "6",
    seven: "7",
    eight: "8",
    nine: "9",
    ten: "10",
    jack: "J",
    queen: "Q",
    king: "K",
    ace: "A",
  }.freeze
  RANKS = RANK_PREFIXES.keys.freeze

  SUIT_SUFFIXES = {
    diamonds: "D",
    clubs: "C",
    hearts: "H",
    spades: "S",
  }.freeze
  SUITS = SUIT_SUFFIXES.keys.freeze

  value_semantics do
    rank Either(*RANKS)
    suit Either(*SUITS)
  end

  RANKS.product(SUITS).map do |(rank, suit)|
    singleton_class.class_eval <<~RUBY
      def #{rank}_of_#{suit}  # def ace_of_spades
        new(                  #   new(
          rank: :#{rank},     #     rank: :ace,
          suit: :#{suit},     #     suit: :spades,
        )                     #   )
      end                     # end
    RUBY
  end

  def self.all
    @all ||=
      SUITS.product(RANKS).map do |(suit, rank)|
        new(rank: rank, suit: suit)
      end.freeze
  end

  def self.parse(serialized)
    attrs = {
      rank: RANK_PREFIXES.key(serialized[0..-2]),
      suit: SUIT_SUFFIXES.key(serialized[-1]),
    }

    raise "wtf? #{serialized.inspect}" if attrs.values.any?(&:nil?)

    new(**attrs)
  end

  def self.new(**attrs)
    # there are only a finite set of values, so might as well deduplicate them
    @cache ||= {}
    @cache.fetch(attrs) do
      @cache[attrs] = super.freeze
    end
  end

  def rank_value
    RANKS.index(rank) || fail
  end

  def inspect
    "#<Card #{RANK_PREFIXES.fetch(rank)}#{SUIT_SUFFIXES.fetch(suit)}>"
  end
end
