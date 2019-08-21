# change

An early, in-progress implementation of Changesets in Crystal. Inspired by Elixir's [Ecto Changesets](https://hexdocs.pm/ecto/Ecto.Changeset.html).

Changesets are a powerful way of implementing validations and coercions in a composable, non-destructive way. Changes can be applied and validations can be enforced without ever modifying the underlying instance, making it easy to trust that data manipulation is always done correctly and safely.

What works:

  - `cast` with typecasting of primitive types (nil, booleans, string, ints, floats).
  - `validate_*` for making assertions about fields (currently only `validate_required`).
    - `valid?` method on the changeset to indicate overall validity.
    - `add_error` to add an error to the changeset and mark it as invalid.
  - `get_*` to inspect information about the changeset dynamically.
  - Schema definitions (but this is definitely going to change a lot soon).

Initial goals for this implementation include:

  - **Compile Performance:** minimal, linear/constant-time overhead with macros and generated code with respect to the number of usages.
  - **Type safety:** safe, automatic casting of data between types from any input type.
  - **Extensibility:** enabling user-defined types to be added without requiring modifications to the core

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     changeset:
       github: faultyserver/change
   ```

2. Run `shards install`


## Usage

This library is too early to have a documented API. In the meantime, check `example.cr` for an example usage. A short sample is also given here:


```crystal
require "change"

class User
  Change.schema User,
    name : String,
    age : Int32,
    bio : String

  # Standard pattern for working with changesets. Define a static method
  # that performs casts and validations to abstract that from the callsite.
  def self.changeset(instance, changes={} of String => String)
    Changeset.new(instance)
      .cast(changes, [:name, :age, :bio])
      .validate_required(["name", "age"])
  end
end


user = User.new
changeset = User.changeset(user, {
  name: "Jon",
  age: 23,
})

# Changesets abstract validation to a single place, so clients can just query
# their validity before continuing.
changeset.valid? #=> true

# Changesets don't modify the backing instance until explicitly applied.
user #=> #<User @name=nil, @age=nil, @bio=nil>
user = changeset.apply_changes
user #=> #<User @name="Jon, @age=23, @bio=nil>
```
