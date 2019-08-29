require "../repo_helper"

def existing_post()
  changeset = Post.changeset(Post.new, {title: "Updateable Post", likes: 0})
  changeset = Repo.insert(changeset)
  changeset.instance
end

describe Change::SQL::Repo do
  describe "#update" do
    it "persists changes to the record when the changeset is valid" do
      DatabaseHelper.clear_posts
      post = existing_post()
      # Quickly assert that the existing post is the only one that exists.
      Repo.all(Post).size.should eq(1)

      changeset = Post.changeset(post, {likes: 3})
      changeset = Repo.update(changeset)

      results = Repo.all(Post)
      results.size.should eq(1)
      results.first.title.should eq("Updateable Post")
      results.first.likes.should eq(3)
    end

    it "updates the instance of the changeset when successful" do
      post = existing_post()
      changeset = Post.changeset(post, {likes: 3})
      # Ensure the change hasn't persisted yet
      changeset.instance.likes.should eq(0)

      returned_changeset = Repo.update(changeset)

      returned_changeset.instance.likes.should eq(3)
    end

    it "does not update unchanged fields" do
      post = existing_post()
      changeset = Post.changeset(post, {likes: 3})

      returned_changeset = Repo.update(changeset)
      returned_changeset.instance.title.should eq(post.title)
    end

    it "does not update the record if the changeset is invalid" do
      DatabaseHelper.clear_posts
      post = existing_post()

      # Title is required, so this is invalid
      changeset = Post.changeset(Post.new, {likes: 2})
      changeset.valid?.should eq(false)

      Repo.update(changeset)

      result = Repo.get(Post, post.id)
      raise "No result from database" unless result.is_a?(Post)
      result.likes.should eq(0)
    end

    it "does not insert a record if one does not exist" do
      DatabaseHelper.clear_posts
      # Title is required, so this should be valid
      changeset = Post.changeset(Post.new, {title: "Valid title"})
      changeset.valid?.should eq(true)

      Repo.update(changeset)

      results = Repo.all(Post)
      results.size.should eq(0)
    end
  end
end
