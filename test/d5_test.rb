require_relative 'test_helper'

class D4Test < Test::Unit::TestCase
  test 'VERSION' do
    assert do
      D4.const_defined?(:VERSION)
    end
  end
end
