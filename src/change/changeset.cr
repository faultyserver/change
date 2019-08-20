module Change
  abstract struct Changeset(T)
    property instance : T
    property? valid : Bool = true
    property errors : Array(ChangesetError)

    # Create a new changeset using `instance` as the base for defining changes.
    def initialize(@instance : T)
      @errors = [] of ChangesetError
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
        next unless has_field?(field_name) && props.has_key?(field_name)
        cast_field(field_name, props[field_name])
      end

      self
    end

    # Returns true if any field in this changeset has been marked as changed.
    abstract def changed? : Bool

    # Returns true if `field` is a valid field name in this changeset.
    abstract def has_field?(field : String) : Bool

    # Return the stored change for the given `field` from this changeset, or
    # `default` if the field has not been changed.
    #
    # Even if the value of the change is `nil`, as long as the field has been
    # marked as changed, that value will be returned instead of `default`.
    abstract def get_change(field : String, default=nil)

    # Similar to `get_change` but if no change is present, this method first
    # checks the stored instance for a defined value, and only returns
    # `default` if the instance's existing value is `nil`.
    abstract def get_field(field : String, default=nil)

    # Assign each changed value from this changeset onto the instance owned
    # by this Changeset (in the `instance` property). Returns the updated
    # instance directly.
    #
    # This is considered a safe operation, as only validated changes are
    # stored in the changeset.
    abstract def apply_changes : T
    # Like `apply_changes/0`, but instead applying the changes to the given
    # instance.
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
