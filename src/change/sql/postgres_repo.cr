require "db"
require "pg"

require "./repo"
require "./postgres_query"

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

      def all(queryable : T.class, query : Query = Query.new) : Array(T) forall T
        query = query
          .only_select(T::Changeset::FIELD_NAMES)
          .only_from(T.sql_source)

        sql, binds = PostgresQuery.select(query)
        queryable.from_rs(conn.query(sql, binds))
      end

      def one(queryable : T.class, query : Query = Query.new) : T forall T
        query = query
          .only_from(T.sql_source)
          .limit(1)

        sql, binds = PostgresQuery.select(query)
        conn.query_one(sql, binds, as: T)
      end

      def get(queryable : T.class, id) : T? forall T
        query = Query.new
          .where({T.primary_key => id})

        self.one(queryable, query)
      end


      def insert(changeset : Changeset(T, U)) : T | Changeset(T, U) forall T, U
        return changeset unless (changeset.valid?)

        fields = {} of String => U?
        changeset.each_change do |field, value|
          fields[field] = value
        end

        query =
          Query.new
          .from(T.sql_source)
          .update(fields)

        sql, binds = PostgresQuery.insert(query)
        conn.query_one(sql, binds, as: T)
      end


      def update(changeset : Changeset(T, U)) forall T, U
        return changeset unless (changeset.valid?)

        fields = {} of String => U?
        changeset.each_change do |field, value|
          fields[field] = value
        end

        query =
          Query.new
          .from(T.sql_source)
          .update(fields)
          .where({T.primary_key => changeset.get_field(T.primary_key)})

        sql, binds = PostgresQuery.update(query)
        conn.exec(sql, binds)
      end


      def delete(queryable : T.class, id) forall T
        query =
          Query.new
          .from(T.sql_source)
          .where({T.primary_key => id})

        sql, binds = PostgresQuery.delete(query)
        conn.exec(sql, binds)
      end
    end
  end
end
