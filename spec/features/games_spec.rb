RSpec.feature "Texas Hold'em Games" do
  scenario "a game that goes to showdown" do
    @game = DD::Entity.new(DD::Projections::Game)

    When "the game starts for Tom and Mot" do
      @game.run_command!(:start_game,
        small_blind: 10,
        big_blind: 20,
        players: [
          DD::Player.new(username: "tom", credits: 1_000),
          DD::Player.new(username: "mot", credits: 1_000),
        ],
        deck: [
          # deal to p1 (AQ off suit)
          # DD::Card.ace_of_spades,
          # DD::Card.queen_of_hearts,

          # deal to p2 (suited connectors)
          # DD::Card.six_of_diamonds,
          # DD::Card.seven_of_diamonds,

          # flop (rainbow, pair of aces for p1, straight draw for p2)
          DD::Card.ace_of_diamonds,
          DD::Card.five_of_spades,
          DD::Card.four_of_clubs,

          # turn (flush draw for p2)
          DD::Card.three_of_diamonds,

          # river (flush for p2)
          DD::Card.jack_of_diamonds,
        ]
      )
    end

    Then "it has players" do
      expect(@game.players.size).to eq(2)
    end

    When "the blinds are paid" do
      @game.run_command!(:pay_blinds)
    end

    Then "Mot has paid the small blind" do
      expect(@game.player("mot")).to have_attributes(credits: 990, current_bet: 10)
    end

    Then "Tom has paid the big blind" do
      expect(@game.player("tom")).to have_attributes(credits: 980, current_bet: 20)
    end

    Then "Mot is the current player" do
      expect(@game.current_player.username).to eq("mot")
    end

    When "Mot calls" do
      @game.run_command!(:bet, credits: 10)
    end

    Then "Mot has paid up to the big blind" do
      expect(@game.player("mot")).to have_attributes(
        current_bet: 20,
        credits: 980,
      )
    end

    Then "Tom is the current player" do
      expect(@game.current_player.username).to eq("tom")
    end

    When "Tom checks" do
      @game.run_command!(:check)
    end

    Then "bets are pooled into the pot" do
      expect(@game.pooled_pot).to eq(40)
      expect(@game.players).to all have_attributes(current_bet: 0, credits: 980)
    end

    Then "the flop is dealt" do
      expect(@game).to have_attributes(
        community_cards: [
          DD::Card.ace_of_diamonds,
          DD::Card.five_of_spades,
          DD::Card.four_of_clubs,
        ],
        deck: [
          DD::Card.three_of_diamonds,
          DD::Card.jack_of_diamonds,
        ]
      )
    end

    Then "Mot is the current player" do
      expect(@game.current_player.username).to eq("mot")
    end
  end
end
