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
  describe "#changes_hash" do
    it "returns an empty hash if the changeset has no changes" do
      changeset = User.changeset()

      changes = changeset.changes_hash
      changes.size.should eq(0)
    end

    it "returns an empty hash if the changeset has no changes with stored instance values" do
      user = User.new(name: "John", age: 35)
      changeset = User.changeset(user)
      changes = changeset.changes_hash

      changes.size.should eq(0)
    end

    it "returns only changed fields" do
      changeset = User.changeset()
        .cast({name: "John"}, [:name])
      changes = changeset.changes_hash

      changes.size.should eq(1)
      changes.has_key?("name").should eq(true)
      changes.has_key?("age").should eq(false)
    end

    it "returns stringified values" do
      changeset = User.changeset()
        .cast({name: "John", age: 23}, [:name, :age])
      changes = changeset.changes_hash

      changes.size.should eq(2)
      changes["name"].should eq("John")
      changes["age"].should eq("23")
    end

    it "includes values changed to nil" do
      user = User.new(name: "John", age: 23)
      changeset = User.changeset(user)
        .cast({name: nil, age: nil}, [:name, :age])
      changes = changeset.changes_hash

      changes["name"]?.should eq(nil)
      changes["age"]?.should eq(nil)
    end
  end
end
