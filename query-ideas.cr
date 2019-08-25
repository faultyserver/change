# This file demonstrates what I think could be a powerful, expressive DSL for
# writing queries on arbitrary objects in Crystal.
#
# A goal is compile-time generation of optimized query structures, and avoiding
# heap allocations where possible. Queries generally don't change, so there's
# no real reason to generate them from scratch on every request.
#
# This is not working code, but the syntax should be valid (assuming most
# things are macros).
#
# Much of this is directly inspired by `Ecto.Query`'s DSL.


# Direct querying
user = Repo.all(User)
#=> SELECT users.* FROM users


# Simple wheres
pp SQL.from(u : User, where: u.name = "jon")
#=> SELECT users.*... FROM users WHERE users.name = "jon"
pp SQL.from(u : User, where: u.name = "jon" && u.age > 23)
#=> SELECT users.*... FROM users WHERE users.name = "jon" AND users.age > 23

# select sub-fields
pp SQL.from(u : User,
  where: u.name = "jon" && u.age > 23,
  select: [:name]
)
#=> SELECT users.name FROM users WHERE users.name = "jon" AND users.age > 23

# group by
pp SQL.from(u : User,
  group: [:name]
)
#=> SELECT users.name FROM users GROUP BY users.name

# order by
pp SQL.from(u : User,
  order: {name: :asc}
)
#=> SELECT users.name FROM users ORDER BY users.name ASC
