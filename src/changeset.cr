module Change
  struct Changeset(Type, Changes)
    property instance : Type
    property changes : Changes
    property changed : Bool

    def initialize(@instance : Type)
      @changes = Changes.new
      @changed = false
    end

    def cast(props, fields : Array(String)) : self
      fields.each do |field|
        if props.has_key?(field)
          change_field(field, props[field])
        end
      end

      self
    end

    def change_field(field : String, value)
      {% begin %}
        case field
        {% for field in Changes.instance_vars %}
          {% non_nilable_field_type = field.type.union_types.reject{|t| t == Nil }[0] %}
          when "{{field.id}}"
            @changes.{{field.id}} = TypeCast.cast(value, {{non_nilable_field_type}})
        {% end %}
        end
      {% end %}
    end
  end
end
