require "../../spec_helper"

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
  describe "#validate_required/1" do
    it "does nothing if the field has a non-nil value as a change" do
      # No arg creates an empty instance.
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name, :age])
        .validate_required("name")

      changeset.errors.size.should eq(0)
      changeset.valid?.should eq(true)
    end

    it "does nothing if the field has a non-nil value as on the stored instance" do
      user = User.new(name: "John")
      changeset = User.changeset(user)
        .validate_required("name")

      changeset.errors.size.should eq(0)
      changeset.valid?.should eq(true)
    end

    it "adds an error if the field does not have a non-nil value" do
      changeset = User.changeset()
        .validate_required("name")

      changeset.errors.size.should eq(1)
      changeset.valid?.should eq(false)
    end

    it "can validate multiple fields with present values" do
      # No arg creates an empty instance.
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name, :age])
        .validate_required(["name", "age"])

      changeset.errors.size.should eq(0)
      changeset.valid?.should eq(true)
    end

    it "can validate multiple fields with one non-present value" do
      # No arg creates an empty instance.
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name, :age])
        .validate_required(["name", "age"])

      changeset.errors.size.should eq(0)
      changeset.valid?.should eq(true)
    end

    it "does nothing with a non-existent field" do
      changeset = User.changeset()
        .validate_required("non-existent")

      changeset.errors.size.should eq(0)
      changeset.valid?.should eq(true)
    end

    it "excludes non-existent fields when given as a list" do
      # No arg creates an empty instance.
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name, :age])
        .validate_required(["name", "non-existent", "age"])

      changeset.errors.size.should eq(0)
      changeset.valid?.should eq(true)
    end
  end
end
