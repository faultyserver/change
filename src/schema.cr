module Change
  class Schema(T)
    macro inherited

    end

    macro schema(name)
      {{yield}}

      gen_schema
    end

    macro field(name, klass)
      property {{name}} : {{klass}}
    end

    macro gen_schema
    end
  end
end
