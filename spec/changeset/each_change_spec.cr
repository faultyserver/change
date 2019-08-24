require "../spec_helper"


describe Change::Changeset do
  describe "#each_change" do
    it "calls the given block for each accepted change" do
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name, :age])

      calls = 0
      changeset.each_change{ calls += 1 }
      calls.should eq(2)
    end

    it "does not call the block with no changes" do
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [] of String)

      calls = 0
      changeset.each_change{ calls += 1 }
      calls.should eq(0)
    end

    it "retains the type of each change" do
      changeset = User.changeset()
        .cast({name: "John", age: 35}, [:name, :age])

      changeset.each_change do |field, value|
        case field
        when "name"
          value.should be_a(String)
        when "age"
          value.should be_a(Int32)
        end
      end
    end

    it "does not yield unchanged values" do
      user = User.new(name: "John")
      changeset = User.changeset(user)
        .cast({name: "John", age: 35}, [:name, :age])

      called_fields = [] of String
      changeset.each_change do |field, value|
        called_fields.push(field)
      end

      called_fields.should contain("age")
      called_fields.should_not contain("name")
    end
  end
end
