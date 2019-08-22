require "spec"
require "../src/change"
require "auto_initialize"

class User
  include AutoInitialize
  include Change

  field name : String
  field age : Int32

  # Standard pattern for working with changesets. Define a static method
  # that performs casts and validations to abstract that from the callsite.
  def self.changeset(instance=self.new)
    Changeset.new(instance)
  end
end
