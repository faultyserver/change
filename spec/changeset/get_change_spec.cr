require "../spec_helper"


describe Change::Changeset do
  describe "#get_change/2" do
    it "returns the value of a stored change if present" do
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name])

      changeset.get_change("name").should eq("John")
    end

    it "returns `default` if no change is stored" do
      changeset = User.changeset()

      changeset.get_change("name").should eq(nil)
      changeset.get_change("name", :default_value).should eq(:default_value)
    end
  end
end
