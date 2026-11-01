require_relative '../../test_helper'

class ScottUk::PerformanceTest < Minitest::Test
  include FeedStubs

  DATE = Date.new(2026, 11, 4)
  BOOKING = 'https://bridgwater.scottcinemas.co.uk/book-now/'.freeze

  def setup
    stub_feed
  end

  def test_at_returns_performances_in_time_order
    performances = performances_at('SCOBWR')

    assert(performances.all? { |p| p.instance_of?(ScottUk::Performance) })
    assert_equal 42, performances.count
    assert_equal performances.map(&:starting_at).sort, performances.map(&:starting_at)
  end

  def test_at_reads_every_date_from_one_request
    performances_at('scobwr')

    assert_requested :get, BRIDGWATER, times: 1
  end

  def test_at_keeps_to_the_range
    assert_equal 21, ScottUk::Performance.at('SCOBWR', from: DATE, to: DATE).count
  end

  def test_at_sets_cinema_details
    performances = performances_at('SCOBWR')

    assert_equal ['SCOBWR'], performances.map(&:cinema_id).uniq
    assert_equal ['Bridgwater'], performances.map(&:cinema_name).uniq
  end

  def test_at_parses_first_performance
    performance = performances_at('SCOBWR').first

    assert_equal 'Primetime', performance.film_name
    assert_nil performance.film_year
    assert_equal Time.utc(2026, 11, 1, 13, 45), performance.starting_at
    assert_equal '2d', performance.dimension
    assert_empty performance.variant
    assert_nil performance.festival
    assert_equal "#{BOOKING}primetime/76326", performance.booking_url
  end

  def test_summer_times_are_converted_to_utc
    performance = performances_at('SCOBWR').last

    assert_equal 'Royal Ballet and Opera: ROMEO & JULIET', performance.film_name
    assert_equal Time.utc(2027, 5, 25, 18, 15), performance.starting_at
    assert_equal %w(arts), performance.variant
  end

  def test_parent_and_baby_screenings
    performance = find('76429')

    assert_equal 'Ghosts: The Possession of Button House', performance.film_name
    assert_equal %w(baby), performance.variant
  end

  def test_autism_friendly_screenings_are_relaxed
    assert_equal %w(relaxed), find('76406').variant
  end

  def test_audio_description_is_not_a_variant
    assert_equal %w(senior), find('75935').variant
  end

  def test_subtitled_screenings
    performance = find('75936')

    assert_equal %w(senior subtitled), performance.variant
    assert performance.subtitled?
  end

  def test_event_cinema_is_arts
    performance = find('74647')

    assert_equal 'National Theatre Live: GOLDEN BOY', performance.film_name
    assert_equal %w(arts), performance.variant
  end

  def test_screen_formats_and_warnings_are_not_variants
    assert_empty find('76327').variant
  end

  def test_unknown_cinema_makes_no_request
    assert_empty ScottUk::Performance.at('SCOZZZ', from: DATE, to: DATE)
    assert_not_requested :get, /scottcinemas/
  end

  def test_to_must_not_precede_from
    assert_raises(ArgumentError) { ScottUk::Performance.at('SCOBWR', from: DATE, to: DATE - 1) }
  end

  def test_empty_schedules_from_php_are_read
    stub_request(:get, "#{FEED}?cinema=SCOBAR").to_return(
      status: 200, body: { cinema: 'SCOBAR', films: [], schedule: [] }.to_json
    )

    assert_empty performances_at('SCOBAR')
  end

  def test_showtimes_of_unlisted_films_are_skipped
    feed = { cinema: 'SCOBAR', films: [], schedule: { '1793750400' => { '1' => { '1793790000' => { film_id: '1' } } } } }
    stub_request(:get, "#{FEED}?cinema=SCOBAR").to_return(status: 200, body: feed.to_json)

    assert_empty performances_at('SCOBAR')
  end

  private

  def performances_at(cinema_id)
    ScottUk::Performance.at(cinema_id, from: Date.new(2026, 11, 1), to: Date.new(2027, 11, 1))
  end

  def find(booking_id)
    performances_at('SCOBWR').detect { |p| p.booking_url.end_with?("/#{booking_id}") }
  end
end
