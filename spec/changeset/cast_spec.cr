require "../spec_helper"

private class User
  include AutoInitialize

  Change::Changeset.schema User,
    name : String,
    age : Int32

  def self.changeset(instance=self.new)
    User::Changeset.new(instance)
  end
end

describe Change::Changeset do
  describe "#cast" do
    it "assigns permitted string fields from Hash" do
      changeset = User.changeset()
        .cast({"name": "John", "age": 35}, ["name", "age"])

      changeset.name.should eq("John")
      changeset.age.should eq(35)
    end

    it "assigns permitted symbol fields from Hash" do
      changeset = User.changeset()
        .cast({"name": "John", "age": 35}, [:name, :age])

      changeset.name.should eq("John")
      changeset.age.should eq(35)
    end

    it "assigns permitted string fields from NamedTuple" do
      changeset = User.changeset()
        .cast({name: "John", age: 35}, ["name", "age"])

      changeset.name.should eq("John")
      changeset.age.should eq(35)
    end

    it "assigns permitted symbol fields from NamedTuple" do
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name, :age])

      changeset.name.should eq("John")
      changeset.age.should eq(35)
    end

    it "allows casts to nil" do
      changeset = User.changeset()
        .cast({name: nil}, [:name])

      changeset.valid?.should eq(true)
      changeset.name?.should eq(nil)
    end


    it "marks changes for valid casts" do
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name, :age])

      changeset.name_changed?.should eq(true)
      changeset.age_changed?.should eq(true)
    end

    it "does not cast unchanged fields" do
      user = User.new(name: "John", age: 24)

      changeset = User.changeset(user)
        .cast({name: "John", age: 35}, [:name, :age])

      changeset.name?.should eq(nil)
      changeset.name_changed?.should eq(false)
      changeset.age.should eq(35)
      changeset.age_changed?.should eq(true)
    end
  end
end
