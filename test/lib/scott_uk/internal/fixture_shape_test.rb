require_relative '../../../test_helper'

class FixtureShapeTest < Minitest::Test
  include ApiShapes
  include FixturesHelper

  def test_feed_fixture_matches_shape
    assert_feed_shape(JSON.parse(feed_json('SCOBWR')), 'SCOBWR')
  end
end
