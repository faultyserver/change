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

    private macro json_cast(kind, method)
      def_cast(JSON::Any, {{kind}}) do
        {true, value.{{method.id}}}
      # JSON::Any raises TypeCastErrors when a non-nilable cast fails
      rescue TypeCastError
        {false, nil}
      end
    end

    json_cast(Nil, :as_nil?)
    json_cast(Bool, :as_bool?)

    json_cast(Int,    :as_i?)
    json_cast(Int32,  :as_i?)
    json_cast(Int64,  :as_i64?)

    json_cast(Float,    :as_f?)
    json_cast(Float32,  :as_f?)
    json_cast(Float64,  :as_f64?)

    json_cast(String, :as_s?)
  end
end
