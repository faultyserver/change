require "./src/change"

class User
  property name : String?
  property age : Int32?

  struct UserChanges
    property name : String? = nil
    property age : Int32? = nil
  end

  def self.changeset(instance)
    Change::Changeset(User, UserChanges).new(instance)
      .cast({"name" => "Jon", "age" => nil}, ["name", "age"])
  end
end


user = User.new
user.name = "Sam"
user.age = 28

pp User.changeset(user)
