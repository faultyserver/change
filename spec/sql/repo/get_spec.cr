require "../repo_helper"

describe Change::SQL::Repo do
  describe "#get" do
    it "returns the record with the matching primary key" do
      post1 = Post.new(id: 1, title: "Post 1", likes: 8)
      post2 = Post.new(id: 2, title: "Post 2", likes: 8)
      DatabaseHelper.clear_posts
      DatabaseHelper.insert_post(post1)
      DatabaseHelper.insert_post(post2)

      result = Repo.get(Post, 1)

      raise "No result from database" unless result.is_a?(Post)
      result.title.should eq(post1.title)
      result.likes.should eq(post1.likes)
    end

    it "returns nil when no matching record exist" do
      DatabaseHelper.clear_posts

      result = Repo.get(Post, 1)

      result.should eq(nil)
    end
  end
end
