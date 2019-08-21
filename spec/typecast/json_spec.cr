require "../spec_helper"
require "../../src/change/typecast/json"

private def test_valid_cast(value, type, expected_value, line=__LINE__, file=__FILE__, end_line=__END_LINE__)
  it("casts `#{value.inspect}` to #{type} as #{expected_value}", line: line, file: file, end_line: end_line) do
    valid, casted = Change::TypeCast.cast(value, type)
    valid.should eq(true)
    casted.class.should eq(type)
    casted.should eq(expected_value)
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
    # Everything can be casted to Nil
    test_valid_cast(JSON::Any.new(nil),       Nil, nil)
    test_valid_cast(JSON::Any.new(true),      Nil, nil)
    test_valid_cast(JSON::Any.new(false),     Nil, nil)
    test_valid_cast(JSON::Any.new("hello"),   Nil, nil)
    test_valid_cast(JSON::Any.new(1234_i64),  Nil, nil)
    test_valid_cast(JSON::Any.new(12.34),     Nil, nil)

    # Direct type casts always succeed
    test_valid_cast(JSON::Any.new(true),      Bool, true)
    test_valid_cast(JSON::Any.new(false),     Bool, false)
    test_valid_cast(JSON::Any.new("hello"),   String, "hello")
    test_valid_cast(JSON::Any.new(1234_i64),  Int32, 1234)
    test_valid_cast(JSON::Any.new(12.34),     Float64, 12.34)

    # Up and down casts of numbers should succeed
    test_valid_cast(JSON::Any.new(1234_i64),  Int64, 1234)
    test_valid_cast(JSON::Any.new(12.34),     Float32, 12.34_f32)

    # # JSON cross-conversions match primitive types
    # test_valid_cast(JSON::Any.new("123"),     Int32, 123)
  end
end
