require "../repo_helper"

describe Change::SQL::Repo do
  describe "#all" do
    it "returns a list of records of the given type" do
      post1 = Post.new(title: "Post 1", likes: 8)
      post2 = Post.new(title: "Post 2", likes: 0)
      DatabaseHelper.clear_posts
      DatabaseHelper.insert_post(post1)
      DatabaseHelper.insert_post(post2)

      results = Repo.all(Post)

      results.size.should eq(2)
      results[0].title.should eq(post1.title)
      results[0].likes.should eq(post1.likes)
      results[1].title.should eq(post2.title)
      results[1].likes.should eq(post2.likes)
    end

    it "returns an empty array when no records exist" do
      DatabaseHelper.clear_posts

      results = Repo.all(Post)

      results.size.should eq(0)
    end


    describe "with query" do
      it "filters results using the given query" do
        post1 = Post.new(title: "Post 1", likes: 8)
        post2 = Post.new(title: "Post 2", likes: 0)
        DatabaseHelper.clear_posts
        DatabaseHelper.insert_post(post1)
        DatabaseHelper.insert_post(post2)

        query = Query.new
          .where(likes: 8)

        results = Repo.all(Post, query)

        results.size.should eq(1)
        results.first.title.should eq(post1.title)
        results.first.likes.should eq(post1.likes)
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

        results = Repo.all(Post, query)

        results.size.should eq(1)
        results.first.title.should eq(post2.title)
        results.first.likes.should eq(post2.likes)
      end
    end
  end
end
