require "./spec_helper"

def test_valid_cast(value, type, expected_value, line=__LINE__, file=__FILE__, end_line=__END_LINE__)
  it("casts `#{value.inspect}` to #{type} as #{expected_value}", line: line, file: file, end_line: end_line) do
    valid, casted = Change::TypeCast.cast(value, type)
    valid.should eq(true)
    casted.class.should eq(type)
    casted.should eq(expected_value)
  end
end

def test_invalid_cast(value, type, line=__LINE__, file=__FILE__, end_line=__END_LINE__)
  it("fails to cast `#{value.inspect}` to #{type}", line: line, file: file, end_line: end_line) do
    valid, casted = Change::TypeCast.cast(value, type)
    valid.should eq(false)
  end
end


describe Change::TypeCast do
  ## Casts to Nil
  # This is to deal with field nilability. Any value can be casted to nil.
  # With this, all other casts should be able to assume non-nilability.
  test_valid_cast("hello",    Nil, nil)
  test_valid_cast(:hello,     Nil, nil)
  test_valid_cast(23,         Nil, nil)
  test_valid_cast(23_i64,     Nil, nil)
  test_valid_cast(23.45,      Nil, nil)
  test_valid_cast(23.0_f64,   Nil, nil)
  test_valid_cast(nil,        Nil, nil)


  ## Casts to Strings
  test_valid_cast("hello",    String, "hello")
  test_valid_cast(:hello,     String, "hello")
  test_valid_cast(23,         String, "23")
  test_valid_cast(23_i64,     String, "23")
  test_valid_cast(23.45,      String, "23.45")
  test_valid_cast(23.0_f64,   String, "23.0")
  # Casting nil into any value is invalid
  test_invalid_cast(nil, String)


  ## Casts to Ints
  test_valid_cast(23,         Int32, 23)
  test_valid_cast("23",       Int32, 23)
  test_valid_cast(23_i64,     Int32, 23)
  test_valid_cast(23_i8,      Int32, 23)
  # nilability
  test_invalid_cast(nil, Int32)
  # Too large of a value
  # TODO: Int64#to_i32 just wraps on overflow? Should be the other way around.
  # test_invalid_cast(Int64::MAX, Int32)
end
