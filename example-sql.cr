require "./src/change"
require "./src/change/sql/postgres_repo"
require "pg"

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


Repo = Change::SQL::PostgresRepo.new("db_url")
pp Repo.all(User)


# changeset = User.changeset(User.new, {name: "John", age: 23})
# puts Repo.insert(conn)
