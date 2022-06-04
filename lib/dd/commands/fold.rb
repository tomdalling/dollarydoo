module DD::Commands::Fold
  extend self

  def call(game)
    # TODO: validation
    DD::CommandResult.success([
      DD::Events::Folded.new,
    ])
  end
end
