require "./src/change"

class User
  Change::Changeset.schema User,
    name : String,
    age : Int32

  include Change::Changeset

  # Standard pattern for working with changesets. Define a static method
  # that performs casts and validations to abstract that from the callsite.
  def self.changeset(instance, changes)
    Changeset.new(instance)
      .cast(changes, [:name, :age])
  end
end

# Both changes are valid and stored on the changeset
changeset = User.changeset(User.new, {name: "Jon", age: 23})
pp changeset #=> @valid = true
# Bool can't be casted to Int32, so the change is invalid and not stored,
# and the changeset is marked as invalid.
changeset = changeset.cast({age: true}, [:age])
pp changeset #=> @valid = false


user = User.new
pp user #=> Empty user
changeset.apply(user)
pp user #=> User with casted changes
