module Change
  # Generate a custom Changeset struct for the given type. `properties` will
  # also be generated as properties on the type itself.
  # `properties` should not include any nilable types, as they will be added
  # automatically on generation. By default, normal accessors will be non-
  # nilable, and query accessors (e.g. `name?`) can be used if a nil value may
  # be expected.
  #
  # Rather than enforcing nilability on the field type itself, it is instead
  # managed by the Changeset's casting, validations, and other constraints.
  macro schema(type, *properties)
    {% prop_names = properties.map(&.var) %}
    {% prop_types = properties.map(&.type) %}

    {% for prop in properties %}
      property! {{prop}}?
    {% end %}

    struct Changeset < ::Change::Changeset({{type}})
      {% for prop in properties %}
        property! {{prop.var}} : {{prop.type}}?
        property? {{prop.var}}_changed : Bool = false
      {% end %}

      def changed? : Bool
        {% for prop in prop_names %}
          return true if self.{{prop}}_changed?
        {% end %}

        return false
      end

      def get_change(field : String, default=nil)
        case field
          {% for prop in prop_names %}
            when "{{prop}}"
              return self.{{prop}}? if self.{{prop}}_changed?
              return default
          {% end %}
        end
      end

      def get_field(field : String, default=nil)
        case field
          {% for prop in prop_names %}
            when "{{prop}}"
              return self.{{prop}}? if self.{{prop}}_changed?
              existing = @instance.{{prop}}?
              return existing.nil? ? default : existing
          {% end %}
        end
      end

      def apply_changes
        {% for prop in prop_names %}
          if self.{{prop}}_changed?
            @instance.{{prop}} = self.{{prop}}?
          end
        {% end %}

        @instance
      end

      def apply_changes(inst : {{type}})
        {% for prop in prop_names %}
          if self.{{prop}}_changed?
            inst.{{prop}} = self.{{prop}}?
          end
        {% end %}

        inst
      end

      private def cast_field(field : String, value)
        case field
        {% for prop in properties %}
          when "{{prop.var}}"
            valid, value =
              if value.nil?
                {true, nil}
              else
                Change::TypeCast.cast(value, {{prop.type}})
              end

            existing = @instance.{{prop.var}}?

            return if existing == value

            if valid
              self.{{prop.var}} = value
              self.{{prop.var}}_changed = true
            else
              self.valid = false
            end
        {% end %}
        end
      end
    end
  end
end
