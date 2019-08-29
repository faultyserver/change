require "../repo_helper"

describe Change::SQL::Repo do
  describe "#delete" do
    it "removes the record with the matching primary key" do
      post1 = Post.new(id: 1, title: "Post 1", likes: 8)
      post2 = Post.new(id: 2, title: "Post 2", likes: 8)
      DatabaseHelper.clear_posts
      DatabaseHelper.insert_post(post1)
      DatabaseHelper.insert_post(post2)

      Repo.delete(Post, 1)

      results = Repo.all(Post)
      results.size.should eq(1)
    end

    it "does nothing when matching record exists" do
      DatabaseHelper.clear_posts

      Repo.delete(Post, 1)
    end
  end
end
