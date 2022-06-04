module DD::Inflector
  extend self

  # _abspath is just for compatibility with zeitwerk
  def camelize(text, _abspath=nil)
    dry_inflector.camelize(text)
  end

  private

    def dry_inflector
      @dry_inflector ||= Dry::Inflector.new do |i|
        i.acronym(
          "DD", # Dollarydoo
        )
      end
    end
end
