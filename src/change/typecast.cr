module Change
  module TypeCast
    macro def_cast(given, target)
      def self.cast(value : {{given.id}}, target : {{target.id}}.class) : {Bool, {{target.id}}?}
        {{yield}}
      end
    end

    # Define a fallback cast method for all casts to a given type. This is
    # mainly intended for primitive values and anything else that defines a
    # converter on `Object` or things like `JSON` that cover most types
    # automatically.
    #
    # The `value` parameter is left untyped to allow overrides for specific
    # value types to be defined afterward.
    macro method_cast(kind, method)
      def self.cast(value, target : {{kind.id}}.class) : {Bool, {{kind.id}}?}
        if value.responds_to?({{method}})
          {true, value.{{method.id}}}
        else
          {false, nil}
        end
      # e.g. `"hello".to_i` raises an ArgumentError
      rescue ArgumentError
        {false, nil}
      rescue OverflowError
        {false, nil}
      end
    end

    # Nil is always a successful cast to deal with field nilability. This is a
    # method overload that allows all other casts to ignore nilability.
    def_cast(_, Nil) do {true, nil} end
    def self.cast(value : Nil, target : T.class) : {Bool, T?} forall T
      {true, nil}
    end

    # Boolean casts are always successful, even considering `nil` as a value.
    # This is done without typing `value` so that other code can override this
    # cast later (e.g., JSON::Any -> Bool)
    def self.cast(value, target : Bool.class)
      {true, !!value}
    end

    # Strings
    # String has a special case for nil, as `nil.to_s` is defined, but should
    # not be considered a valid cast (nilability is handled elsewhere above).
    def_cast(Nil, String) do {false, nil} end
    method_cast(String, :to_s)

    # Integers
    def_cast(Nil, Int) do {false, nil} end
    def_cast(Nil, Int32) do {false, nil} end
    def_cast(Nil, Int64) do {false, nil} end
    method_cast(Int,    :to_i)
    method_cast(Int32,  :to_i32)
    method_cast(Int64,  :to_i64)

    # Floats
    def_cast(Nil, Float) do {false, nil} end
    def_cast(Nil, Float32) do {false, nil} end
    def_cast(Nil, Float64) do {false, nil} end
    method_cast(Float,    :to_f)
    method_cast(Float32,  :to_f32)
    method_cast(Float64,  :to_f64)
  end
end
