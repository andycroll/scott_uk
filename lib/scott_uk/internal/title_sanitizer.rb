module ScottUk
  # Internal utility classes: Do not use
  # @api private
  module Internal
    # Sanitize and standardize film titles
    class TitleSanitizer < Cinebase::TitleSanitizer
      # @!method initialize(title)
      #   Constructor
      #   @param [String] title a film title
      #   @return [ScottUk::Internal::TitleSanitizer]

      # @!method sanitized
      #   sanitized and standardized title
      #   @return [String] sanitised title

      private

      # strings and regex to be removed
      def remove
        [
          /\s*\(Parent and Baby Only Show\)/i,                  # parent and baby screening
          /\s*(?:-\s+|\()Exmouth Film Festival\)?/i,            # festival suffix
          /\ASFS:\s*/                                           # film society prefix
        ] + COMMON_REMOVE
      end

      # regexes and their replacements
      def replace
        {
          /\ARBO \d{2}-\d{2}: (.*)/i            => 'Royal Ballet and Opera: ',
          /\ANATIONAL THEATRE LIVE: (.*)/i      => 'National Theatre Live: '
        }.merge(COMMON_REPLACE)
      end
    end
  end
end
