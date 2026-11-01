# The parts of Scott Cinemas' JSON feed the gem reads. Checked against the
# trimmed fixture and, in the live suite, against real feeds held only in
# memory.
module ApiShapes
  YES_NO = /\A[YN]\z/
  BOOKING_URL = %r{\Ahttps://[a-z]+\.scottcinemas\.co\.uk/book-now/[\w-]+/\d+\z}

  private

  def assert_feed_shape(feed, code)
    assert_equal code, feed.fetch('cinema')
    films = feed.fetch('films')
    refute_empty films
    films.each_value { |film| assert_kind_of String, film.fetch('name') }
    showtimes = feed.fetch('schedule').flat_map do |midnight, screens|
      assert_match(/\A\d{10}\z/, midnight)
      screens.values.flat_map(&:to_a)
    end
    refute_empty showtimes
    showtimes.each { |timestamp, showtime| assert_showtime_shape(timestamp, showtime, films) }
  end

  def assert_showtime_shape(timestamp, showtime, films)
    assert_match(/\A\d{10}\z/, timestamp)
    assert films.key?(showtime.fetch('film_id'))
    assert_match(/\A[23]D\z/, showtime.fetch('performance_type'))
    %w(AFS audio_description subtitles).each { |field| assert_match YES_NO, showtime.fetch(field) }
    flags = showtime.fetch('flags')
    assert(flags.nil? || flags.all? { |flag| flag.match?(/\A[A-Z]{3}\z/) })
    assert_match BOOKING_URL, showtime.fetch('booking_url')
  end
end
