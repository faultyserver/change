require "./spec_helper"

private def test_valid_cast(value, type, expected_value, line=__LINE__, file=__FILE__, end_line=__END_LINE__)
  it("casts `#{value.inspect}` to #{type} as #{expected_value}", line: line, file: file, end_line: end_line) do
    valid, casted = Change::TypeCast.cast(value, type)
    valid.should eq(true)
    casted.class.should eq(type) unless expected_value.nil?
    casted.should eq(expected_value)
  end
end

private def test_valid_cast_block(value, type : T.class, line=__LINE__, file=__FILE__, end_line=__END_LINE__, &validator : T? -> Bool) forall T
  it("casts `#{value.inspect}` to #{type} with validator", line: line, file: file, end_line: end_line) do
    valid, casted = Change::TypeCast.cast(value, type)
    valid.should eq(true)
    casted.class.should eq(type)
    validator.call(casted).should eq(true)
  end
end

private def test_invalid_cast(value, type, line=__LINE__, file=__FILE__, end_line=__END_LINE__)
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
  test_valid_cast(nil,   Nil, nil)
  test_invalid_cast("hello",    Nil)
  test_invalid_cast(:hello,     Nil)
  test_invalid_cast(23,         Nil)
  test_invalid_cast(23_i64,     Nil)
  test_invalid_cast(23.45,      Nil)
  test_invalid_cast(23.0_f64,   Nil)
  test_invalid_cast(true,       Nil)
  test_invalid_cast(false,      Nil)

  ## Casts from nil
  test_valid_cast(nil,   Nil, nil)
  test_valid_cast(nil,   Bool, nil)
  test_valid_cast(nil,   String, nil)
  test_valid_cast(nil,   Int32, nil)
  test_valid_cast(nil,   Int64, nil)
  test_valid_cast(nil,   Float32, nil)
  test_valid_cast(nil,   Float64, nil)


  ## Casts to Bool
  test_valid_cast(false,      Bool, false)
  test_valid_cast(true,       Bool, true)
  # Allow string representations
  test_valid_cast("false",    Bool, false)
  test_valid_cast("true",     Bool, true)
  # Everything else is not allowed
  test_invalid_cast(:hello,     Bool)
  test_invalid_cast(0,          Bool)
  test_invalid_cast(23,         Bool)
  test_invalid_cast(23_i64,     Bool)
  test_invalid_cast(0.00,       Bool)
  test_invalid_cast(23.45,      Bool)
  test_invalid_cast(23.0_f64,   Bool)


  ## Casts to Strings
  test_valid_cast("hello",    String, "hello")
  test_valid_cast(:hello,     String, "hello")
  test_valid_cast(23,         String, "23")
  test_valid_cast(23_i64,     String, "23")
  test_valid_cast(23.45,      String, "23.45")
  test_valid_cast(23.0_f64,   String, "23.0")


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
  test_invalid_cast("nan",    Int32)
  # Symbols are not considered integers when casting
  test_invalid_cast(:hello, Int32)
  test_invalid_cast(:_123,  Int32)
  test_invalid_cast(:"123", Int32)
  # # TODO: Int64#to_i32 just wraps on overflow? Should be the other way around.
  # test_invalid_cast(Int64::MAX, Int32)


  ## Casts to Floats
  test_valid_cast(23.45,      Float64, 23.45)
  test_valid_cast(-12.251,    Float64, -12.251)
  test_valid_cast("23.45",    Float64, 23.45)
  test_valid_cast("-12.251",  Float64, -12.251)
  test_valid_cast_block("NaN",  Float64){ |v| !v.nil? && !!v.nan? }
  test_valid_cast_block("NaN",  Float32){ |v| !v.nil? && !!v.nan? }
  test_valid_cast_block("infinity",  Float64){ |v| !v.nil? && !!v.infinite? }
  test_valid_cast_block("infinity",  Float32){ |v| !v.nil? && !!v.infinite? }

  # Float32s can't always be represented by Float64s. These numbers are
  # specifically used to have the same representation
  test_valid_cast(23.5_f32,   Float64, 23.5)
  test_valid_cast(-12.25_f32, Float64, -12.25)
  test_valid_cast(23,         Float64, 23.0)
  test_valid_cast(-12,        Float64, -12)
  test_invalid_cast("nop",    Float64)
end
