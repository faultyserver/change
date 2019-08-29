require "./query_helper"
require "../../../src/change/sql/query"

describe Change::SQL::Query do
  describe "#offset" do
    it "adds a offset expression to the query" do
      query = Change::SQL::Query.new
        .offset(2)

      query.offset.should eq(2)
    end

    it "overwrites an existing offset value when called again" do
      query = Change::SQL::Query.new
        .offset(2)
        .offset(10)

      query.offset.should eq(10)
    end
  end

  describe "#without_offset" do
    it "removes an existing offset from the query" do
      query = Change::SQL::Query.new
        .offset(2)
        .without_offset()

      query.offset?.should eq(nil)
    end

    it "is valid with no existing offset set" do
      query = Change::SQL::Query.new
        .without_offset()

      query.offset?.should eq(nil)
    end
  end
end
