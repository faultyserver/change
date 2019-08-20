require "../spec_helper"

private class User
  include AutoInitialize

  Change.schema User,
    name : String,
    age : Int32

  def self.changeset(instance=self.new)
    User::Changeset.new(instance)
  end
end

describe Change::Changeset do
  describe "#get_field/2" do
    it "returns the value of a stored change if present" do
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name])

      changeset.get_field("name").should eq("John")
    end

    it "returns the stored instance's field value if no change is stored" do
      user = User.new(name: "John")
      changeset = User.changeset(user)

      changeset.get_field("name").should eq("John")
    end

    it "returns `default` if no change is stored and the instance value is nil" do
      user = User.new(name: nil)
      changeset = User.changeset(user)

      changeset.get_field("name").should eq(nil)
      changeset.get_field("name", :default_value).should eq(:default_value)
    end
  end
end
