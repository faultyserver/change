require "./query_helper"
require "../../../src/change/sql/query"

describe Change::SQL::Query do
  describe "#select" do
    it "adds a single select expression to the query" do
      query = Change::SQL::Query.new
        .select(["title"])

      query.selects.should eq([select_expr("title")])
    end

    it "adds multiple select expressions to the query" do
      query = Change::SQL::Query.new
        .select(["title", "author"])

      query.selects.should eq([select_expr("title"), select_expr("author")])
    end

    it "retains existing select expressions on multiple calls" do
      query = Change::SQL::Query.new
        .select(["title"])
        .select(["author"])

      query.selects.should eq([select_expr("title"), select_expr("author")])
    end
  end

  describe "#only_select" do
    it "removes existing select expressions when called again" do
      query = Change::SQL::Query.new
        .select(["title"])
        .only_select(["author"])

      query.selects.should eq([select_expr("author")])
    end
  end
end
