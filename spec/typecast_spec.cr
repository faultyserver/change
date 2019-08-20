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
  ###
  # Singular Casts
  ###

  ## Casts to Nil
  # This is to deal with field nilability. Any value can be casted to nil.
  # With this, all other casts should be able to assume non-nilability.
  test_valid_cast("hello",    Nil, nil)
  test_valid_cast(:hello,     Nil, nil)
  test_valid_cast(23,         Nil, nil)
  test_valid_cast(23_i64,     Nil, nil)
  test_valid_cast(23.45,      Nil, nil)
  test_valid_cast(23.0_f64,   Nil, nil)
  test_valid_cast(true,       Nil, nil)
  test_valid_cast(false,      Nil, nil)
  test_valid_cast(nil,        Nil, nil)

  ## Casts to Bool
  # Any value can be casted to a boolean, and is purely based on Crystal's
  # truthiness semantics.
  # Nil and False are the only falsey values
  test_valid_cast(nil,        Bool, false)
  test_valid_cast(false,      Bool, false)
  # Everything else is truthy
  test_valid_cast(true,       Bool, true)
  test_valid_cast("hello",    Bool, true)
  test_valid_cast(:hello,     Bool, true)
  test_valid_cast(0,          Bool, true)
  test_valid_cast(23,         Bool, true)
  test_valid_cast(23_i64,     Bool, true)
  test_valid_cast(0.00,       Bool, true)
  test_valid_cast(23.45,      Bool, true)
  test_valid_cast(23.0_f64,   Bool, true)


  ## Casts to Strings
  test_valid_cast("hello",    String, "hello")
  test_valid_cast(:hello,     String, "hello")
  test_valid_cast(23,         String, "23")
  test_valid_cast(23_i64,     String, "23")
  test_valid_cast(23.45,      String, "23.45")
  test_valid_cast(23.0_f64,   String, "23.0")
  test_invalid_cast(nil, String)


  ## Casts to Ints
  test_valid_cast(23,         Int32, 23)
  test_valid_cast("23",       Int32, 23)
  test_valid_cast(23_i64,     Int32, 23)
  test_valid_cast(23_i8,      Int32, 23)
  test_valid_cast(-23,        Int32, -23)
  test_valid_cast("-23",      Int32, -23)
  test_valid_cast(-23_i64,    Int32, -23)
  test_valid_cast(-23_i8,     Int32, -23)
  test_valid_cast(23.00,      Int32, 23)
  test_invalid_cast(nil, Int32)
  # # TODO: Int64#to_i32 just wraps on overflow? Should be the other way around.
  # test_invalid_cast(Int64::MAX, Int32)


  ## Casts to Floats
  test_valid_cast(23.45,      Float64, 23.45)
  test_valid_cast(-12.251,    Float64, -12.251)
  test_valid_cast("23.45",    Float64, 23.45)
  test_valid_cast("-12.251",  Float64, -12.251)
  # Float32s can't always be represented by Float64s. These numbers are
  # specifically used to have the same representation
  test_valid_cast(23.0_f32,   Float64, 23.0)
  test_valid_cast(-12.25_f32, Float64, -12.25)
  test_invalid_cast(nil, Float64)
end
