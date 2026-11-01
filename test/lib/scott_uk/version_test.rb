require_relative '../../test_helper'

class ScottUk::VersionTest < Minitest::Test
  def test_version_is_defined
    refute_nil ScottUk::VERSION
  end
end
