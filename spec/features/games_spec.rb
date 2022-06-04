RSpec.feature "Games" do
  scenario "a typical game" do
    @game = DD::Entity.new(DD::Projections::Game)

    When "the game starts" do
      @game.run_command!(:start_game)
    end

    Then "it has players" do
      expect(@game.projection.players.size).to be > 1
    end
  end
end
