# Read fixtures from disk: Bridgwater's feed, trimmed to a few dates and
# shortened descriptions. It follows the shape in api_shapes.rb.
module FixturesHelper
  private

  def feed_json(code)
    read_fixture("feed/#{code}.json")
  end

  def read_fixture(filepath)
    File.read(File.expand_path("../../fixtures/#{filepath}", __FILE__))
  end
end
