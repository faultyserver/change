module Change
  abstract struct Changeset(T)
    # Validates that the given field is present in this Changeset, either as a
    # change, or as an existing value on the stored instance. Presence is
    # defined as anything other than a value of `nil`.
    #
    # If the field is not present, an error is added and the changeset is
    # marked as invalid.
    #
    # If the field is not a valid field for this changeset, it is ignored.
    def validate_required(field : String | Symbol) : self
      field_name = field.to_s
      if has_field?(field_name) && get_field(field_name).nil?
        add_error(field_name, "is required")
      end

      self
    end

    # Validate the multiple fields are present in the Changeset. See
    # `validate_required(String)` for more information.
    def validate_required(fields : Array(String) | Array(Symbol)) : self
      fields.each{ |field| validate_required(field) }
      self
    end
  end
end
