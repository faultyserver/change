require "./query_helper"
require "../../../src/change/sql/query"

describe Change::SQL::Query do
  describe "#where" do
    it "accepts bare kwargs of where expressions to add to the query" do
      time = Time.utc()

      query = Change::SQL::Query.new
        .where(title: "Something", published_at: time)

      query.wheres.should eq([
        where_expr(select_expr("title"), "=", "Something"),
        where_expr(select_expr("published_at"), "=", time)
      ])
    end

    it "accepts a NamedTuple of where expressions to add to the query" do
      time = Time.utc()

      query = Change::SQL::Query.new
        .where({title: "Something", published_at: time})

      query.wheres.should eq([
        where_expr(select_expr("title"), "=", "Something"),
        where_expr(select_expr("published_at"), "=", time)
      ])
    end

    it "accepts a hash of where expressions to add to the query" do
      time = Time.utc()

      query = Change::SQL::Query.new
        .where({"title" => "Something", "published_at" => time})

      query.wheres.should eq([
        where_expr(select_expr("title"), "=", "Something"),
        where_expr(select_expr("published_at"), "=", time)
      ])
    end

    it "allows multiple calls to append where expressions" do
      time = Time.utc()

      query = Change::SQL::Query.new
        .where(title: "Something")
        .where(published_at: time)

      query.wheres.should eq([
        where_expr(select_expr("title"), "=", "Something"),
        where_expr(select_expr("published_at"), "=", time)
      ])
    end
  end

  describe "#only_where" do
    it "removes existing where expressions when called again" do
      time = Time.utc()

      query = Change::SQL::Query.new
        .where(title: "Something")
        .only_where({published_at: time})

      query.wheres.should eq([
        where_expr(select_expr("published_at"), "=", time)
      ])
    end
  end
end
