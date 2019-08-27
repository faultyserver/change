module Change
  module SQL
    class PostgresQuery
      property query : Query
      property binds : Array(DB::Any)


      def self.select(query : Query)
        q = self.new(query)
        {q.to_select, q.binds}
      end

      def self.insert(query : Query)
        q = self.new(query)
        {q.to_insert, q.binds}
      end

      def self.update(query : Query)
        q = self.new(query)
        {q.to_update, q.binds}
      end

      def self.delete(query : Query)
        q = self.new(query)
        {q.to_delete, q.binds}
      end


      def initialize(@query : Query)
        @binds = [] of DB::Any
      end

      def to_select
        String.build do |str|
          str << " SELECT "
          build_select_expressions(str)
          str << " FROM "
          build_from_expressions(str)

          if query.wheres.size > 0
            str << " WHERE "
            build_where_expressions(str)
          end
          if query.orders.size > 0
            str << " ORDER BY "
            build_order_expressions(str)
          end
        end
      end

      def to_insert
        String.build do |str|
          str << " INSERT INTO "
          build_from_expressions(str)
          str << " ("
          build_insert_field_list_expression(str)
          str << ") VALUES ("
          build_insert_value_list_expression(str)
          str << ")"
        end
      end

      def to_update
        String.build do |str|
          str << " UPDATE "
          build_from_expressions(str)

          if query.updates.size > 0
            str << " SET "
            build_update_expressions(str)
          end

          if query.wheres.size > 0
            str << " WHERE "
            build_where_expressions(str)
          end
        end
      end

      def to_delete
        String.build do |str|
          str << " DELETE FROM "
          build_from_expressions(str)

          if query.wheres.size > 0
            str << " WHERE "
            build_where_expressions(str)
          end
        end
      end


      private def build_select_expressions(io : IO)
        # If no selects are given, assume loading every field from all of the
        # `FROM` sources.
        if query.selects.size == 0
          io << "*"
          return
        end

        columns = query.selects.map(&->make_criterion(SelectExpr))

        io << columns.join(", ")
      end

      private def build_from_expressions(io : IO)
        froms = query.froms.map do |expr|
          "#{expr.table}"
        end

        io << froms.join(", ")
      end

      private def build_where_expressions(io : IO)
        wheres = query.wheres.map do |expr|
          criterion = make_criterion(expr.criterion)
          bind = make_bind(expr.value)
          "#{criterion} #{expr.op} #{bind}"
        end

        io << wheres.join(" AND ")
      end

      private def build_update_expressions(io : IO)
        updates = query.updates.map do |expr|
          criterion = make_criterion(expr.criterion)
          bind = make_bind(expr.value)
          "#{criterion} = #{bind}"
        end

        io << updates.join(", ")
      end

      private def build_order_expressions(io : IO)
        orders = query.orders.map do |expr|
          criterion = make_criterion(expr.criterion)
          direction = expr.direction.to_s.upcase
          "#{criterion} #{direction}"
        end

        io << orders.join(", ")
      end

      # INSERT uses the `criterion` fields of the `UpdateExpr` list on the
      # query to build the list of fields that will be inserted.
      private def build_insert_field_list_expression(io : IO)
        fields = query.updates.map do |expr|
          # Assuming that it's a single table, just the name of the column is
          # needed.
          expr.criterion.column
        end

        io << fields.join(", ")
      end

      # INSERT uses the `value` fields of the `UpdateExpr` list on the
      # query to build the list of values that will be inserted.
      #
      # Because this is a list, the order should be guaranteed to match what
      # was generated for the field list.
      private def build_insert_value_list_expression(io : IO)
        fields = query.updates.map do |expr|
          make_bind(expr.value)
        end

        io << fields.join(", ")
      end


      private def make_criterion(expr : SelectExpr)
        if table = expr.table
          "#{expr.table}.#{expr.column}"
        else
          "#{expr.column}"
        end
      end

      # Adds a value to the list of binds for the query and returns the
      # positional parameter to use in the query string to represent it.
      private def make_bind(value : DB::Any)
        @binds.push(value)
        "$#{@binds.size}"
      end
    end
  end
end
