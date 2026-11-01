require_relative '../../test_helper'

class ScottUk::CinemaTest < Minitest::Test
  IDS = %w(SCOBAR SCOBWR SCOORP SCOEXM SCONEW SCORAD).freeze

  def test_all_returns_every_venue_without_requests
    cinemas = ScottUk::Cinema.all

    assert(cinemas.all? { |cinema| cinema.instance_of?(ScottUk::Cinema) })
    assert_equal IDS, cinemas.map(&:id)
  end

  def test_new_stores_upcase_string_id
    assert_equal 'SCOBAR', ScottUk::Cinema.new('scobar').id
  end

  def test_name_full_name_and_slug
    cinema = ScottUk::Cinema.new('SCOORP')

    assert_equal 'Bristol, Westbury Park', cinema.name
    assert_equal 'Scott Cinemas Bristol, Westbury Park', cinema.full_name
    assert_equal 'scott-cinemas-bristol-westbury-park', cinema.slug
  end

  def test_brand
    assert_equal 'Scott Cinemas', ScottUk::Cinema.new('SCOBAR').brand
  end

  def test_url
    assert_equal 'https://barnstaple.scottcinemas.co.uk', ScottUk::Cinema.new('SCOBAR').url
  end

  def test_adr
    expected = {
      street_address:   'Northgate Yard',
      extended_address: 'Mount Street',
      locality:         'Bridgwater',
      region:           'Somerset',
      postal_code:      'TA6 3FQ',
      country_name:     'United Kingdom'
    }

    assert_equal expected, ScottUk::Cinema.new('SCOBWR').adr
  end

  def test_coordinates
    cinema = ScottUk::Cinema.new('SCOBAR')

    assert_in_delta 51.07933, cinema.latitude
    assert_in_delta(-4.05859, cinema.longitude)
  end

  def test_every_venue_has_a_postcode_and_coordinates
    ScottUk::Cinema.all.each do |cinema|
      refute_empty cinema.locality, cinema.id
      assert_match(/\A[A-Z]{2}\d{1,2} \d[A-Z]{2}\z/, cinema.postal_code, cinema.id)
      assert_kind_of Float, cinema.latitude, cinema.id
      assert_kind_of Float, cinema.longitude, cinema.id
    end
  end

  def test_unknown_cinema_has_no_details
    cinema = ScottUk::Cinema.new('SCOZZZ')

    assert_equal '', cinema.name
    assert_equal '', cinema.url
    assert_nil cinema.latitude
  end
end
