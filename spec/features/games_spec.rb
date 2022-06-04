RSpec.feature "Games" do
  scenario "a typical game" do
    @game = DD::Entity.new(DD::Projections::Game)

    When "the game starts for Tom and Mot" do
      @game.run_command!(:start_game,
        small_blind: 10,
        big_blind: 20,
        players: [
          DD::Player.new(username: "tom", credits: 1_000),
          DD::Player.new(username: "mot", credits: 1_000),
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
  end
end
