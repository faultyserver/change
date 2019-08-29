require "./query_helper"
require "../../../src/change/sql/query"

describe Change::SQL::Query do
  describe "#update" do
    it "accepts bare kwargs of update expressions to add to the query" do
      time = Time.utc()

      query = Change::SQL::Query.new
        .update(title: "Something", published_at: time)

      query.updates.should eq([
        update_expr(select_expr("title"), "Something"),
        update_expr(select_expr("published_at"), time)
      ])
    end

    it "accepts a NamedTuple of update expressions to add to the query" do
      time = Time.utc()

      query = Change::SQL::Query.new
        .update({title: "Something", published_at: time})

      query.updates.should eq([
        update_expr(select_expr("title"), "Something"),
        update_expr(select_expr("published_at"), time)
      ])
    end

    it "accepts a hash of update expressions to add to the query" do
      time = Time.utc()

      query = Change::SQL::Query.new
        .update({"title" => "Something", "published_at" => time})

      query.updates.should eq([
        update_expr(select_expr("title"), "Something"),
        update_expr(select_expr("published_at"), time)
      ])
    end

    it "allows multiple calls to append update expressions" do
      time = Time.utc()

      query = Change::SQL::Query.new
        .update(title: "Something")
        .update(published_at: time)

      query.updates.should eq([
        update_expr(select_expr("title"), "Something"),
        update_expr(select_expr("published_at"), time)
      ])
    end
  end

  describe "#only_update" do
    it "removes existing update expressions when called again" do
      time = Time.utc()

      query = Change::SQL::Query.new
        .update(title: "Something")
        .only_update({published_at: time})

      query.updates.should eq([
        update_expr(select_expr("published_at"), time)
      ])
    end
  end
end
