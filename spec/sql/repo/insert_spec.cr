require "../repo_helper"

private def post_changeset()
  Post.changeset(Post.new, {title: "A Post"})
end

describe Change::SQL::Repo do
  describe "#insert" do
    it "creates a new record when everything is valid" do
      DatabaseHelper.clear_posts

      changeset = post_changeset()
      Repo.insert(changeset)

      results = Repo.all(Post)

      results.size.should eq(1)
      results.first.title.should eq("A Post")
    end

    it "updates the instance of the changeset when successful" do
      changeset = post_changeset()

      # No primary key is set initially
      changeset.instance.id?.should eq(nil)
      returned_changeset = Repo.insert(changeset)

      # After insertion, the primary key is set by the result
      returned_changeset.instance.id.should_not eq(nil)
    end

    it "does not create a record if the changeset is invalid" do
      DatabaseHelper.clear_posts

      # Title is required, so this is invalid
      changeset = Post.changeset(Post.new, {likes: 2})
      changeset.valid?.should eq(false)

      Repo.insert(changeset)

      results = Repo.all(Post)
      results.size.should eq(0)
    end
  end
end
