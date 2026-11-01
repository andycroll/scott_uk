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
    assert_equal 'Scott Cinemas HTTP error 500', error.message
  end

  def test_redirects_are_not_followed
    stub_request(:get, BRIDGWATER).to_return(status: 302, headers: { 'Location' => 'https://www.scottcinemas.co.uk/findme' })

    assert_raises(RuntimeError) { ScottUk::Internal::Feed.new.listings('SCOBWR') }
  end

  def test_transient_errors_are_retried
    stub_request(:get, BRIDGWATER).to_raise(Errno::ECONNRESET).then.to_return(status: 200, body: feed_json('SCOBWR'))
    feed = ScottUk::Internal::Feed.new

    feed.stub(:sleep, nil) { feed.listings('SCOBWR') }

    assert_requested :get, BRIDGWATER, times: 2
  end

  def test_retries_give_up
    stub_request(:get, BRIDGWATER).to_raise(Net::OpenTimeout)
    feed = ScottUk::Internal::Feed.new

    assert_raises(Net::OpenTimeout) { feed.stub(:sleep, nil) { feed.listings('SCOBWR') } }
    assert_requested :get, BRIDGWATER, times: 3
  end
end
