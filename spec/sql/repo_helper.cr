require "spec"
require "../src/change"
require "auto_initialize"


Repo = Change::SQL::Repo.new("postgres://postgres@localhost/change_travis_ci_test")

class Post
  ### Inherited behavior from Changesets ###
  include AutoInitialize
  include Change

  field id : Int32
  field title : String
  field likes : Int32
  field published_at : Time

  # Standard pattern for working with changesets. Define a static method
  # that performs casts and validations to abstract that from the callsite.
  def self.changeset(instance=self.new, changes=Hash(String, String).new)
    Changeset.new(instance)
      .cast(changes, [:title, :likes, :published_at])
      .validate_required([:title])
  end


  ### BEGIN RELEVANT STUFF ###

  include Change::SQL

  source :posts
  primary_key :id
end
