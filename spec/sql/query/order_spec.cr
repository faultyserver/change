require "./query_helper"
require "../../../src/change/sql/query"

describe Change::SQL::Query do
  describe "#order" do
    it "accepts bare kwargs of order expressions to add to the query" do
      time = Time.utc()

      query = Change::SQL::Query.new
        .order(title: :asc, published_at: :desc)

      query.orders.should eq([
        order_expr(select_expr("title"), :asc),
        order_expr(select_expr("published_at"), :desc)
      ])
    end

    it "accepts a NamedTuple of order expressions to add to the query" do
      time = Time.utc()

      query = Change::SQL::Query.new
        .order({title: :asc, published_at: :desc})

      query.orders.should eq([
        order_expr(select_expr("title"), :asc),
        order_expr(select_expr("published_at"), :desc)
      ])
    end

    it "accepts a hash of order expressions to add to the query" do
      time = Time.utc()

      query = Change::SQL::Query.new
        .order({"title" => :asc, "published_at" => :desc})

      query.orders.should eq([
        order_expr(select_expr("title"), :asc),
        order_expr(select_expr("published_at"), :desc)
      ])
    end

    it "allows multiple calls to append order expressions" do
      time = Time.utc()

      query = Change::SQL::Query.new
        .order(title: :asc)
        .order(published_at: :desc)

      query.orders.should eq([
        order_expr(select_expr("title"), :asc),
        order_expr(select_expr("published_at"), :desc)
      ])
    end
  end

  describe "#only_order" do
    it "removes existing order expressions when called again" do
      time = Time.utc()

      query = Change::SQL::Query.new
        .order(title: :asc)
        .only_order({published_at: :desc})

      query.orders.should eq([
        order_expr(select_expr("published_at"), :desc)
      ])
    end
  end
end
