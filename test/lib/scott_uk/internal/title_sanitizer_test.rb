require_relative '../../../test_helper'

class ScottUk::Internal::TitleSanitizerTest < Minitest::Test
  def test_plain_titles_are_unchanged
    assert_sanitized 'Ghosts: The Possession of Button House', 'Ghosts: The Possession of Button House'
    assert_sanitized "Andrew Lloyd Webber's Starlight Express - Live On Stage",
                     "Andrew Lloyd Webber's Starlight Express - Live On Stage"
  end

  def test_parent_and_baby_suffix
    assert_sanitized 'Ghosts: The Possession of Button House',
                     'Ghosts: The Possession of Button House (Parent and Baby Only Show)'
  end

  def test_exmouth_film_festival_suffix
    assert_sanitized 'The Ballad of Wallis Island', 'The Ballad of Wallis Island (Exmouth Film Festival)'
    assert_sanitized 'DEREK VS DEREK', 'DEREK VS DEREK - EXMOUTH FILM FESTIVAL'
    assert_sanitized 'Rose of Nevada', 'Rose of Nevada - Exmouth Film Festival'
  end

  def test_film_society_prefix
    assert_sanitized 'Barry Lyndon', 'SFS: Barry Lyndon'
  end

  def test_royal_ballet_and_opera
    assert_sanitized 'Royal Ballet and Opera: THE NUTCRACKER', 'RBO 26-27: THE NUTCRACKER'
  end

  def test_national_theatre_live
    assert_sanitized 'National Theatre Live: HAY FEVER', 'NATIONAL THEATRE LIVE: HAY FEVER'
  end

  def test_film_years
    assert_sanitized 'The Evil Dead', 'The Evil Dead (1981)'
  end

  private

  def assert_sanitized(expected, title)
    assert_equal expected, ScottUk::Internal::TitleSanitizer.new(title).sanitized
  end
end
