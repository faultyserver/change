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
  describe "#add_error/1" do
    it "adds an error object to the Changeset's error list" do
      changeset = User.changeset()
      changeset.add_error("name", "is required")

      changeset.errors.size.should eq(1)
      error = changeset.errors.first
      error.should be_a(Change::ChangesetError)
      error.field.should eq("name")
      error.message.should eq("is required")
    end

    it "marks the changeset as invalid" do
      changeset = User.changeset()
      changeset.add_error("name", "is required")

      changeset.valid?.should eq(false)
    end
  end
end
