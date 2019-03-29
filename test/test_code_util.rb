require_relative "helper"
require "maccro/code_util"

class CodeUtilTest < ::Test::Unit::TestCase
  text1 = "0123456789\n0123456789\n0123456789\n0123456789\n"
  text2 = "\n\n\n\n0123456789\n1"
  text3 = "0123456789\n\n\n0123456789\n0123456789\n\n\n0123456789\n"

  data(
    case1: [text1, 0, 1, 0],
    case2: [text1, 11, 2, 0],
    case3: [text1, 16, 2, 5],
    case4: [text2, 7, 5, 3],
    case5: [text2, 15, 6, 0],
    case6: [text3, 35, 6, 0],
  )
  test 'code_position_to_index' do |data|
    source, expected_index, lineno, column = data
    assert_equal expected_index, Maccro::CodeUtil.code_position_to_index(source, lineno, column)
  end
end
