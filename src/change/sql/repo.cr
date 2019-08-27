require "./query"

module Change
  module SQL
    # Generic interface for querying a repository.
    #
    # Adapters implement this interface by executing the designated operations
    abstract class Repo
      abstract def all(queryable : T.class, query : Query? = nil) : Array(T) forall T

      abstract def one(queryable : T.class) : T forall T

      abstract def get(queryable : T.class, id) : T? forall T

      abstract def insert(changeset : Changeset(T, U)) forall T, U

      abstract def update(changeset : Changeset(T, U)) forall T, U

      abstract def delete(queryable : T.class, id) forall T
    end
  end
end
