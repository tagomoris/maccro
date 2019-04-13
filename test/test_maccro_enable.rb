require_relative "helper"
require "maccro"

class MaccroEnableTestCase < ::Test::Unit::TestCase
  test 'enable rules on a module' do
    dirty_load File.join(__dir__, "examples", "enable_on_module.rb")
    assert_equal "yay", EnableOnModule.foo
  end

  test 'enable rules on a path' do
    dirty_load File.join(__dir__, "examples", "enable_on_path.rb")
    assert_equal "yay", EnableOnPath1.foo
    assert_equal "yay", EnableOnPath2.foo
  end
end
