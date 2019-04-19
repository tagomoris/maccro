require_relative "helper"
require "maccro/builtin"

class BuiltinTestCase < ::Test::Unit::TestCase
  suppress_warning do
    require_relative "examples/builtin"
  end

  sub_test_case 'continuing less/greater-than or equal-to' do
    test 'less_than_2' do
      rules = Maccro::Builtin.rules(:less_than_2)
      Maccro.apply(BuiltinExamples, BuiltinExamples.instance_method(:m_less_than_2), rules: rules)
      assert BuiltinExamples.new.m_less_than_2(0, 2)
    end

    test 'less_than_3' do
      rules = Maccro::Builtin.rules(:less_than_2)
      code = Maccro.apply(BuiltinExamples, BuiltinExamples.instance_method(:m_less_than_3), rules: rules, get_code: true)
      expected_code = <<CODE.chomp
  def m_less_than_3(x, y)
    if true && ((1 < x && x < y) && y < 4)
      true
    else
      false
    end
  end
CODE
      assert_equal expected_code, code
      Maccro.apply(BuiltinExamples, BuiltinExamples.instance_method(:m_less_than_3), rules: rules)
      assert BuiltinExamples.new.m_less_than_3(2, 3)
    end

    test 'combination_less_than_or_equal_to' do
      rules = Maccro::Builtin.rules(:less_than_2, :less_than_or_equal_to_2, :less_than_and_equal_to_a, :less_than_and_equal_to_b)
      code = Maccro.apply(BuiltinExamples, BuiltinExamples.instance_method(:m_less_than_and_equal_to), rules: rules, get_code: true)
      expected_code = <<CODE.chomp
  def m_less_than_and_equal_to
    if true && ((1 <= 2 && 2 < 3) && (3 < 4 && 4 <= 4) && 4 < 5)
      true
    else
      false
    end
  end
CODE
      assert_equal expected_code, code
      Maccro.apply(BuiltinExamples, BuiltinExamples.instance_method(:m_less_than_and_equal_to), rules: rules)
      assert BuiltinExamples.new.m_less_than_and_equal_to
    end
  end

  sub_test_case 'mathematic intervals' do
  end

  sub_test_case 'ActiveRecord utilities' do
    test 'ar_where_equal_to' do
      rules = Maccro::Builtin.rules(:activerecord_utilities)
      code = Maccro.apply(BuiltinExamples, BuiltinExamples.instance_method(:m_ar_where_equal_to), rules: rules, get_code: true)
      expected_code = <<CODE.chomp
  def m_ar_where_equal_to(i)
    Rows.where({:col1 => i})
  end
CODE
      assert_equal expected_code, code
    end

    test 'ar_where_not_equal_to' do
      rules = Maccro::Builtin.rules(:activerecord_utilities)
      code = Maccro.apply(BuiltinExamples, BuiltinExamples.instance_method(:m_ar_where_not_equal_to), rules: rules, get_code: true)
      expected_code = <<CODE.chomp
  def m_ar_where_not_equal_to(i)
    Rows.where(["\#{:col1} != ?", i])
  end
CODE
      assert_equal expected_code, code
    end

    test 'ar_where_in_range_exclusive' do
      rules = Maccro::Builtin.rules(:activerecord_utilities)
      code = Maccro.apply(BuiltinExamples, BuiltinExamples.instance_method(:m_ar_where_in_range_exclusive), rules: rules, get_code: true)
      expected_code = <<CODE.chomp
  def m_ar_where_in_range_exclusive(x, y)
    Rows.where({:id => [(x)...(y)]})
  end
CODE
      assert_equal expected_code, code
    end

    test 'ar_where_in_range_inclusive' do
      rules = Maccro::Builtin.rules(:activerecord_utilities)
      code = Maccro.apply(BuiltinExamples, BuiltinExamples.instance_method(:m_ar_where_in_range_inclusive), rules: rules, get_code: true)
      expected_code = <<CODE.chomp
  def m_ar_where_in_range_inclusive(x, y)
    Rows.where({:id => [(x)..(y)]})
  end
CODE
      assert_equal expected_code, code
    end

    test 'ar_where_and_chain, once' do
      rules = Maccro::Builtin.rules(:activerecord_utilities)
      code = Maccro.apply(BuiltinExamples, BuiltinExamples.instance_method(:m_ar_and_chain_1), rules: rules, get_code: true)
      expected_code = <<CODE.chomp
  def m_ar_and_chain_1
    Rows.where(:x).where(:y)
  end
CODE
      assert_equal expected_code, code
    end

    test 'ar_where_and_chain, twice' do
      rules = Maccro::Builtin.rules(:activerecord_utilities)
      code = Maccro.apply(BuiltinExamples, BuiltinExamples.instance_method(:m_ar_and_chain_2), rules: rules, get_code: true)
      expected_code = <<CODE.chomp
  def m_ar_and_chain_2
    Rows.where(:x).where(:y).where(:z)
  end
CODE
      assert_equal expected_code, code
    end

    test 'ar_where_or_chain, once' do
      rules = Maccro::Builtin.rules(:activerecord_utilities)
      code = Maccro.apply(BuiltinExamples, BuiltinExamples.instance_method(:m_ar_or_chain_1), rules: rules, get_code: true)
      expected_code = <<CODE.chomp
  def m_ar_or_chain_1
    Rows.where(:x).or(Rows.where(:y))
  end
CODE
      assert_equal expected_code, code
    end

    test 'ar_where_or_chain, twice' do
      rules = Maccro::Builtin.rules(:activerecord_utilities)
      code = Maccro.apply(BuiltinExamples, BuiltinExamples.instance_method(:m_ar_or_chain_2), rules: rules, get_code: true)
      expected_code = <<CODE.chomp
  def m_ar_or_chain_2
    Rows.where(:x).or(Rows.where(:y)).or(Rows.where(:z))
  end
CODE
      assert_equal expected_code, code
    end

    test 'ar_complex: and-connected' do
      rules = Maccro::Builtin.rules(:activerecord_utilities)
      code = Maccro.apply(BuiltinExamples, BuiltinExamples.instance_method(:m_ar_complex_1), rules: rules, get_code: true)
      expected_code = <<CODE.chomp
  def m_ar_complex_1
    Rows.where({:id => [(min)...(max)]}).where(["\#{:name} != ?", my_name]).where(["\#{:age} > ?", my_age])
  end
CODE
      assert_equal expected_code, code
    end

    test 'ar_complex: or-connected' do
      rules = Maccro::Builtin.rules(:activerecord_utilities)
      code = Maccro.apply(BuiltinExamples, BuiltinExamples.instance_method(:m_ar_complex_2), rules: rules, get_code: true)
      expected_code = <<CODE.chomp
  def m_ar_complex_2
    Rows.where({:name => "MyName"}).or(Rows.where(["\#{:level} >= ?", 2]))
  end
CODE
      assert_equal expected_code, code
    end
  end
end




