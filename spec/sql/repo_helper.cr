require "spec"

require "pg"
require "auto_initialize"

require "../../src/change"

# DATABASE is made available to directly execute statements in preparation for
# tests, or as cleanup.
#
# Repo is the main object being tested here.
DATABASE = PG.connect("postgres://postgres@localhost/change_travis_ci_test")
Repo = Change::SQL::Repo.new(DATABASE)
Query = Change::SQL::Query

class Post
  ### Inherited behavior from Changesets ###
  include Change

  field id : Int32
  field title : String
  field likes : Int32

  def initialize(*, @id=nil, @title=nil, @likes=nil)
  end

  # Standard pattern for working with changesets. Define a static method
  # that performs casts and validations to abstract that from the callsite.
  def self.changeset(instance=self.new, changes=Hash(String, String).new)
    Changeset.new(instance)
      .cast(changes, [:title, :likes])
      .validate_required([:title])
  end


  ### BEGIN RELEVANT STUFF ###

  include Change::SQL

  source :posts
  primary_key :id

  gen_db_mapping
end


# These helpers bypass Repo to setup and teardown the database for a test,
# primarily creating persisted data to use in a test.
module DatabaseHelper
  extend self

  def clear_posts
    DATABASE.exec(<<-SQL)
      TRUNCATE TABLE posts
      RESTART IDENTITY
    SQL
  end

  def insert_post(post : Post)
    post_values = [post.title, post.likes]
    DATABASE.exec(<<-SQL, post_values)
      INSERT INTO posts (title, likes)
      VALUES ($1, $2)
    SQL
  end
end
