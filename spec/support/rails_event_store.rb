# Use in-memory repository whilst running the test suite
RSpec.configure do |c|
  c.before(:each) do
    Rails.configuration.event_store = RailsEventStore::Client.new(
      repository: RubyEventStore::InMemoryRepository.new
    )
  end
end
