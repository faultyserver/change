module Change
  # `T` is the type of the stored instance, inferrable from `initialize`.
  # `U` is a union of the type of all managed fields on that instance. `U` does
  # not need to (and generally should not) include `Nil` in the union, it will
  # automatically be added where needed.
  abstract struct Changeset(T, U)
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
    abstract def get_change(field : String, default=nil) : U?

    # Similar to `get_change` but if no change is present, this method first
    # checks the stored instance for a defined value, and only returns
    # `default` if the instance's existing value is `nil`.
    abstract def get_field(field : String, default=nil) : U?

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

    # Returns a hash of changes currently stored in this changeset, including
    # fields that have been changed to nil. Fields without changes are not
    # included in this hash, meaning a changeset with no changes will return an
    # empty hash.
    abstract def changes_hash : Hash(String, String?)

    # Calls the given block once for every accepted change currently in the
    # changeset. The block is passed the name of the changed field and its
    # accepted value as arguments. Fields that have not been changed will not
    # be yielded to the block.
    #
    # If the changeset has no accepted changes, the block will not be called.
    abstract def each_change(&block : String, U? -> _)

    # Calls the given block once for every field in the changeset, including
    # fields that have not been changed. Fields with accepted changes will
    # yield the changed value, while fields without changes will yield the
    # value from the stored instance.
    #
    # The block will always be called for every field managed by the changeset.
    abstract def each_field(&block : String, U? -> _)

    # Cast `value` into the field with the given name.
    #
    # If the cast is successful, the casted value will be assigned into the
    # changeset, and the `changed?` field for that value will be set.
    # Otherwise, the changeset is marked as invalid and the value is not
    # assigned.
    protected abstract def cast_field(field : String, value)
  end
end
