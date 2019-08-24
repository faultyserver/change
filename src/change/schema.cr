module Change
  macro included
    FIELDS = [] of NamedTuple(name: String, type: String)

    macro finished
      gen_changeset(\{{@type}})
    end
  end


  # Define a nilable property on the caller and for the Changeset it generates.
  # The generated property will automatically be made Nilable, but the default
  # accessor will raise on nil. If the field is expected to be nil, use `prop?`
  # to access the field instead.
  #
  # `prop` is expected to be a `TypeDeclaration` (e.g. `name : String`), just
  # as is used when calling `property`, including setting a default value, or
  # adding any annotations.
  #
  # `opts` is currently unused, but will be passed along to the generated
  # changeset fields to modify them further.
  macro field(prop, **opts)
    {% FIELDS.push({name: prop.var, type: prop.type}) %}
    property! {{prop}}?
  end

  # Exactly like `field`, but the generated field is non-nilable.
  macro field!(prop, **opts)
    {% FIELDS.push({name: prop.var, type: prop.type}) %}
    property {{prop}}
  end


  # Generate a custom Changeset struct for the given type. `properties` will
  # also be generated as properties on the type itself.
  # `properties` should not include any nilable types, as they will be added
  # automatically on generation. By default, normal accessors will be non-
  # nilable, and query accessors (e.g. `name?`) can be used if a nil value may
  # be expected.
  #
  # Rather than enforcing nilability on the field type itself, it is instead
  # managed by the Changeset's casting, validations, and other constraints.
  macro gen_changeset(type)
    {% prop_names = FIELDS.map(&.[:name]) %}
    {% prop_types = FIELDS.map(&.[:type]) %}

    private alias Field_Type = Union({{*prop_types}})

    struct Changeset < ::Change::Changeset({{type}}, Field_Type)
      {% for prop in FIELDS %}
        property! {{prop[:name].id}} : {{prop[:type].id}}?
        property? {{prop[:name].id}}_changed : Bool = false
      {% end %}

      FIELD_NAMES = {{ prop_names.map(&.stringify) }}

      def changed? : Bool
        {% for prop in prop_names %}
          return true if self.{{prop}}_changed?
        {% end %}

        return false
      end

      def has_field?(field : String) : Bool
        FIELD_NAMES.includes?(field)
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

      def apply_changes : {{type}}
        {% for prop in prop_names %}
          if self.{{prop}}_changed?
            @instance.{{prop}} = self.{{prop}}?
          end
        {% end %}

        @instance
      end

      def apply_changes(inst : {{type}}) : {{type}}
        {% for prop in prop_names %}
          if self.{{prop}}_changed?
            inst.{{prop}} = self.{{prop}}?
          end
        {% end %}

        inst
      end

      def changes_hash : Hash(String, String?)
        hash = {} of String => String?
        {% for prop in prop_names %}
          if self.{{prop}}_changed?
            hash["{{prop}}"] = self.{{prop}}?.try(&.to_s)
          end
        {% end %}
        hash
      end

      def each_change(&block : String, Field_Type? -> _)
        {% for prop in prop_names %}
          if self.{{prop}}_changed?
            block.call({{prop.stringify}}, get_change({{prop.stringify}}))
          end
        {% end %}
      end

      def each_field(&block : String, Field_Type? -> _)
        {% for prop in prop_names %}
          block.call({{prop.stringify}}, get_field({{prop.stringify}}))
        {% end %}
      end

      protected def cast_field(field : String, value)
        case field
        {% for prop in FIELDS %}
          when "{{prop[:name].id}}"
            valid, value = Change::TypeCast.cast(value, {{prop[:type].id}})
            return if @instance.{{prop[:name].id}}? == value

            if valid
              self.{{prop[:name].id}} = value
              self.{{prop[:name].id}}_changed = true
            else
              self.valid = false
            end
        {% end %}
        end
      end
    end
  end
end
