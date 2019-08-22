require "../spec_helper"


describe Change::Changeset do
  describe "#changed?" do
    it "returns true if the changeset has any changes" do
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name, :age])

      changeset.changed?.should eq(true)
    end

    it "returns false if the changeset has no changes" do
      user = User.new(name: "John", age: 35)

      changeset = User.changeset(user)
        .cast({name: "John", age: 35}, [:name, :age])

      changeset.changed?.should eq(false)
    end
  end
end
