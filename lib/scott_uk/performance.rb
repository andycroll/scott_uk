module ScottUk
  # A single screening of a film on the Scott Cinemas website
  class Performance < Cinebase::Performance
    # @!attribute [r] booking_url
    #   @return [String] the booking URL on the cinema website
    # @!attribute [r] cinema_name
    #   @return [String] the cinema name
    # @!attribute [r] cinema_id
    #   @return [String] the cinema id
    # @!attribute [r] dimension
    #   @return [String] 2d or 3d
    # @!attribute [r] film_name
    #   @return [String] the film name

    # @!method initialize(options)
    #   @param [Hash] options options hash
    #   @option options [String] :booking_url (nil) buying url for the screening
    #   @option options [String] :cinema_name name of the cinema
    #   @option options [String] :cinema_id website id of the cinema
    #   @option options [String] :dimension ('2d') dimension of the screening
    #   @option options [Cinebase::Festival] :festival (nil) festival edition
    #   @option options [String] :film_name name of the film
    #   @option options [Integer] :film_year (nil) year from the film's title
    #   @option options [String] :language (nil) audio language, e.g. 'Hindi'
    #   @option options [Time] :starting_at listed start time of the performance

    # Performances within an inclusive range of showing dates, from one
    # request: the venue's feed holds every advertised date.
    # @param [String] cinema_id the cinema's feed code, e.g. 'SCOBAR'
    # @param [Date] from first date (defaults to today in London)
    # @param [Date] to last date (defaults to 13 days after from)
    # @return [Array<ScottUk::Performance>]
    def self.at(
      cinema_id,
      from: Cinebase::London.today,
      to: from + 13
    )
      raise ArgumentError, 'to must not precede from' if to < from

      cinema = Cinema.new(cinema_id)
      if cinema.name.empty?
        []
      else
        feed = ScottUk::Internal::Feed.new.listings(cinema.id)
        performances = showtimes_between(feed, from, to).map do |showtime, film, starting_at|
          parsed = ScottUk::Internal::Parser::Showtime.new(showtime, film: film, starting_at: starting_at)
          new(parsed.to_hash.merge(cinema_id: cinema.id, cinema_name: cinema.name))
        end
        performances.sort_by(&:starting_at)
      end
    end

    # @!method showing_on
    #   The date of the screening
    #   @return [Date]

    # @!method starting_at
    #   UTC time of the screening
    #   @return [Time]

    # @!method variant
    #   The kinds of screening (arts, audio_described, baby, relaxed ...)
    #   @return <Array[String]>

    # PHP sends an empty schedule, day or screen as [] rather than {}
    def self.showtimes_between(feed, from, to)
      films = Hash(feed['films'])
      Hash(feed['schedule']).flat_map do |midnight, screens|
        if (from..to).cover?(Cinebase::London.date(Time.at(midnight.to_i)))
          Hash(screens).values.flat_map do |showtimes|
            Hash(showtimes).filter_map do |timestamp, showtime|
              film = films[showtime['film_id']]
              [showtime, film, Time.at(timestamp.to_i).utc] if film
            end
          end
        else
          []
        end
      end
    end
    private_class_method :showtimes_between
  end
end
