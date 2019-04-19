class BuiltinExamples
  # less_than_2: ['e1 < e2 < e3', '(e1 < e2 && e2 < e3)'],
  def m_less_than_2(x, y)
    if x < 1 < y && true
      true
    else
      false
    end
  end

  def m_less_than_3(x, y)
    if true && 1 < x < y < 4
      true
    else
      false
    end
  end

  def m_less_than_and_equal_to
    if true && 1 <= 2 < 3 < 4 <= 4 < 5
      true
    else
      false
    end
  end

  # less_than_or_equal_to_2: ['e1 <= e2 <= e3', '(e1 <= e2 && e2 <= e3)'],
  # greater_than_2: ['e1 > e2 > e3', '(e1 > e2 && e2 > e3)'],
  # greater_than_or_equal_to_2: ['e1 >= e2 >= e3', '(e1 >= e2 && e2 >= e3)'],

  # less_than_3: ['e1 < e2 < e3 < e4', '(e1 < e2 && e2 < e3 && e3 < e4)'],
  # less_than_or_equal_to_3: ['e1 <= e2 <= e3 <= e4', '(e1 <= e2 && e2 <= e3 && e3 <= e4)'],
  # greater_than_3: ['e1 > e2 > e3 > e4', '(e1 > e2 && e2 > e3 && e3 > e4)'],
  # greater_than_or_equal_to_3: ['e1 >= e2 >= e3 >= e4', '(e1 >= e2 && e2 >= e3 && e3 >= e4)'],

  # less_than_4: ['e1 < e2 < e3 < e4 < e5', '(e1 < e2 && e2 < e3 && e3 < e4 && e4 < e5)'],
  # less_than_or_equal_to_4: ['e1 <= e2 <= e3 <= e4 <= e5', '(e1 <= e2 && e2 <= e3 && e3 <= e4 && e4 <= e5)'],
  # greater_than_4: ['e1 > e2 > e3 > e4 > e5', '(e1 > e2 && e2 > e3 && e3 > e4 && e4 > e5)'],
  # greater_than_or_equal_to_4: ['e1 >= e2 >= e3 >= e4', '(e1 >= e2 && e2 >= e3 && e3 >= e4 && e4 >= e5)'],

  # open_interval: ['e1 < e2 < e3', '(e1 < e2 && e2 < e3)'],
  # closed_interval: ['e1 <= e2 <= e3', '(e1 <= e2 && e2 <= e3)'],
  # left_closed_interval: ['e1 <= e2 < e3', '(e1 <= e2 && e2 < e3)'],
  # right_closed_interval: ['e1 < e2 <= e3', '(e1 < e2 && e2 <= e3)'],

  # ar_where_equal_to: ['v1 == e1', '{v1 => e1}', {under: 'e1.where($TARGET)'}],
  def m_ar_where_equal_to(i)
    Rows.where(:col1 == i)
  end

  # :ar_where_not_equal_to, ['v1 != e1', '"#{v1} != ?", e1', {under: 'e1.where($TARGET)'}],
  def m_ar_where_not_equal_to(i)
    Rows.where(:col1 != i)
  end

  # :ar_where_larger_than, ['v1 > e1', '"#{v1} > ?", e1', {under: 'e1.where($TARGET)'}],
  # :ar_where_larger_than_or_equal_to, ['v1 >= e1', '"#{v1} >= ?", e1', {under: 'e1.where($TARGET)'}],
  # :ar_where_less_than, ['v1 < e1', '"#{v1} < ?", e1', {under: 'e1.where($TARGET)'}],
  # :ar_where_less_than_or_equal_to, ['v1 <= e1', '"#{v1} <= ?", e1', {under: 'e1.where($TARGET)'}],

  # :ar_where_in_range_exclusive, ['e1 <= v1 < e2', 'v1 => [e1...e2]', {under: 'e1.where($TARGET)'}],
  def m_ar_where_in_range_exclusive(x, y)
    Rows.where(x <= :id < y)
  end

  # :ar_where_in_range_inclusive, ['e1 <= v1 <= e2', 'v1 => [e1..e2]', {under: 'e1.where($TARGET)'}],
  def m_ar_where_in_range_inclusive(x, y)
    Rows.where(x <= :id <= y)
  end

  # :ar_and_chain, ['e1.where(e2 and e3)', 'e1.where(e2).where(e3)'],
  def m_ar_and_chain_1
    Rows.where(:x && :y)
  end

  def m_ar_and_chain_2
    Rows.where((:x and :y and :z))
  end

  # :ar_or_chain, ['e1.where(e2 or e3)', 'e1.where(e2).or(e1.where(e3))'],
  def m_ar_or_chain_1
    Rows.where(:x || :y)
  end

  def m_ar_or_chain_2
    Rows.where((:x or :y or :z))
  end

  def m_ar_complex_1
    Rows.where(
      min <= :id < max &&
      :name != my_name &&
      :age > my_age
    )
  end

  def m_ar_complex_2
    Rows.where(
      :name == "MyName" ||
      :level >= 2
    )
  end

  ## TODO: find a way to implement this
  #
  # def m_ar_complex_3
  #   Rows.where(:age >= 30 && (:level >= 2 || :type == :admin))
  # end
  #
  # def m_ar_complex_4
  #   Rows.where(:age >= 30 || (:level >= 2 && :type == :admin))
  # end
end
