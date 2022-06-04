class DD::Card
  RANKS = %i[two three four five six seven eight nine ten jack queen king ace].freeze
  SUITS = %i[diamonds clubs hearts spades].freeze

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

  def self.new(**attrs)
    # there are only a finite set of values, so might as well deduplicate them
    @cache ||= {}
    @cache.fetch(attrs) do
      @cache[attrs] = super.freeze
    end
  end
end
