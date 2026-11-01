require_relative 'live_helper'

# Every venue's feed: six requests.
class LiveApiShapeTest < Minitest::Test
  include ApiShapes

  def test_feeds_are_readable
    ScottUk::Cinema::VENUES.each_key do |code|
      assert_feed_shape(ScottUk::Internal::Feed.new.listings(code), code)
    end
  end
end
