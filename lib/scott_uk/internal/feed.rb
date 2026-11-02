# frozen_string_literal: true

module ScottUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Reads Scott Cinemas' public JSON listings feed, documented at
    # https://www.scottcinemas.co.uk/api. Each venue's feed holds every
    # advertised date.
    class Feed
      URL = 'https://www.scottcinemas.co.uk/json.php'

      def initialize
        @http = Cinebase::Http.new
      end

      # @param [String] code a venue's feed code, e.g. 'SCOBAR'
      # @return [Hash] the feed: 'cinema', 'films' by id, and 'schedule' of
      #   showtimes by local midnight, then screen, then start, each a Unix
      #   timestamp
      def listings(code)
        JSON.parse(@http.get("#{URL}?cinema=#{CGI.escape(code)}"))
      end
    end
  end
end
