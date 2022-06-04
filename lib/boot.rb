# bundler
require "rubygems"
require "bundler"
Bundler.require

# zeitwerk
require_relative "dd"
require_relative "dd/inflector"
Zeitwerk::Loader.new.tap do |loader|
  loader.push_dir(__dir__)
  loader.inflector = DD::Inflector
  loader.setup
end

# other global config
ValueSemantics.monkey_patch!
