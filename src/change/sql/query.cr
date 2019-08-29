require "auto_initialize"
require "db"

module Change
  module SQL
    struct SelectExpr
      include AutoInitialize
      property prefix : String?
      property table : String?
      property column : String
    end

    struct FromExpr
      include AutoInitialize
      property prefix : String?
      property table : String
    end

    # NOTE: this is very basic and not nearly a complete representation of all
    # possible expressions in a where clause.
    struct WhereExpr
      include AutoInitialize
      property criterion : SelectExpr
      property op : String
      property value : DB::Any
    end

    struct UpdateExpr
      include AutoInitialize
      property criterion : SelectExpr
      property value : DB::Any
    end

    struct OrderExpr
      include AutoInitialize
      property criterion : SelectExpr
      property direction : String
    end


    class Query
      property selects = [] of SelectExpr
      property froms = [] of FromExpr
      # Currently all `AND`d together
      property wheres = [] of WhereExpr
      property updates = [] of UpdateExpr
      property orders = [] of OrderExpr
      property! limit : Int32?
      property! offset : Int32?

      def initialize
      end

      def select(columns : Array) : self
        columns.each do |column|
          self.selects.push(SelectExpr.new(
            column: column.to_s
          ))
        end

        self
      end

      def from(source : String) : self
        self.froms.push(FromExpr.new(table: source))
        self
      end

      def where(conditions) : self
        conditions.each do |field, value|
          self.wheres.push(WhereExpr.new(
            criterion: SelectExpr.new(column: field.to_s),
            op: "=",
            value: value
          ))
        end

        self
      end

      def where(**conditions) : self
        where(conditions)
      end

      def update(updates) : self
        updates.each do |field, value|
          self.updates.push(UpdateExpr.new(
            criterion: SelectExpr.new(column: field.to_s),
            value: value
          ))
        end

        self
      end

      def update(**conditions) : self
        update(conditions)
      end

      def order(orders) : self
        orders.each do |field, direction|
          self.orders.push(OrderExpr.new(
            criterion: SelectExpr.new(column: field.to_s),
            direction: direction.to_s
          ))
        end

        self
      end

      def order(**orders) : self
        order(orders)
      end

      def limit(number) : self
        self.limit = number
        self
      end

      def offset(number) : self
        self.offset = number
        self
      end

      # The `only_` methods are clones of all the other methods, but clear out
      # any other existing entries in that expression list beforehand.
      #
      # Using these methods can guarantee that values are controlled and not
      # composed with any previous values.
      def only_select(columns : Array) : self
        self.selects.clear
        self.select(columns)
      end

      def only_from(source : String) : self
        self.froms.clear
        self.from(source)
      end

      def only_where(conditions) : self
        self.wheres.clear
        self.where(conditions)
      end

      def only_update(updates) : self
        self.updates.clear
        self.update(updates)
      end

      def only_order(orders) : self
        self.orders.clear
        self.order(orders)
      end

      # LIMIT and OFFSET do not have `only_` methods, since they can only
      # contain a single value to start with. Instead, they have `without`
      # methods to remove any existing value
      def without_limit() : self
        self.limit = nil
        self
      end

      def without_offset() : self
        self.offset = nil
        self
      end
    end
  end
end
