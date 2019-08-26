require "db"
require "pg"

require "./repo"

module Change
  module SQL
    class PostgresRepo < Repo
      property conn : DB::Database

      def initialize(conn_url : String)
        @conn = PG.connect(conn_url)
      end


      ###
      # Impl
      ###

      def all(queryable : T.class) : Array(T) forall T
        source = queryable.sql_source
        columns = T::Changeset::FIELD_NAMES.map{ |field| "#{source}.#{field}" }
        select_string = columns.join(", ")

        queryable.from_rs(conn.query("SELECT #{select_string} FROM #{source}"))
      end

      def one(queryable : T) : T forall T
      end

      def get(queryable : T, id) : T? forall T
      end


      def insert(changeset : Changeset(T, U)) : T | Changeset(T, U) forall T, U
        return changeset unless (changeset.valid?)

        source = T.sql_source

        fields = [] of String
        values = [] of U?
        changeset.each_field do |field, value|
          unless field == T.primary_key
            fields.push(field)
            values.push(value)
          end
        end

        returns = fields + [T.primary_key]
        positions = values.map_with_index{ |_, i| "$#{i+1}" }

        query = <<-SQL
          INSERT INTO #{source} (#{fields.join(", ")})
          VALUES (#{positions.join(", ")})
          RETURNING #{returns.join(", ")}
        SQL

        conn.query_one(query, values, as: T)
      end


      def update(changeset : Changeset(T, U)) forall T, U
      end


      def delete(changeset : Changeset(T, U)) forall T, U
      end
    end
  end
end
