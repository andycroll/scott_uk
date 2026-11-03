# frozen_string_literal: true

module ScottUk
  # @api private
  module Internal
    module Parser
      # Parses one showtime from the feed into performance attributes
      class Showtime
        # Showtime flags and the variants they mean. Others, such as 'STB'
        # (strobe lighting), 'ATF' (all tickets £5), 'LUX' and 'DOL' (screen
        # formats), are not variants.
        FLAGS = {
          'AFS' => 'relaxed',
          'ART' => 'arts',
          'BAL' => 'arts',
          'ECA' => 'arts',
          'ETV' => 'arts',
          'MSC' => 'arts',
          'MUS' => 'arts',
          'OPE' => 'arts',
          'PBB' => 'baby',
          'SSC' => 'senior',
          'THE' => 'arts'
        }.freeze

        # Yes/no fields and the variants they mean. Most screenings offer
        # audio description, so it does not mark one out.
        FIELDS = {
          'AFS' => 'relaxed',
          'subtitles' => 'subtitled'
        }.freeze

        YES = 'Y'
        FESTIVAL_FLAG = 'EVF'
        FESTIVAL = 'Exmouth Film Festival'
        THREE_D = /\A3D\z/i
        LANGUAGE = /\((#{Cinebase::TitleSanitizer::LANGUAGES.join('|')})\)/i

        # @param [Hash] showtime one showtime from the feed's schedule
        # @param [Hash] film the feed's film for the showtime
        # @param [Time] starting_at from the showtime's Unix timestamp
        def initialize(showtime, film:, starting_at:)
          @showtime = showtime
          @film = film
          @starting_at = starting_at
        end

        # @return [Hash] options for ScottUk::Performance.new
        def to_hash
          {
            booking_url: @showtime['booking_url'],
            dimension: @showtime['performance_type'].to_s.match?(THREE_D) ? '3d' : '2d',
            festival: festival,
            film_name: TitleSanitizer.new(title).sanitized,
            film_year: Cinebase::TitleSanitizer.film_year(title),
            language: title[LANGUAGE, 1],
            starting_at: @starting_at,
            title: title,
            variant: variant
          }
        end

        private

        def flags
          Array(@showtime['flags'])
        end

        def festival
          if flags.include?(FESTIVAL_FLAG)
            Cinebase::Festival.new(name: FESTIVAL, year: @starting_at.year)
          else
            Cinebase::Festival.from_title(title, year: @starting_at.year)
          end
        end

        def title
          @title ||= CGI.unescapeHTML(@film.fetch('name')).strip
        end

        def variant
          from_fields = FIELDS.filter_map { |field, variant| variant if @showtime[field] == YES }
          (flags.filter_map { |flag| FLAGS[flag] } + from_fields).uniq
        end
      end
    end
  end
end
