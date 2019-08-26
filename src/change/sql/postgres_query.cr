module Change
  module SQL
    class PostgresQuery
      property query : Query

      def initialize(@query : Query)
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
          "#{criterion} #{expr.op} #{expr.value}"
        end

        io << wheres.join(", ")
      end

      private def build_update_expressions(io : IO)
        updates = query.updates.map do |expr|
          criterion = make_criterion(expr.criterion)
          "#{criterion} = #{expr.value}"
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


      private def make_criterion(expr : SelectExpr)
        if table = expr.table
          "#{expr.table}.#{expr.column}"
        else
          "#{expr.column}"
        end
      end
    end
  end
end
