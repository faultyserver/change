require "spec"
require "../src/change"

class User
  Change::Changeset.schema User,
    name : String,
    age : Int32
end
