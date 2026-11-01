require_relative 'fixtures_helper'

# Serve the fixture in place of the Scott Cinemas feed
module FeedStubs
  include FixturesHelper

  FEED = 'https://www.scottcinemas.co.uk/json.php'.freeze
  BRIDGWATER = "#{FEED}?cinema=SCOBWR".freeze

  private

  def stub_feed
    stub_request(:get, BRIDGWATER).to_return(status: 200, body: feed_json('SCOBWR'))
  end
end
