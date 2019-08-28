require "./sql/repo"
require "./sql/query"

module Change
  # This is an incredibly basic module for SQL generation. To start, I just
  # need a way of querying, inserting, updating, and deleting. No corner cases,
  # associations, or anything like that are intended to be supported by this
  # basic implementation.
  #
  # Expanding this into a proper DSL/querying library can come later (see
  # `query-ideas.cr` for an example of what this may look like in the future).
  module SQL
    # Define the name of the source table for an object.
    macro source(name)
      class_getter sql_source = "{{name.id}}"
    end

    macro primary_key(name)
      class_getter primary_key = "{{name.id}}"
    end
  end
end
