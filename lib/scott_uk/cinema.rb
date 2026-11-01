module ScottUk
  # The object representing a cinema on the Scott Cinemas website
  class Cinema < Cinebase::Cinema
    # @!attribute [r] id
    #   @return [String] the cinema's feed code, e.g. 'SCOBAR'

    # The website keeps the chosen cinema in a cookie and has no plain venue
    # list, so the gem holds the venues: names, addresses and feed codes
    # from the website's cinema and API pages, coordinates from its cinema
    # finder.
    VENUES = {
      'SCOBAR' => {
        name: 'Barnstaple', subdomain: 'barnstaple', street_address: 'Boutport Street', locality: 'Barnstaple',
        region: 'Devon', postal_code: 'EX31 1SR', latitude: 51.07933, longitude: -4.05859
      },
      'SCOBWR' => {
        name: 'Bridgwater', subdomain: 'bridgwater', street_address: 'Northgate Yard',
        extended_address: 'Mount Street', locality: 'Bridgwater', region: 'Somerset', postal_code: 'TA6 3FQ',
        latitude: 51.12985, longitude: -3.006949
      },
      'SCOORP' => {
        name: 'Bristol, Westbury Park', subdomain: 'bristolwestburypark', street_address: 'Northumbria Drive',
        extended_address: 'Westbury Park', locality: 'Bristol', postal_code: 'BS9 4HN',
        latitude: 51.480392, longitude: -2.612085
      },
      'SCOEXM' => {
        name: 'Exmouth', subdomain: 'exmouth', street_address: 'Strand Gardens', locality: 'Exmouth',
        region: 'Devon', postal_code: 'EX8 1HP', latitude: 50.619789, longitude: -3.413336
      },
      'SCONEW' => {
        name: 'Newton Abbot', subdomain: 'newtonabbot', street_address: 'Market Street', locality: 'Newton Abbot',
        region: 'Devon', postal_code: 'TQ12 2RB', latitude: 50.530781, longitude: -3.61197
      },
      'SCORAD' => {
        name: 'Sidmouth', subdomain: 'sidmouth', street_address: 'Radway Place', locality: 'Sidmouth',
        region: 'Devon', postal_code: 'EX10 8TL', latitude: 50.682728, longitude: -3.238649
      }
    }.freeze

    ADDRESS_PARTS = %i(street_address extended_address locality region postal_code).freeze

    # Constructor
    # @param [String] id the cinema's feed code, e.g. 'SCOBAR' or 'scobar'
    # @return [ScottUk::Cinema]
    def initialize(id)
      @id = id.to_s.upcase
    end

    # Return basic cinema information for all cinemas
    # @return [Array<ScottUk::Cinema>]
    # @example
    #   ScottUk::Cinema.all
    #   #=> [<ScottUk::Cinema>, <ScottUk::Cinema>, ...]
    def self.all
      VENUES.keys.map { |id| new(id) }
    end

    # @!method address
    #   Address of the cinema
    #   @return [Hash] of different address parts
    #   @see #adr

    # Address of the cinema
    # @return [Hash] contains :street_address, :extended_address,
    # :locality, :region, :postal_code, :country_name
    # @example
    #   cinema = ScottUk::Cinema.new('SCOBWR')
    #   cinema.adr
    #   #=> {
    #         street_address:   'Northgate Yard',
    #         extended_address: 'Mount Street',
    #         locality:         'Bridgwater',
    #         region:           'Somerset',
    #         postal_code:      'TA6 3FQ',
    #         country_name:     'United Kingdom'
    #       }
    # @note Uses method naming as at http://microformats.org/wiki/adr
    def adr
      ADDRESS_PARTS.to_h { |part| [part, venue[part]] }.merge(country_name: 'United Kingdom')
    end

    # Brand of the cinema
    # @return [String] which will always be 'Scott Cinemas'
    def brand
      'Scott Cinemas'.freeze
    end

    # @return [Float, nil]
    def latitude
      venue[:latitude]
    end

    # @return [Float, nil]
    def longitude
      venue[:longitude]
    end

    # The name of the cinema
    # @return [String]
    # @example
    #   ScottUk::Cinema.new('SCOORP').name
    #   #=> 'Bristol, Westbury Park'
    def name
      venue[:name].to_s
    end

    # The url of the cinema's pages on the Scott Cinemas website
    # @return [String]
    # @example
    #   ScottUk::Cinema.new('SCOBAR').url
    #   #=> 'https://barnstaple.scottcinemas.co.uk'
    def url
      subdomain = venue[:subdomain]
      subdomain ? "https://#{subdomain}.scottcinemas.co.uk" : ''
    end

    private

    def venue
      VENUES.fetch(id, {})
    end
  end
end
