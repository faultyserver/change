module Change
  class ChangesetError
    property field : String
    property message : String

    def initialize(@field : String, @message : String)
    end
  end

  abstract struct Changeset(T, U)
    # Add an error to this changeset. `field` is the field that the error
    # applies to, and `message` is a description about the error. Errors will
    # be coerced into a `ChangesetError` object.
    #
    # Calling this method also implicitly marks this Changeset as invalid.
    def add_error(field : String, message : String) : self
      error = ChangesetError.new(field, message)
      @errors.push(error)
      @valid = false

      self
    end
  end
end
