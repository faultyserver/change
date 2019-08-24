require "../spec_helper"


describe Change::Changeset do
  # NOTE: `User` currently defines name and age. These spec are not safe
  # against changes to the schema.
  describe "#each_field" do
    it "calls the given block for each field on the object" do
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name, :age])

      calls = 0
      changeset.each_field{ calls += 1 }
      calls.should eq(2)
    end

    it "calls the block even with no changes" do
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [] of String)

      calls = 0
      changeset.each_field{ calls += 1 }
      calls.should eq(2)
    end

    it "retains the type of each change" do
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name, :age])

      changeset.each_field do |field, value|
        case field
        when "name"
          value.should be_a(String)
        when "age"
          value.should be_a(Int32)
        end
      end
    end

    it "yields the stored instance value when a field is not changed" do
      user = User.new(name: "John", age: 35)
      changeset = User.changeset(user)

      changeset.each_field do |field, value|
        case field
        when "name"
          value.should eq("John")
        when "age"
          value.should eq(35)
        end
      end
    end
  end
end
