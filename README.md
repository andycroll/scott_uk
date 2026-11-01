# ScottUk

A simple gem to pull cinemas and performances from the [Scott Cinemas website](https://www.scottcinemas.co.uk) and spit out useful formatted info.

## Installation

Add this line to your application's Gemfile:

    gem 'scott_uk'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scott_uk

## Usage

The gem conforms to the API set down in the `cinebase` gem, [andycroll/cinebase](https://github.com/andycroll/cinebase), which provides a lot of useful base vocabulary and repetitive code for this series of cinema focussed gems.

Performance titles are sanitized as much as possible, removing years,
festival suffixes, the parent and baby suffix and the film society prefix,
and naming National Theatre Live and Royal Ballet and Opera screenings in
full.

No token or setup is needed. Scott Cinemas publishes a JSON feed of each
venue's listings, documented at https://www.scottcinemas.co.uk/api. Tickets
are sold through TapOS, behind each venue's own booking pages.

### Cinema

The website keeps the chosen cinema in a cookie and has no plain list of
venues, so the gem holds them: names, addresses and feed codes from the
website's cinema and API pages, and coordinates from its cinema finder. Cinema
methods make no requests. The four WTW cinemas in Cornwall, which share the
website's cinema menu, run a separate site and are not included.

``` ruby
ScottUk::Cinema.all
#=> [<ScottUk::Cinema ...>, <ScottUk::Cinema ...>, ...]

cinema = ScottUk::Cinema.new('SCOBWR')
#=> <ScottUk::Cinema ...>

cinema.adr
#=> {
  street_address:   'Northgate Yard',
  extended_address: 'Mount Street',
  locality:         'Bridgwater',
  region:           'Somerset',
  postal_code:      'TA6 3FQ',
  country_name:     'United Kingdom'
}

cinema.brand
#=> 'Scott Cinemas'

cinema.full_name
#=> 'Scott Cinemas Bridgwater'

cinema.id
#=> 'SCOBWR'

cinema.latitude
#=> 51.12985

cinema.url
#=> 'https://bridgwater.scottcinemas.co.uk'
```

### Performances

`Performance.at` returns performances for an inclusive range of showing dates,
defaulting to today in London and the following 13 days. The venue's feed
holds every advertised date, so any range is one request.

``` ruby
ScottUk::Performance.at('SCOBWR', from: Date.today, to: Date.today + 2)
#=> [<ScottUk::Performance ...>, <ScottUk::Performance ...>, ...]

performance = ScottUk::Performance.at('SCOBWR').first
#=> <ScottUk::Performance ...>

performance.film_name
#=> 'Ghosts: The Possession of Button House' # from '... (Parent and Baby Only Show)'

performance.film_year
#=> nil # from the title, e.g. 1975 for 'Barry Lyndon (1975)'

performance.dimension
#=> '2d'

performance.variant
#=> ['baby']

performance.subtitled?
#=> false

performance.festival
#=> nil # e.g. #<data Cinebase::Festival name="Exmouth Film Festival", year=2026>

performance.starting_at
#=> 2026-11-04 11:00:00 UTC

performance.booking_url
#=> 'https://bridgwater.scottcinemas.co.uk/book-now/ghosts-the-possession-parent-baby/76429'

performance.cinema_name
#=> 'Bridgwater'

performance.cinema_id
#=> 'SCOBWR'
```

Booking links are the feed's own, to the venue's booking page, which holds
the TapOS seat selection.

Variants come from the feed's flags and fields: `arts` (event cinema:
theatre, opera, ballet, musicals, music, art and television), `baby`,
`relaxed` (autism friendly), `senior` (Silver Screen) and `subtitled`. Most
screenings offer audio description, so it is not a variant. Strobe warnings,
ticket offers and premium screens are not variants either.

## Tests

```sh
bundle exec rake          # unit tests against fixtures
bundle exec rake live     # live scottcinemas.co.uk
```

The fixture in `test/fixtures` is Bridgwater's feed, trimmed to a few dates
with shortened descriptions. `test/support/api_shapes.rb` describes the fields
the gem reads. The unit suite checks the fixture against it and the live suite
checks every venue's real feed, held only in memory. When the feed changes,
update the shape first, then the fixture.

## Releasing

Bump the version, merge, then run the **Release Gem** workflow in GitHub
Actions. It runs the tests, tags the version and publishes the gem through
RubyGems trusted publishing.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
