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

    # Nil
    def_cast(Nil, Nil) do {true, nil} end
    # Some other types have their own representations of nil (such as
    # `JSON::Any`), so `value` is left untyped here.
    def self.cast(value, target : Nil.class) : {Bool, Nil}
      {false, nil}
    end
    # Casting _from_ nil is always considered valid to deal with field
    # nilability. Non-nil assertions are instead made using validations.
    def self.cast(value : Nil, target : T.class) : {Bool, T?} forall T
      {true, nil}
    end

    # Booleans
    # Boolean casts allow the strings "false" and "true" as their respective
    # boolean values, but nothing else.
    def self.cast(value, target : Bool.class)
      return {true, true} if value == "true"
      return {true, false} if value == "false"
      return {true, value} if value.is_a?(Bool)
      return {false, nil}
    end

    # Strings
    method_cast(String, :to_s)

    # Integers
    method_cast(Int32,  :to_i32)
    method_cast(Int64,  :to_i64)

    # Floats
    method_cast(Float32,  :to_f32)
    method_cast(Float64,  :to_f64)
  end
end
