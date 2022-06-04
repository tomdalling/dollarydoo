RSpec.feature "Texas Hold'em Games" do
  subject(:game) { DD::Entity.new(DD::Projections::Game) }

  scenario "a game that goes to showdown" do
    When "the game starts for Tom and Mot" do
      game.run_command!(:start_game,
        small_blind: 10,
        big_blind: 20,
        players: [
          DD::Player.new(username: "mot", credits: 1_000),
          DD::Player.new(username: "tom", credits: 1_000),
        ],
        deck: [
          # deal to Mot (suited connectors)
          DD::Card.six_of_diamonds,
          DD::Card.seven_of_diamonds,

          # deal to Tom (AQ off suit)
          DD::Card.ace_of_spades,
          DD::Card.queen_of_hearts,

          # flop (rainbow, pair of aces for Tom, straight draw for Mot)
          DD::Card.ace_of_diamonds,
          DD::Card.five_of_spades,
          DD::Card.four_of_clubs,

          # turn (flush draw for Mot)
          DD::Card.three_of_diamonds,

          # river (flush for Mot)
          DD::Card.jack_of_diamonds,
        ]
      )
    end

    Then "hole cards are dealt" do
      expect(game.player("tom").hole_cards).to eq([
        DD::Card.ace_of_spades,
        DD::Card.queen_of_hearts,
      ])

      expect(game.player("mot").hole_cards).to eq([
        DD::Card.six_of_diamonds,
        DD::Card.seven_of_diamonds,
      ])
    end

    And "Mot has paid the small blind" do
      expect(game.player("mot")).to have_attributes(credits: 990, current_bet: 10)
    end

    And "Tom has paid the big blind" do
      expect(game.player("tom")).to have_attributes(credits: 980, current_bet: 20)
    end

    And "Mot is the current player" do
      expect(game.current_player.username).to eq("mot")
    end

    When "Mot calls" do
      game.run_command!(:call)
    end

    Then "Mot has paid up to the big blind" do
      expect(game.player("mot")).to have_attributes(
        current_bet: 20,
        credits: 980,
      )
    end

    And "Tom is the current player" do
      expect(game.current_player.username).to eq("tom")
    end

    When "Tom checks" do
      game.run_command!(:check)
    end

    Then "bets are pooled into the pot" do
      expect(game.pooled_pot).to eq(40)
      expect(game.players).to all have_attributes(current_bet: 0, credits: 980)
    end

    And "the flop is dealt" do
      expect(game).to have_attributes(
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

    And "Mot is the current player" do
      expect(game.current_player.username).to eq("mot")
    end

    When "Mot checks" do
      game.run_command!(:check)
    end

    And "Tom raises" do
      game.run_command!(:bet, credits: 30)
    end

    And "Mot calls" do
      game.run_command!(:call)
    end

    Then "bets are pooled into the pot" do
      expect(game.pooled_pot).to eq(100)
      expect(game.players).to all have_attributes(current_bet: 0, credits: 950)
    end

    And "the turn is dealt" do
      expect(game).to have_attributes(
        community_cards: [
          DD::Card.ace_of_diamonds,
          DD::Card.five_of_spades,
          DD::Card.four_of_clubs,
          DD::Card.three_of_diamonds,
        ],
        deck: [
          DD::Card.jack_of_diamonds,
        ]
      )
    end

    When "Mot checks" do
      game.run_command!(:check)
    end

    And "Tom raises" do
      game.run_command!(:bet, credits: 100)
    end

    And "Mot reraises" do
      game.run_command!(:bet, credits: 200)
    end

    And "Tom calls" do
      game.run_command!(:call)
    end

    Then "bets are pooled into the pot" do
      expect(game.pooled_pot).to eq(500)
      expect(game.players).to all have_attributes(current_bet: 0, credits: 750)
    end

    And "the river is dealt" do
      expect(game).to have_attributes(
        community_cards: [
          DD::Card.ace_of_diamonds,
          DD::Card.five_of_spades,
          DD::Card.four_of_clubs,
          DD::Card.three_of_diamonds,
          DD::Card.jack_of_diamonds,
        ],
        deck: [],
      )
    end

    When "Mot raises" do
      game.run_command!(:bet, credits: 500)
    end

    And "Tom calls" do
      game.run_command!(:call)
    end

    Then "the game is over" do
      expect(game).to be_finished
    end

    And "the winner is Mot with a flush" do
      expect(game.wins.size).to eq(1)
      expect(game.wins.first.player.username).to eq("mot")
      expect(game.wins.first.hand.cards).to contain_exactly(
        DD::Card.six_of_diamonds,
        DD::Card.seven_of_diamonds,
        DD::Card.ace_of_diamonds,
        DD::Card.three_of_diamonds,
        DD::Card.jack_of_diamonds,
      )
    end

    And "Mot receives the entire pot" do
      expect(game.total_pot).to eq(1500)
      expect(game.wins.first.share_of_pot).to eq(1500)
    end
  end

  scenario "a game that doesn't go to showdown" do
    When "the game starts for Tom and Mot" do
      game.run_command!(:start_game,
        small_blind: 10,
        big_blind: 20,
        players: [
          DD::Player.new(username: "mot", credits: 1_000),
          DD::Player.new(username: "tom", credits: 1_000),
        ],
      )
    end

    Then "Mot is the current player" do
      expect(game.current_player.username).to eq("mot")
    end

    When "Mot raises" do
      game.run_command!(:bet, credits: 100)
    end

    And "Tom folds" do
      game.run_command!(:fold)
    end

    Then "the game is over" do
      expect(game).to be_finished
    end

    And "the winner is Mot" do
      expect(game.wins.size).to eq(1)
      expect(game.wins.first.player.username).to eq("mot")
      expect(game.wins.first.hand).to be_nil
    end

    And "Mot receives the entire pot" do
      expect(game.total_pot).to eq(130)
      expect(game.wins.first.share_of_pot).to eq(130)
    end
  end

  scenario "a game that results in a draw" do
    When "the game starts for Dealy, Smally, and Biggy" do
      game.run_command!(:start_game,
        small_blind: 10,
        big_blind: 20,
        players: [
          DD::Player.new(username: "smally", credits: 1_000),
          DD::Player.new(username: "biggy", credits: 1_000),
          DD::Player.new(username: "dealy", credits: 1_000),
        ],
        deck: [
          # deal to p1
          DD::Card.two_of_spades,
          DD::Card.three_of_spades,

          # deal to p2
          DD::Card.two_of_diamonds,
          DD::Card.three_of_diamonds,

          # deal to p3
          DD::Card.two_of_clubs,
          DD::Card.three_of_clubs,

          # community cards (royal flush)
          DD::Card.ace_of_hearts,
          DD::Card.king_of_hearts,
          DD::Card.queen_of_hearts,
          DD::Card.jack_of_hearts,
          DD::Card.ten_of_hearts,
        ]
      )
    end

    Then "the current player is Dealy" do
      expect(game.current_player.username).to eq("dealy")
    end

    When "Dealy raises to 101" do
      game.run_command!(:bet, credits: 101)
    end

    And "the other players call" do
      game.run_command!(:call)
      game.run_command!(:call)
    end

    Then "the game advances to the flop" do
      expect(game.stage).to eq(:flop)
    end

    When "Smally folds and the other players check" do
      game.run_command!(:fold)
      game.run_command!(:check)
      game.run_command!(:check)
    end

    Then "the game advances to the turn" do
      expect(game.stage).to eq(:turn)
    end

    When "the remaining players check" do
      game.run_command!(:check)
      game.run_command!(:check)
    end

    Then "the game advances to the river" do
      expect(game.stage).to eq(:river)
    end

    When "the remaining players check again" do
      game.run_command!(:check)
      game.run_command!(:check)
    end

    Then "the game is finished" do
      expect(game).to be_finished
    end

    And "Dealy and Biggy both win with a royal flush" do
      expect(game.winners.map(&:username)).to contain_exactly("dealy", "biggy")
      expect(game.wins.map(&:hand)).to all be_straight_flush
    end

    And "the final pot is 303" do
      expect(game.total_pot).to eq(303)
    end

    And "Biggy gets half the pot, rounded up" do
      biggy_win = game.wins.find { _1.player.username == "biggy" }
      expect(biggy_win.share_of_pot).to eq(152)
    end

    And "Dealy gets half the pot, rounded down" do
      dealy_win = game.wins.find { _1.player.username == "dealy" }
      expect(dealy_win.share_of_pot).to eq(151)
    end
  end
end
