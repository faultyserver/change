require "../spec_helper"


describe Change::Changeset do
  describe "#apply_changes/0" do
    it "applies all saved changes to the Changeset's stored instance" do
      # No arg creates an empty instance.
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name, :age])

      user = changeset.instance
      user.name?.should eq(nil)
      user.age?.should eq(nil)

      changeset.apply_changes
      user.name.should eq("John")
      user.age.should eq(35)
    end

    it "does not remove changes from the Changeset after applying" do
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name, :age])

      changeset.apply_changes
      changeset.name.should eq("John")
      changeset.name_changed?.should eq(true)
      changeset.age.should eq(35)
      changeset.age_changed?.should eq(true)
    end
  end

  describe "#apply_changes/1" do
    it "applies all saved changes to the given instance" do
      # No arg creates an empty instance.
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name, :age])

      user = User.new
      changeset.apply_changes(user)
      user.name.should eq("John")
      user.age.should eq(35)
    end

    it "does not remove changes from the Changeset after applying" do
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name, :age])

      user = User.new
      changeset.apply_changes(user)
      changeset.name.should eq("John")
      changeset.name_changed?.should eq(true)
      changeset.age.should eq(35)
      changeset.age_changed?.should eq(true)
    end
  end
end
