require "pg"
require "./src/change"
require "./src/change/sql"

struct User
  include Change
  include Change::SQL

  source :users
  primary_key :id

  field id : Int32
  field name : String
  field age : Int32
  field bio : String

  {% begin %}
    DB.mapping({
      {{*FIELDS.map{ |f| "#{f[:name]}: #{f[:type]}?".id } }}
    })
  {% end %}

  def initialize; end

  def self.changeset(instance, changes={} of String => String)
    Changeset.new(instance)
      .cast(changes, [:name, :age, :bio])
      .validate_required([:name, :age])
  end
end


Repo = Change::SQL::Repo.new(PG.connect("postgres://postgres@localhost/change_travis_ci_test"))
Query = Change::SQL::Query

pp Repo.all(User)
pp Repo.get(User, 2)
pp Repo.one(User, Query.new.offset(1))

joe = User.changeset(User.new, {name: "Joe", age: 40})
user = Repo.insert(joe)
pp user

if user.is_a?(User)
  updated = User.changeset(user, {bio: "another"})
  pp Repo.update(updated)

  Repo.delete(User, updated.instance.id)
end


# changeset = User.changeset(User.new, {name: "John", age: 23})
# puts Repo.insert(conn)

