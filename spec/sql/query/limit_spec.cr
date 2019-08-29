require "./query_helper"
require "../../../src/change/sql/query"

describe Change::SQL::Query do
  describe "#limit" do
    it "adds a limit expression to the query" do
      query = Change::SQL::Query.new
        .limit(2)

      query.limit.should eq(2)
    end

    it "overwrites an existing limit value when called again" do
      query = Change::SQL::Query.new
        .limit(2)
        .limit(10)

      query.limit.should eq(10)
    end
  end

  describe "#without_limit" do
    it "removes an existing limit from the query" do
      query = Change::SQL::Query.new
        .limit(2)
        .without_limit()

      query.limit?.should eq(nil)
    end

    it "is valid with no existing limit set" do
      query = Change::SQL::Query.new
        .without_limit()

      query.limit?.should eq(nil)
    end
  end
end
