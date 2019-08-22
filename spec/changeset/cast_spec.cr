require "../spec_helper"


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

    it "does not assign changes that are not permitted" do
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name])

      changeset.name.should eq("John")
      changeset.age?.should eq(nil)
      changeset.age_changed?.should eq(false)
    end

    it "allows casts to nil" do
      user = User.new(name: "John")
      changeset = User.changeset(user)
        .cast({name: nil}, [:name])

      changeset.valid?.should eq(true)
      changeset.name?.should eq(nil)
      changeset.name_changed?.should eq(true)
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

    it "ignores non-existent fields" do
      user = User.new(name: "John", age: 24)

      changeset = User.changeset(user)
        .cast({name: "John", age: 35}, [:non_existent])

      changeset.changed?.should eq(false)
    end
  end
end
