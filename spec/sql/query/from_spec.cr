require "./query_helper"
require "../../../src/change/sql/query"

describe Change::SQL::Query do
  describe "#from" do
    it "adds a single from expression to the query" do
      query = Change::SQL::Query.new
        .from("posts")

      query.froms.should eq([from_expr("posts")])
    end

    it "allows multiple calls to set multiple sources" do
      query = Change::SQL::Query.new
        .from("posts")
        .from("users")

      query.froms.should eq([from_expr("posts"), from_expr("users")])
    end
  end

  describe "#only_from" do
    it "removes existing from expressions when called again" do
      query = Change::SQL::Query.new
        .from("posts")
        .only_from("users")

      query.froms.should eq([from_expr("users")])
    end
  end
end
