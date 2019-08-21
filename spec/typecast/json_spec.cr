require "../spec_helper"
require "../../src/change/typecast/json"

private def test_valid_cast(value, type, expected_value, *, line=__LINE__, file=__FILE__, end_line=__END_LINE__)
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
  describe "casts from JSON" do
    # Everything can be casted from Nil, but not to it
    test_valid_cast(JSON::Any.new(nil),   Nil, nil)
    test_valid_cast(JSON::Any.new(nil),   Bool, nil)
    test_valid_cast(JSON::Any.new(nil),   String, nil)
    test_valid_cast(JSON::Any.new(nil),   Int32, nil)
    test_valid_cast(JSON::Any.new(nil),   Int64, nil)
    test_valid_cast(JSON::Any.new(nil),   Float32, nil)
    test_valid_cast(JSON::Any.new(nil),   Float64, nil)

    test_invalid_cast(JSON::Any.new(true),      Nil)
    test_invalid_cast(JSON::Any.new(false),     Nil)
    test_invalid_cast(JSON::Any.new("hello"),   Nil)
    test_invalid_cast(JSON::Any.new(1234_i64),  Nil)
    test_invalid_cast(JSON::Any.new(12.34),     Nil)

    # Direct type casts always succeed
    test_valid_cast(JSON::Any.new(true),      Bool, true)
    test_valid_cast(JSON::Any.new(false),     Bool, false)
    test_valid_cast(JSON::Any.new("hello"),   String, "hello")
    test_valid_cast(JSON::Any.new(1234_i64),  Int32, 1234)
    test_valid_cast(JSON::Any.new(12.34),     Float64, 12.34)

    # Up and down casts of numbers should succeed
    test_valid_cast(JSON::Any.new(1234_i64),  Int64, 1234)
    test_valid_cast(JSON::Any.new(12.34),     Float32, 12.34_f32)

    # JSON cross-conversions match primitive types
    test_valid_cast(JSON::Any.new("true"),  Bool, true)
    test_valid_cast(JSON::Any.new("false"), Bool, false)
    test_invalid_cast(JSON::Any.new("hello"), Bool)
    test_invalid_cast(JSON::Any.new(123_i64), Bool)
    test_invalid_cast(JSON::Any.new(0_i64),   Bool)
    test_invalid_cast(JSON::Any.new(123.45),  Bool)
    test_invalid_cast(JSON::Any.new(0.0),     Bool)

    test_valid_cast(JSON::Any.new("123"),   Int32, 123)
    test_valid_cast(JSON::Any.new("-400"),  Int32, -400)
    test_valid_cast(JSON::Any.new("123"),   Int64, 123_i64)
    test_valid_cast(JSON::Any.new("-400"),  Int64, -400_i64)
    test_invalid_cast(JSON::Any.new("nan"),  Int32)
    test_invalid_cast(JSON::Any.new("nan"),  Int64)

    test_valid_cast(JSON::Any.new("12.45"),       Float64, 12.45)
    test_valid_cast(JSON::Any.new("-12512.124"),  Float64, -12512.124)
    test_valid_cast(JSON::Any.new("12.45"),       Float32, 12.45_f32)
    test_valid_cast(JSON::Any.new("-12512.124"),  Float32, -12512.124_f32)
    test_valid_cast_block(JSON::Any.new("NaN"),  Float64){ |v| !v.nil? && !!v.nan? }
    test_valid_cast_block(JSON::Any.new("NaN"),  Float32){ |v| !v.nil? && !!v.nan? }
    test_valid_cast_block(JSON::Any.new("infinity"),  Float64){ |v| !v.nil? && !!v.infinite? }
    test_valid_cast_block(JSON::Any.new("infinity"),  Float32){ |v| !v.nil? && !!v.infinite? }
    test_invalid_cast(JSON::Any.new("invalid"),  Float64)
    test_invalid_cast(JSON::Any.new("invalid"),  Float32)
  end
end
