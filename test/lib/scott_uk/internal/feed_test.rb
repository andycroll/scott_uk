require_relative '../../../test_helper'

class ScottUk::Internal::FeedTest < Minitest::Test
  include FeedStubs

  def test_listings_reads_a_venue_feed
    stub_feed

    assert_equal 'SCOBWR', ScottUk::Internal::Feed.new.listings('SCOBWR').fetch('cinema')
  end

  def test_errors_name_the_status_but_not_the_body
    stub_request(:get, BRIDGWATER).to_return(status: 500, body: 'secret')

    error = assert_raises(RuntimeError) { ScottUk::Internal::Feed.new.listings('SCOBWR') }
    assert_equal 'HTTP error 500 from www.scottcinemas.co.uk', error.message
  end

  def test_transient_errors_are_retried
    stub_request(:get, BRIDGWATER).to_raise(Errno::ECONNRESET).then.to_return(status: 200, body: feed_json('SCOBWR'))

    Cinebase::Http.stub(:pause, nil) { ScottUk::Internal::Feed.new.listings('SCOBWR') }

    assert_requested :get, BRIDGWATER, times: 2
  end
end
