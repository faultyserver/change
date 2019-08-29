require "../repo_helper"

describe Change::SQL::Repo do
  describe "#one" do
    it "returns the first record of the given type" do
      post1 = Post.new(title: "Post 1", likes: 8)
      post2 = Post.new(title: "Post 2", likes: 7)
      DatabaseHelper.clear_posts
      DatabaseHelper.insert_post(post1)
      DatabaseHelper.insert_post(post2)

      result = Repo.one(Post)

      raise "No result from database" unless result.is_a?(Post)
      result.title.should eq(post1.title)
      result.likes.should eq(post1.likes)
    end

    it "returns nil when no matching record exist" do
      DatabaseHelper.clear_posts

      result = Repo.one(Post)

      result.should eq(nil)
    end


    describe "with query" do
      it "filters results using the given query" do
        post1 = Post.new(title: "Post 1", likes: 8)
        post2 = Post.new(title: "Post 2", likes: 0)
        DatabaseHelper.clear_posts
        DatabaseHelper.insert_post(post1)
        DatabaseHelper.insert_post(post2)

        query = Query.new
          .where(likes: 0)

        result = Repo.one(Post, query)

        raise "No result from database" unless result.is_a?(Post)
        result.title.should eq(post2.title)
        result.likes.should eq(post2.likes)
      end

      it "respects order and limits" do
        post1 = Post.new(title: "Post 1", likes: 8)
        post2 = Post.new(title: "Post 2", likes: 0)
        post3 = Post.new(title: "Post 3", likes: 8)
        DatabaseHelper.clear_posts
        DatabaseHelper.insert_post(post1)
        DatabaseHelper.insert_post(post2)
        DatabaseHelper.insert_post(post3)

        query = Query.new
          .order(title: :asc)
          .limit(1)
          .offset(1)

        result = Repo.one(Post, query)

        raise "No result from database" unless result.is_a?(Post)
        result.title.should eq(post2.title)
        result.likes.should eq(post2.likes)
      end
    end
  end
end
