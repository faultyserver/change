require "./src/change"

class User
  include Change

  field name : String
  field age : Int32
  field bio : String

  # Standard pattern for working with changesets. Define a static method
  # that performs casts and validations to abstract that from the callsite.
  def self.changeset(instance, changes={} of String => String)
    Changeset.new(instance)
      .cast(changes, [:name, :age, :bio])
      .validate_required(["name", "age"])
  end
end

## Basic client usage

# All changes are valid and stored on the changeset
changeset =
  User.changeset(User.new, {
    name: "Jon",
    age: 23,
    bio: "I like changesets"
  })
pp changeset #=> @valid = true


## Dealing with invalid props

# Bool can't be casted to Int32, so the change is invalid and not stored,
# and the changeset is marked as invalid. `name `is also not given
changeset = User.changeset(User.new, {age: true})
# Even though `age` was given as a param, it is not valid and fails to `cast`,
# so it keeps the initial value of `nil` and fails `validate_required`.
pp changeset.errors


## Using existing information

user = User.new
user.name = "John"
user.age = 23
# Initiailizing a changeset with an existing User lets it use that data
# for validations.
changeset = User.changeset(user)
pp changeset #=> valid = true


user = User.new
pp user #=> Empty user
changeset.apply_changes(user)
pp user #=> User with casted changes


## Casting JSON

require "json"
# `cast` accepts any key-value enumerable type with String keys that supports
# `[]` and `has_key?`. JSON _almost_ fits this, but doesn't support `has_key?`,
# so it needs to be converted to a hash before sending to `cast`. Other than
# that, passing a `JSON::Any` to a changeset function should just work.
json_params = JSON.parse(%({"name": "Sam", "age": 35}))
pp json_params.as_h
user = User.changeset(User.new, json_params.as_h).apply_changes
pp user
