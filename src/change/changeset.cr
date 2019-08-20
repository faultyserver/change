module Change::Changeset
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

    struct Changeset
      property instance : {{type}}?
      property? valid : Bool = true

      {% for prop in properties %}
        property! {{prop.var}} : {{prop.type}}?
        property? {{prop.var}}_changed : Bool = false
      {% end %}

      def initialize(@instance : {{type}}? = nil)
      end

      # For each field in `permitted`, attempt to cast the value from `props`
      # into the type of the corresponding field on the model.
      #
      # If any field cannot be casted successfully, the changeset is marked as
      # invalid, but all remaining casts will still be attempted.
      #
      # `nil` is always permitted in casts.
      def cast(props, permitted : Array) : self
        permitted.each do |field|
          field_name = field.to_s
          next unless props.has_key?(field_name)
          cast_field(field_name, props[field_name])
        end

        self
      end

      # Cast `value` into the field with the given name.
      #
      # If the cast is successful, the casted value will be assigned into the
      # changeset, and the `changed?` field for that value will be set.
      # Otherwise, the changeset is marked as invalid and the value is not
      # assigned.
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

            if valid
              self.{{prop.var}} = value
              self.{{prop.var}}_changed = true
            else
              self.valid = false
            end
            return valid
        {% end %}
        end
      end

      # Returns true if any field in this changeset has been marked as changed.
      def changed? : Bool
        {% for prop in prop_names %}
          return true if self.{{prop}}_changed?
        {% end %}

        return false
      end

      # Assign each changed value from this changeset onto the instance owned
      # by this Changeset (in the `instance` property). Returns the updated
      # instance directly.
      #
      # This is considered a safe operation, as only validated changes are
      # stored in the changeset.
      def apply
        {% for prop in prop_names %}
          if self.{{prop}}_changed?
            @instance.{{prop}} = self.{{prop}}?
          end
        {% end %}

        @instance
      end

      # Like `apply/0`, but instead applying the changes to the given instance.
      def apply(inst : {{type}})
        {% for prop in prop_names %}
          if self.{{prop}}_changed?
            inst.{{prop}} = self.{{prop}}?
          end
        {% end %}

        inst
      end
    end
  end
end
