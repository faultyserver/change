require "./query"

module Change
  module SQL
    # Generic interface for querying a repository.
    #
    # For now this is implemented directly with Postgres as a backing adapter,
    # but extracting an adapter system should be fairly simple.
    class Repo
      property conn : DB::Database

      def initialize(@conn : DB::Database)
      end


      # Return all existing records of `queryable` that match the provided
      # query, or just all records if no query is given.
      def all(queryable : T.class, query : Query = Query.new) : Array(T) forall T
        query = query
          .only_from(T.sql_source)

        sql, binds = PostgresQuery.select(query)
        queryable.from_rs(conn.query(sql, binds))
      end

      # Return a single record of `queryable` that matches the provided query,
      # or the first result of the query if no query is given.
      #
      # If multiple records are returned by the query, the first is selected.
      # If no record matches, returns nil.
      def one(queryable : T.class, query : Query = Query.new) : T? forall T
        query = query
          .only_from(T.sql_source)
          .limit(1)

        sql, binds = PostgresQuery.select(query)
        conn.query_one?(sql, binds, as: T)
      end

      # Get the record of `queryable` whose primary key matches the given id
      # value. If no record matches the query, `nil` is returned instead.
      def get(queryable : T.class, id) : T? forall T
        query = Query.new
          .where({T.primary_key => id})

        self.one(queryable, query)
      end


      # Attempt to save a record of `T` to the repository. The insertion is
      # only attempted if the changeset is currently valid.
      def insert(changeset : Changeset(T, U)) : Changeset(T, U) forall T, U
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
        changeset.instance = conn.query_one(sql, binds, as: T)
        changeset
      end


      # Attempt to update a record of `T` in the repository. The update is only
      # attempted if the changeset is currently valid, and the instance of the
      # changeset has a primary key value set.
      def update(changeset : Changeset(T, U)) : Changeset(T, U) forall T, U
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

        changeset.apply_changes
        changeset
      end


      # Delete the record of `queryable` with the primary key that matches
      # the given id value.
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
