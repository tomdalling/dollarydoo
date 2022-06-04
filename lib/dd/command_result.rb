class DD::CommandResult
  def self.success(events)
    Success.new(events)
  end

  private

    class Success
      attr_reader :events

      def initialize(events)
        @events = events
      end

      def ok? = true
    end
end
