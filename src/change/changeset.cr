module Change
  abstract struct Changeset(T)
    property instance : T
    property? valid : Bool = true

    # Create a new changeset using `instance` as the base for defining changes.
    def initialize(@instance : T)
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

    # Returns true if any field in this changeset has been marked as changed.
    abstract def changed? : Bool

    # Assign each changed value from this changeset onto the instance owned
    # by this Changeset (in the `instance` property). Returns the updated
    # instance directly.
    #
    # This is considered a safe operation, as only validated changes are
    # stored in the changeset.
    abstract def apply_changes : T
    # Like `apply_changes/0`, but instead applying the changes to the given instance.
    abstract def apply_changes(inst : T) : T


    # Cast `value` into the field with the given name.
    #
    # If the cast is successful, the casted value will be assigned into the
    # changeset, and the `changed?` field for that value will be set.
    # Otherwise, the changeset is marked as invalid and the value is not
    # assigned.
    private abstract def cast_field(field : String, value)
  end
end
