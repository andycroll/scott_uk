require 'cgi/escape'
require 'json'

require 'cinebase'

require_relative './scott_uk/version'

require_relative './scott_uk/internal/feed'
require_relative './scott_uk/internal/title_sanitizer'
require_relative './scott_uk/internal/parser/showtime'

require_relative './scott_uk/cinema'
require_relative './scott_uk/performance'

# scott_uk gem
module ScottUk
end
