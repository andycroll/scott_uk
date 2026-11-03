require_relative '../../../../test_helper'

class ScottUk::Internal::Parser::ShowtimeTest < Minitest::Test
  STARTING_AT = Time.utc(2026, 11, 7, 19, 0)
  SHOWTIME = {
    'performance_type' => '2D', 'AFS' => 'N', 'audio_description' => 'N', 'subtitles' => 'N',
    'flags' => nil, 'booking_url' => 'https://exmouth.scottcinemas.co.uk/book-now/film/1'
  }.freeze

  def test_exmouth_film_festival
    parsed = parse({ 'flags' => ['EVF'] }, 'Rose of Nevada - Exmouth Film Festival')

    assert_equal Cinebase::Festival.new(name: 'Exmouth Film Festival', year: 2026), parsed[:festival]
    assert_equal 'Rose of Nevada', parsed[:film_name]
  end

  def test_festival_prefixes_shared_by_chains
    assert_equal 'Cambridge Film Festival', parse({}, 'CFF: Paddington')[:festival].name
  end

  def test_three_d
    assert_equal '3d', parse({ 'performance_type' => '3D' }, 'Avengers: Doomsday')[:dimension]
  end

  def test_language_and_year_from_the_title
    parsed = parse({}, 'Ramayana: Rise of a Legend (Hindi)')

    assert_equal 'Hindi', parsed[:language]
    assert_equal 'Ramayana: Rise of a Legend', parsed[:film_name]
    assert_equal 1975, parse({}, 'Barry Lyndon (1975)')[:film_year]
  end

  def test_html_entities_are_decoded
    assert_equal 'Exhibition on Screen: Renoir & Love', parse({}, 'Exhibition on Screen: Renoir &amp; Love')[:film_name]
  end

  def test_each_variant_once
    assert_equal %w(relaxed), parse({ 'flags' => ['AFS'], 'AFS' => 'Y' }, 'Ghosts')[:variant]
  end

  def test_performances_read_audience_labels_from_the_title
    parsed = parse({}, 'Ghosts (Parent and Baby Only Show)')
    performance = ScottUk::Performance.new(parsed.merge(cinema_id: 'SCOEXM', cinema_name: 'Exmouth'))

    assert_equal 'Ghosts', performance.film_name
    assert_equal %w(baby), performance.variant
  end

  private

  def parse(showtime, title)
    ScottUk::Internal::Parser::Showtime.new(SHOWTIME.merge(showtime), film: { 'name' => title },
                                                                       starting_at: STARTING_AT).to_hash
  end
end
