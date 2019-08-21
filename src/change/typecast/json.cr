# This file shows how the typecasting system can be extended with conversions
# for new types by showing how JSON can be added.
#
# The `def_cast` macro is a convenience for defining a simple cast from A to B,
# and should be the only way casts are defined. Directly creating a `self.cast`
# method is not an officially supported way of adding casts, as there may be
# other behavior added/hooked by the macro.
#
# This implementation creates another wrapping macro, `json_cast` to simplify
# the definitions even further.
require "json"

module Change
  module TypeCast
    # This extension implements type conversions for JSON::Any values. This is
    # especially useful when used in web contexts where user-provided data is
    # commonly given in JSON format.
    #
    # With these conversions defined, it's easy to just pass a `params` JSON
    # object to `Changeset.cast` and have everything work as expected.
    #
    # Example:
    #
    #     def changeset(instance, changes)
    #       User::Changeset.new(instance)
    #           .cast([:name, :age, :admin])
    #           .validate_required("name")
    #     end
    #
    #     json_params = JSON.parse(%({"name":"John","age":23,"admin":true}))
    #
    #     changeset(User.new, json_params.as_h).apply
    #     #=> #<User:... @name="John", @age=23, @admin=true

    def_cast(JSON::Any, Nil)      do cast(value.raw, Nil) end
    def_cast(JSON::Any, Bool)     do cast(value.raw, Bool) end
    def_cast(JSON::Any, Int)      do cast(value.raw, Int) end
    def_cast(JSON::Any, Int32)    do cast(value.raw, Int32) end
    def_cast(JSON::Any, Int64)    do cast(value.raw, Int64) end
    def_cast(JSON::Any, Float)    do cast(value.raw, Float) end
    def_cast(JSON::Any, Float32)  do cast(value.raw, Float32) end
    def_cast(JSON::Any, Float64)  do cast(value.raw, Float64) end
    def_cast(JSON::Any, String)   do cast(value.raw, String) end
  end
end
